import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // Parse text from the selected image path
  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    return recognizedText.text;
  }

  // Necessary to close the recognizer when not in use
  void close() {
    textRecognizer.close();
  }
}
