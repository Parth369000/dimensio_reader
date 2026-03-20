import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../widgets/block_painter.dart';
import '../widgets/ui_components/content_card.dart';
import '../widgets/ui_components/primary_action_button.dart';
import '../widgets/ui_components/grid_painter.dart';
import '../widgets/ui_components/add_block_dialog.dart';
import '../widgets/ui_components/text_field_row.dart';
import '../widgets/ui_components/custom_app_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final AppController controller = Get.put(AppController());
  final TextEditingController _blockNameController = TextEditingController();

  final Color primaryBrown = const Color(0xFF8D4F23);
  final Color bgCream = const Color(0xFFFAF9F6);

  void _showAddBlockDialog(BuildContext context) {
    _blockNameController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AddBlockDialog(
          controller: controller,
          blockNameController: _blockNameController,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          // Background Grid
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          // Foreground Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Image Selection Box Custom Styled
                  PrimaryActionButton(
                    icon: Icons.add_photo_alternate,
                    label: 'Select Plan from Gallery',
                    onPressed: controller.pickImage,
                  ),
                  const SizedBox(height: 20),

                  // 2. Main 3D Stage / Image Container
                  Obx(() {
                    if (controller.selectedImagePath.value.isNotEmpty) {
                      return Container(
                        height: 420,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Image.file(
                                    File(controller.selectedImagePath.value),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Empty state visual placeholder
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 2,
                            style: BorderStyle.none,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.architecture,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No architecture plan loaded",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }),
                  const SizedBox(height: 20),

                  // 3. Document Extraction Actions
                  Obx(() {
                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryBrown,
                              surfaceTintColor: Colors.transparent,
                              elevation: 2,
                              shadowColor: Colors.black.withValues(alpha: 0.1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: primaryBrown.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                            onPressed:
                                controller.selectedImagePath.value.isEmpty ||
                                    controller.isLoading.value ||
                                    controller.isAnalyzing.value
                                ? null
                                : controller.extractDimensions,
                            icon: controller.isLoading.value
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: primaryBrown,
                                    ),
                                  )
                                : const Icon(Icons.straighten, size: 18),
                            label: Text(
                              controller.isLoading.value
                                  ? 'Scanning...'
                                  : 'Extract Dims',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryBrown,
                              surfaceTintColor: Colors.transparent,
                              elevation: 2,
                              shadowColor: Colors.black.withValues(alpha: 0.1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: primaryBrown.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                            onPressed:
                                controller.selectedImagePath.value.isEmpty ||
                                    controller.isLoading.value ||
                                    controller.isAnalyzing.value
                                ? null
                                : controller.analyzeElevation,
                            icon: controller.isAnalyzing.value
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: primaryBrown,
                                    ),
                                  )
                                : const Icon(Icons.analytics, size: 18),
                            label: Text(
                              controller.isAnalyzing.value
                                  ? 'Analyzing...'
                                  : 'Analyze JSON',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),

                  // 4. JSON Debug Box Styled
                  Obx(() {
                    if (controller.elevationAnalysisJson.value.isNotEmpty) {
                      Widget contentWidget;
                      try {
                        final data =
                            jsonDecode(controller.elevationAnalysisJson.value)
                                as Map<String, dynamic>;
                        contentWidget = Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: data.entries.map((e) {
                            if (e.value is Map) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 12,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      e.key.toUpperCase().replaceAll('_', ' '),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryBrown,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Column(
                                      children: (e.value as Map).entries.map((
                                        sub,
                                      ) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                sub.key.replaceAll('_', ' '),
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                sub.value?.toString() ?? 'N/A',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              );
                            } else if (e.value is List) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 12,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      e.key.toUpperCase().replaceAll('_', ' '),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryBrown,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      '\${(e.value as List).length} elements detected',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.key.replaceAll('_', ' '),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      e.value?.toString() ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }).toList(),
                        );
                      } catch (_) {
                        contentWidget = SelectableText(
                          controller.elevationAnalysisJson.value,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        );
                      }

                      return ContentCard(
                        title: 'AI ELEVATION SPECS',
                        tag: 'SUCCESS',
                        child: contentWidget,
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // 5. Reference list box styled
                  Obx(() {
                    if (controller.extractedDimensions.isNotEmpty) {
                      return ContentCard(
                        title: 'EXTRACTED REFERENCES',
                        tag: '${controller.extractedDimensions.length} Dims',
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 160),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: controller.extractedDimensions.length,
                            separatorBuilder: (_, _) =>
                                Divider(color: Colors.grey.shade100, height: 1),
                            itemBuilder: (context, index) {
                              final item =
                                  controller.extractedDimensions[index];
                              return ListTile(
                                visualDensity: VisualDensity.compact,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.architecture,
                                  size: 18,
                                  color: primaryBrown,
                                ),
                                title: Text(
                                  item.originalText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: Text(
                                  '${item.valueInInches.toStringAsFixed(2)}  in',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // 6. Block Building UI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 12),
                        child: Text(
                          'DIMENSION BLOCKS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddBlockDialog(context),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryBrown,
                        ),
                        icon: const Icon(Icons.add_circle, size: 20),
                        label: const Text(
                          'Add Layer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // List of mapped physical blocks
                  Obx(() {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.blocks.length,
                      itemBuilder: (context, index) {
                        final block = controller.blocks[index];
                        return ContentCard(
                          title: 'BLOCK MODEL',
                          tag: block.name.toUpperCase(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Close Button Top Right aligned
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () => controller.removeBlock(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),

                              TextFieldRow(
                                label: 'LENGTH',
                                textController: block.lengthController,
                                currentUnit: block.lengthUnit,
                                onUnitChanged: (val) => controller
                                    .updateBlockUnit(index, 'length', val!),
                              ),
                              TextFieldRow(
                                label: 'WIDTH / BREADTH',
                                textController: block.breadthController,
                                currentUnit: block.breadthUnit,
                                onUnitChanged: (val) => controller
                                    .updateBlockUnit(index, 'breadth', val!),
                              ),
                              TextFieldRow(
                                label: 'HEIGHT',
                                textController: block.heightController,
                                currentUnit: block.heightUnit,
                                onUnitChanged: (val) => controller
                                    .updateBlockUnit(index, 'height', val!),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 12),

                  // 7. Generation Engine Button over image overlay natively modeled
                  Obx(() {
                    if (controller.blocks.isNotEmpty) {
                      return PrimaryActionButton(
                        icon: controller.isGeneratingSuggestion.value
                            ? Icons.hourglass_empty
                            : Icons.check_circle,
                        label: controller.isGeneratingSuggestion.value
                            ? 'Predicting Usage...'
                            : 'Render 3D Specs',
                        onPressed: controller.isGeneratingSuggestion.value
                            ? null
                            : controller.generateBlocks,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                  const SizedBox(height: 20),

                  // 7.5 3D Visualization Section
                  Obx(() {
                    if (controller.showBlocks.value &&
                        controller.blocks.isNotEmpty) {
                      return ContentCard(
                        title: '3D VISUALIZATION',
                        tag: 'VIRTUAL RENDER',
                        child: Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: CustomPaint(
                            painter: MultiBlockPainter(
                              blocks: controller.blocks.toList(),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 12),

                  // 7.7 Area Occupancy Calibration Action
                  Obx(() {
                    if (controller.showBlocks.value &&
                        controller.blocks.isNotEmpty) {
                      return PrimaryActionButton(
                        icon: controller.isCalculatingArea.value
                            ? Icons.hourglass_top
                            : Icons.calculate,
                        label: controller.isCalculatingArea.value
                            ? 'Calibrating Space...'
                            : 'Calibrate Area Occupancy',
                        onPressed: controller.isCalculatingArea.value
                            ? null
                            : controller.calculateOccupiedArea,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 20),

                  // 7.8 Area Calibration Result
                  Obx(() {
                    if (controller.isCalculatingArea.value) {
                      return ContentCard(
                        title: 'AREA CALIBRATION',
                        tag: 'PROCESSING',
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: primaryBrown,
                            ),
                          ),
                        ),
                      );
                    } else if (controller
                        .areaCalibrationResult
                        .value
                        .isNotEmpty) {
                      return ContentCard(
                        title: 'AREA CALIBRATION',
                        tag: 'MATH VERIFIED',
                        child: HtmlWidget(
                          controller.areaCalibrationResult.value,
                          textStyle: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 20),

                  // 8. Material Usage Prediction
                  Obx(() {
                    if (controller.isGeneratingSuggestion.value) {
                      return ContentCard(
                        title: 'MATERIAL PREDICTION',
                        tag: 'ANALYZING',
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: primaryBrown,
                            ),
                          ),
                        ),
                      );
                    } else if (controller.materialSuggestion.value.isNotEmpty) {
                      return ContentCard(
                        title: 'MATERIAL PREDICTION',
                        tag: 'AI INVENTORY',
                        child: HtmlWidget(
                          controller.materialSuggestion.value,
                          textStyle: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
