import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// ## Sign Language Service
///
/// - takes a captured image
/// - sends it to Groq vision API (llama-4-scout)
/// - returns the translated text

class SignLanguageService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'meta-llama/llama-4-scout-17b-16e-instruct';

  /// Takes an image file and returns the sign language translation
  static Future<String> translateSign(File imageFile) async {
    try {
      // convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 200,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': '''You are a sign language interpreter. 
Look at this image and identify any sign language gesture or hand sign being made.
If you see a sign language gesture, translate it into a natural English sentence.
If no clear sign language gesture is visible, respond with "No sign detected".
Respond with ONLY the translated sentence or "No sign detected". No explanation.''',
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      }

      return 'Translation failed. Please try again.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
