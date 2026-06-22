import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:the_silent_voice/services/sign_dictionary.dart';

/// ## Sign Language Service
///
/// Sends a burst of frames to the Groq vision API and asks it to classify:
///   1. Which fingers are extended (5 binary flags)
///   2. The hand's orientation (palm direction / blade direction)
///
/// The result is looked up in [signDictionary] via [findClosestSign],
/// which tolerates a single misclassified finger (Hamming distance ≤ 1).
///
/// Orientation replaces the old "motion" system because it is a single-
/// frame static judgment — much more reliable than asking the model to
/// compare frames over time and decide "did the hand move upward?"
class SignLanguageService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'meta-llama/llama-4-scout-17b-16e-instruct';

  static const String unclearResult = 'Unclear, please try again';

  /// How many fingers' worth of misclassification to tolerate.
  /// 1 = forgive a single wrong finger; 0 = require exact match.
  static const int _matchTolerance = 1;

  static Future<String> translateSign(List<File> frames) async {
    if (frames.isEmpty) return 'No frames captured.';

    try {
      final orientationList = signOrientations.join(', ');

      final content = <Map<String, dynamic>>[
        {
          'type': 'text',
          'text': '''You are analyzing ${frames.length} frames of a hand sign captured ~200ms apart.

Look at ALL frames together to judge both hand shape and orientation.

Return ONLY this JSON object — no markdown, no explanation:

{
  "thumb": 0 or 1,
  "index": 0 or 1,
  "middle": 0 or 1,
  "ring": 0 or 1,
  "pinky": 0 or 1,
  "orientation": one of [$orientationList]
}

Finger rules:
- 1 = finger is extended/straight
- 0 = finger is curled/folded into palm

Orientation rules:
- "toward_them"  = palm facing outward (toward the camera / viewer)
- "toward_you"   = palm facing inward (toward the signer themselves)
- "palm_up"      = palm facing upward (toward the ceiling)
- "palm_down"    = palm facing downward (toward the floor)
- "side_up"      = hand held like a blade with fingers pointing upward
- "side_forward" = hand held like a blade with fingers pointing toward the camera

If no hand is visible, return: {"thumb":-1,"index":-1,"middle":-1,"ring":-1,"pinky":-1,"orientation":"none"}

Return ONLY the JSON. No other text.''',
        },
      ];

      for (final frame in frames) {
        final bytes = await frame.readAsBytes();
        content.add({
          'type': 'image_url',
          'image_url': {'url': 'data:image/jpeg;base64,${base64Encode(bytes)}'},
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
          'max_tokens': 120,
          'temperature': 0,
          'messages': [
            {'role': 'user', 'content': content},
          ],
        }),
      );

      if (response.statusCode != 200) {
        return 'Translation failed. Please try again.';
      }

      final data = jsonDecode(response.body);
      final raw = (data['choices'][0]['message']['content'] as String).trim();

      final classification = _parse(raw);
      if (classification == null) return unclearResult;

      final word = findClosestSign(
        classification.fingers,
        classification.orientation,
        maxDistance: _matchTolerance,
      );
      return word ?? unclearResult;
    } catch (e) {
      return 'Error: $e';
    }
  }

  static _Classification? _parse(String raw) {
    try {
      final cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      final thumb  = json['thumb'];
      final index  = json['index'];
      final middle = json['middle'];
      final ring   = json['ring'];
      final pinky  = json['pinky'];
      final ori    = json['orientation'];

      if (thumb == null || index == null || middle == null ||
          ring == null || pinky == null || ori is! String) return null;

      final fingers = [thumb, index, middle, ring, pinky];
      if (fingers.any((f) => f != 0 && f != 1)) return null;
      if (!signOrientations.contains(ori)) return null;

      return _Classification(fingers.cast<int>(), ori);
    } catch (_) {
      return null;
    }
  }
}

class _Classification {
  final List<int> fingers;
  final String orientation;
  _Classification(this.fingers, this.orientation);
}
