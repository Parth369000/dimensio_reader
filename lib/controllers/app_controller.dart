import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/dimension_item.dart';
import '../models/block_model.dart';
import '../services/ocr_service.dart';
import '../services/gemini_service.dart';
import '../utils/dimension_parser.dart';
import '../utils/toast_utils.dart';

class AppController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final GeminiService _geminiService = GeminiService();

  var isLoading = false.obs;
  var isAnalyzing = false.obs;
  var selectedImagePath = ''.obs;

  var rawExtractedText = ''.obs;
  var elevationAnalysisJson = ''.obs;
  var extractedDimensions = <DimensionItem>[].obs;

  var blocks = <BlockModel>[].obs;
  var showBlocks = false.obs;

  var isGeneratingSuggestion = false.obs;
  var materialSuggestion = ''.obs;

  var isCalculatingArea = false.obs;
  var areaCalibrationResult = ''.obs;

  @override
  void onClose() {
    _ocrService.close();
    super.onClose();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImagePath.value = image.path;
        rawExtractedText.value = '';
        elevationAnalysisJson.value = '';
        extractedDimensions.clear();
        blocks.clear();
        showBlocks.value = false;
        materialSuggestion.value = '';
        areaCalibrationResult.value = '';
      }
    } catch (e) {
      ToastUtils.showError('Failed to pick image: $e');
    }
  }

  Future<void> extractDimensions() async {
    if (selectedImagePath.value.isEmpty) {
      ToastUtils.showInfo('Please select an image first');
      return;
    }

    try {
      isLoading.value = true;
      showBlocks.value = false;

      // Extract dimensions using Gemini
      final geminiStrings = await _geminiService.extractDimensionsFromImage(
        selectedImagePath.value,
      );

      extractedDimensions.clear();

      if (geminiStrings.isEmpty) {
        // Fallback to ML Kit + Regex if Gemini fails
        final text = await _ocrService.extractText(selectedImagePath.value);
        rawExtractedText.value = text;
        final dimensions = DimensionParser.extractDimensions(text);
        if (dimensions.isEmpty) {
          ToastUtils.showInfo('No dimensions found in the image');
        } else {
          extractedDimensions.assignAll(dimensions);
          ToastUtils.showSuccess('Extracted \${dimensions.length} dimensions');
        }
      } else {
        // Parse Gemini values into DimensionItem models
        for (final ds in geminiStrings) {
          final parsed = DimensionParser.extractDimensions(ds);
          if (parsed.isNotEmpty) {
            extractedDimensions.add(parsed.first);
          } else {
            // If Regex fails but Gemini gave something, add manually as inches (fallback logic)
            double approx =
                double.tryParse(ds.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
            extractedDimensions.add(
              DimensionItem(originalText: ds, valueInInches: approx),
            );
          }
        }
        ToastUtils.showSuccess(
          'Extracted \${extractedDimensions.length} dimensions via Gemini AI',
        );
      }
    } catch (e) {
      ToastUtils.showError('Failed to extract text: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> analyzeElevation() async {
    if (selectedImagePath.value.isEmpty) {
      ToastUtils.showInfo('Please select an image first');
      return;
    }

    try {
      isAnalyzing.value = true;
      elevationAnalysisJson.value = '';

      final jsonResult = await _geminiService.analyzeElevationDrawing(
        selectedImagePath.value,
      );

      if (jsonResult != null && jsonResult.isNotEmpty) {
        elevationAnalysisJson.value = jsonResult;
        ToastUtils.showSuccess('Elevation analysis completed');
      } else {
        ToastUtils.showError('Failed to generate JSON or returned empty');
      }
    } catch (e) {
      ToastUtils.showError('Analysis error: $e');
    } finally {
      isAnalyzing.value = false;
    }
  }

  void addBlock(String name) {
    if (name.trim().isEmpty) {
      ToastUtils.showError('Block name cannot be empty');
      return;
    }
    if (blocks.any((b) => b.name == name.trim())) {
      ToastUtils.showError('A block named "\${name.trim()}" already exists');
      return;
    }
    blocks.add(BlockModel(name: name.trim()));
    showBlocks.value = false;
  }

  void removeBlock(int index) {
    blocks.removeAt(index);
    showBlocks.value = false;
  }

  void generateBlocks() {
    if (blocks.isEmpty) {
      ToastUtils.showInfo('Please add at least one block');
      return;
    }
    for (var block in blocks) {
      if (block.lengthController.text.trim().isEmpty ||
          block.breadthController.text.trim().isEmpty ||
          block.heightController.text.trim().isEmpty) {
        ToastUtils.showInfo(
          'Please enter Length, Breadth, and Height for \${block.name}',
        );
        return;
      }

      block.parsedL = _parseInput(
        block.lengthController.text,
        block.lengthUnit,
      );
      block.parsedB = _parseInput(
        block.breadthController.text,
        block.breadthUnit,
      );
      block.parsedH = _parseInput(
        block.heightController.text,
        block.heightUnit,
      );
    }
    blocks.refresh();
    showBlocks.value = true;

    _fetchMaterialSuggestion();
  }

  Future<void> _fetchMaterialSuggestion() async {
    if (selectedImagePath.value.isEmpty) return;

    try {
      isGeneratingSuggestion.value = true;
      materialSuggestion.value = '';

      String blocksData = blocks
          .map(
            (b) =>
                "\${b.name}: \${b.parsedL}\" L x \${b.parsedB}\" W x \${b.parsedH}\" H",
          )
          .join("\\n");

      if (elevationAnalysisJson.value.isEmpty) {
        ToastUtils.showInfo('Analyzing structure details first...');
        await analyzeElevation();
      }

      String designDims = extractedDimensions
          .map((d) => d.originalText)
          .join(", ");

      final suggestion = await _geminiService.generateMaterialUsageSuggestion(
        selectedImagePath.value,
        blocksData,
        elevationAnalysisJson.value,
        designDims,
      );

      if (suggestion != null && suggestion.isNotEmpty) {
        materialSuggestion.value = suggestion;
        ToastUtils.showSuccess('Material usage prediction complete');
      }
    } catch (e) {
      ToastUtils.showError('Failed to generate usage prediction');
    } finally {
      isGeneratingSuggestion.value = false;
    }
  }

  Future<void> calculateOccupiedArea() async {
    if (selectedImagePath.value.isEmpty || blocks.isEmpty) return;

    try {
      isCalculatingArea.value = true;
      areaCalibrationResult.value = '';

      String blocksData = blocks
          .map(
            (b) =>
                "\${b.name}: \${b.parsedL}\" L x \${b.parsedB}\" W x \${b.parsedH}\" H",
          )
          .join("\\n");

      final result = await _geminiService.calculateOccupiedArea(
        selectedImagePath.value,
        blocksData,
        elevationAnalysisJson.value,
      );

      if (result != null && result.isNotEmpty) {
        areaCalibrationResult.value = result;
        ToastUtils.showSuccess('Area calibration complete');
      }
    } catch (e) {
      ToastUtils.showError('Failed to calculate area');
    } finally {
      isCalculatingArea.value = false;
    }
  }

  double _parseInput(String input, String unit) {
    if (input.trim().isEmpty) return 0.0;
    try {
      double value = double.parse(input.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (unit == 'cm') {
        value = value / 2.54; // Convert cm to inches
      }
      return value;
    } catch (_) {
      return 0.0;
    }
  }

  void updateBlockUnit(int index, String field, String unit) {
    if (field == 'length') {
      blocks[index].lengthUnit = unit;
    } else if (field == 'breadth') {
      blocks[index].breadthUnit = unit;
    } else if (field == 'height') {
      blocks[index].heightUnit = unit;
    }
    blocks.refresh();
  }
}
