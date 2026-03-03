import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'AIzaSyC8wcn_EpKrCl8UY0MuvLhP2bTeJjwlD48';

  static final Map<String, String?> _modelHealth = {
    'gemini-flash-latest': null,
    'gemini-1.5-pro-latest': null,
  };

  static String? getModelStatus(String model) => _modelHealth[model];

  static Future<String> _generate(
    String prompt, {
    String? mimeType,
    String model = 'gemini-flash-latest',
  }) async {
    final baseUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
    final url = Uri.parse('$baseUrl?key=$_apiKey');

    final Map<String, dynamic> generationConfig = {
      'temperature': 0.7,
      'maxOutputTokens': 4096,
    };
    if (mimeType != null) {
      generationConfig['responseMimeType'] = mimeType;
    }

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': generationConfig,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        _modelHealth[model] = null;
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? '';
      } else {
        if (response.statusCode == 503 || response.statusCode == 429) {
          _modelHealth[model] = 'Sibuk';
        }
        return jsonEncode({
          'error': 'API Error ${response.statusCode}: ${response.body}',
        });
      }
    } catch (e) {
      return jsonEncode({'error': e.toString()});
    }
  }

  static Future<Map<String, dynamic>> summarizeMaterialRich(
    String text, {
    String model = 'gemini-flash-latest',
  }) async {
    final prompt =
        '''
Kamu adalah asisten belajar cerdas. Buat rangkuman materi berikut dalam Bahasa Indonesia.
Kembalikan respon dalam format JSON:
{
  "title": "Judul Materi",
  "summary": ["poin 1", "poin 2", "poin 3", "poin 4", "poin 5"],
  "glossary": [{"term": "istilah", "definition": "definisi"}],
  "flashcards": [{"q": "pertanyaan", "a": "jawaban"}],
  "practiceQuestions": [{"q": "soal", "options": ["a", "b", "c", "d"], "a": index_jawaban_benar}]
}
Materi:
$text
''';
    try {
      final result = await _generate(
        prompt,
        mimeType: 'application/json',
        model: model,
      );
      return jsonDecode(result);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<List<Map<String, String>>> generateFlashcards(
    String text, {
    int count = 5,
    String model = 'gemini-flash-latest',
  }) async {
    final prompt =
        'Buatkan TEPAT $count flashcard dari teks berikut dalam Bahasa Indonesia. '
        'Jangan berikan mukadimah, langsung berikan JSON array saja. '
        'Format: [{"question": "...", "answer": "..."}, ...]\n\n$text';

    try {
      final result = await _generate(
        prompt,
        mimeType: 'application/json',
        model: model,
      );
      final List<dynamic> decoded = jsonDecode(result);
      return decoded
          .map(
            (item) => {
              'question': item['question']?.toString() ?? '',
              'answer': item['answer']?.toString() ?? '',
            },
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> generateQuizQuestions(
    String text, {
    String model = 'gemini-flash-latest',
  }) async {
    final prompt =
        '''
Buatkan 5 soal pilihan ganda dari materi berikut dalam Bahasa Indonesia.
Kembalikan respon dalam format JSON:
[
  {
    "question": "pertanyaan",
    "options": ["a", "b", "c", "d"],
    "answer": 0 // index jawaban benar
  }
]
Materi:
$text
''';
    try {
      final result = await _generate(
        prompt,
        mimeType: 'application/json',
        model: model,
      );
      final List<dynamic> decoded = jsonDecode(result);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }
}
