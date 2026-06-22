import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:the_silent_voice/services/sign_dictionary.dart';

/// ## Sign Language Service
///
/// - takes a short burst of frames (captured ~200ms apart) instead of a
///   single still photo, so the model can see motion, not just a static pose
/// - asks the vision model to classify the hand shape into 5 finger flags
///   (extended/curled) + a motion category - NOT to guess the word itself
/// - looks that classification up via [findClosestSign], which tolerates
///   a single misclassified finger instead of requiring a perfect match
///
/// Why classify instead of translate directly: vision LLMs are much more
/// reliable at structured classification ("is this finger up or down?")
/// than at inventing a translation from scratch. It also means the
/// vocabulary can grow to any size just by adding entries to
/// sign_dictionary.dart - no prompt or code changes needed.
class SignLanguageService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'meta-llama/llama-4-scout-17b-16e-instruct';

  /// Standard "no clear sign" response, used so callers can detect it
  /// without doing fragile string matching everywhere.
  static const String unclearResult = 'Unclear, please try again';

  /// How many fingers' worth of misclassification to tolerate when
  /// matching against the dictionary. 1 = forgive a single wrong finger;
  /// 0 = require an exact match. Higher values trade accuracy for more
  /// successful matches - 1 is a reasonable starting point.
  static const int _matchTolerance = 1;

  /// Takes a list of image frames (captured a few hundred ms apart),
  /// classifies the hand shape + motion, and returns the matching word
  /// from the dictionary - or [unclearResult] if no match is found.
  static Future<String> translateSign(List<File> frames) async {
    if (frames.isEmpty) return 'No frames captured.';

    try {
      final motionList = signMotionCategories.join(', ');

      final content = <Map<String, dynamic>>[
        {
          'type': 'text',
          'text':
              '''You are analyzing a short sequence of ${frames.length} frames captured roughly 200ms apart, showing one hand making a sign language gesture.

Look across ALL the frames together to judge hand shape and movement as a whole gesture, not just the first frame.

Classify the hand into exactly these 6 values and return ONLY a JSON object, nothing else - no markdown, no explanation:

{
  "thumb": 0 or 1,
  "index": 0 or 1,
  "middle": 0 or 1,
  "ring": 0 or 1,
  "pinky": 0 or 1,
  "motion": one of [$motionList]
}

Rules:
- For each finger: 1 if extended/straight, 0 if curled/folded into the palm.
- "motion" describes how the hand moved while holding that shape during the frame sequence. Use "still" if the hand shape stayed in roughly the same position the whole time.
- Only judge motion that is visible as a 2D position change in frame (left/right/up/down/shaking back and forth). Do not try to judge movement toward or away from the camera.
- If no hand is clearly visible in the frames, respond with {"thumb": -1, "index": -1, "middle": -1, "ring": -1, "pinky": -1, "motion": "none"}.
- Return ONLY the JSON object. No other text.''',
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
          'max_tokens': 100,
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
      final rawContent = (data['choices'][0]['message']['content'] as String).trim();

      final classification = _parseClassification(rawContent);
      if (classification == null) return unclearResult;

      final word = findClosestSign(
        classification.fingers,
        classification.motion,
        maxDistance: _matchTolerance,
      );
      return word ?? unclearResult;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  /// Parses the model's JSON response. Returns null if the response
  /// couldn't be parsed, used a motion outside the known set, or the
  /// model reported no hand visible (-1 values).
  static _HandClassification? _parseClassification(String rawContent) {
    try {
      final cleaned = rawContent
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> json = jsonDecode(cleaned);

      final thumb = json['thumb'];
      final index = json['index'];
      final middle = json['middle'];
      final ring = json['ring'];
      final pinky = json['pinky'];
      final motion = json['motion'];

      if (thumb == null ||
          index == null ||
          middle == null ||
          ring == null ||
          pinky == null ||
          motion is! String) {
        return null;
      }

      final fingers = [thumb, index, middle, ring, pinky];
      // -1 means the model couldn't see a hand at all
      if (fingers.any((f) => f != 0 && f != 1)) return null;
      if (!signMotionCategories.contains(motion)) return null;

      return _HandClassification(fingers.cast<int>(), motion);
    } catch (e) {
      return null;
    }
  }
}

class _HandClassification {
  final List<int> fingers;
  final String motion;
  _HandClassification(this.fingers, this.motion);
}
