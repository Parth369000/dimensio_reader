import 'package:flutter_dotenv/flutter_dotenv.dart';

class Apis {
  /// Gemini API Key — loaded from .env file.
  /// NEVER hardcode API keys in source code.
  static String get geminiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
