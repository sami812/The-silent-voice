import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// ## Sign Language Service
///
/// - takes a short burst of frames (captured ~200ms apart) instead of a
///   single still photo, so the model can see motion, not just a static pose
/// - sends them to Groq vision API (llama-4-scout)
/// - returns the translated text
///

class SignLanguageService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'meta-llama/llama-4-scout-17b-16e-instruct';

  /// Standard "no clear sign" response, used so callers can detect it
  /// without doing fragile string matching everywhere.
  static const String unclearResult = 'Unclear, please try again';

  /// Takes a list of image frames (captured a few hundred ms apart) and
  /// returns the sign language translation. Sending multiple frames lets
  /// the model interpret motion across the sequence instead of guessing
  /// from a single static pose.
  static Future<String> translateSign(List<File> frames) async {
    if (frames.isEmpty) return 'No frames captured.';

    try {
      final content = <Map<String, dynamic>>[
        {
          'type': 'text',
          'text':
              '''You are a sign language interpreter.
You will see a short sequence of ${frames.length} frames captured roughly 200ms apart, showing a hand sign in motion.
Look across ALL the frames together (not just one) to understand the hand shape, position, and movement as a whole gesture.
If you can identify a sign language gesture, translate it into a short, natural English word or sentence.
If no clear sign language gesture is visible across the frames, respond with exactly "$unclearResult".
Respond with ONLY the translated word/sentence or "$unclearResult". No explanation, no extra text, no quotation marks.''',
        },
      ];

      for (final frame in frames) {
        final bytes = await frame.readAsBytes();
        final base64Image = base64Encode(bytes);
        content.add({
          'type': 'image_url',
          'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
        });
      }

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
            {'role': 'user', 'content': content},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = (data['choices'][0]['message']['content'] as String).trim();
        return result;
      }

      return 'Translation failed. Please try again.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
