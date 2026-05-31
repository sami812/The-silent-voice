import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
Example: ["good morning.", "thank you.", "One moment."]''',
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
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
        return results.isEmpty ? _fallback() : results;
      }
      return _fallback();
    } catch (e) {
      return _fallback();
    }
  }

  static List<String> _fallback() => [
    'I understand.',
    'Let me think about that.',
    'Could you write that down for me?',
  ];
}
