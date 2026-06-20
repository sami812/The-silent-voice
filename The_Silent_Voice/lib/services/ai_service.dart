import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:the_silent_voice/sign/user_cache.dart';

/// ## Artificial Intelligence Suggestion Service
///
/// - this file contain all the implementation of service related to this topic
/// ---
/// #### this file contain:
///
/// 1. define the api key
/// 2. promting the chatbot
/// 3. returning the responce
/// ---
///
/// #### Personal info placeholders
/// The model is told it can use {{name}}, {{pronoun}}, {{phone}}, and
/// {{address}} in a suggestion instead of guessing the user's real info.
/// After the API responds, those placeholders are swapped for the user's
/// actual saved values (see PersonalInfoPage) entirely on-device - the
/// model itself never sees the real phone number/address/etc, only the
/// token name.

class AiService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  static Future<List<String>> getSuggestions(
    String heardText, {
    List<String> history = const [],
  }) async {
    if (heardText.trim().isEmpty) return _fallback();

    final historyContext = history.isNotEmpty
        ? 'Conversation so far:\n${history.join('\n')}\n\n'
        : '';

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'temperature': 0.3,
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are a reply suggestion assistant for a deaf person.
When given a sentence spoken by a hearing person, generate one or more response, 
natural, practical reply options the deaf person can tap to respond quickly.
Return ONLY a valid JSON array of strings. No explanation. No markdown.
Try to create a relevant response based on the history of the conversation.
Avoid simple responses like "Yes", "No", "Can you repeat?" because it is already implemented.

If the hearing person is asking for the user's name, pronouns, phone number,
or address, you may use these exact placeholders in your suggestion instead
of guessing or inventing personal information: {{name}}, {{pronoun}},
{{phone}}, {{address}}. For example, if asked "What's your name?", a good
suggestion is "My name is {{name}}." Only use a placeholder when it directly
answers what was asked - never insert one into an unrelated sentence.

Example: ["good morning.", "thank you.", "One moment."]
Example with personal info: ["My name is {{name}}.", "You can reach me at {{phone}}."]''',
            },
            {'role': 'user', 'content': '$historyContext$heardText'},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final List<dynamic> parsed = jsonDecode(content);
        final results = parsed
            .map((e) => _fillPersonalInfo(e.toString().trim()))
            .where((e) => e.isNotEmpty)
            .toList();
        return results.isEmpty ? _fallback() : results;
      }
      return _fallback();
    } catch (e) {
      return _fallback();
    }
  }

  /// Replaces {{name}}, {{pronoun}}, {{phone}}, {{address}} placeholders
  /// with the user's saved personal info. If a value isn't set, the
  /// placeholder is removed gracefully rather than leaving a literal
  /// "{{phone}}" or an awkward blank in the sentence.
  static String _fillPersonalInfo(String text) {
    final data = userCache ?? {};
    final values = {
      '{{name}}': (data['preferredName'] as String?)?.trim().isNotEmpty == true
          ? data['preferredName']
          : (data['name'] as String?) ?? '',
      '{{gender}}': (data['gender'] as String?) ?? '',
      '{{phone}}': (data['phone'] as String?) ?? '',
      '{{address}}': (data['address'] as String?) ?? '',
    };

    var result = text;
    values.forEach((placeholder, value) {
      if (!result.contains(placeholder)) return;
      if ((value as String).trim().isEmpty) {
        // no value saved - drop the placeholder rather than show a blank.
        // e.g. "My name is {{name}}." -> "My name is ." would look broken,
        // so the whole sentence containing an unfillable placeholder is
        // skipped instead by returning an empty string the caller filters.
        result = '';
      } else {
        result = result.replaceAll(placeholder, value);
      }
    });
    return result;
  }

  static List<String> _fallback() => [
    'I understand.',
    'Let me think about that.',
    'Could you write that down for me?',
  ];
}
