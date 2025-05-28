import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String pdfContext = '';

void setPDFContext(String text) {
  pdfContext = text;
}

Future<String> askWithPDFContext(String question) async {
  try {
    final prompt = '''
Eres un asistente experto. Usa únicamente la información del siguiente texto para responder preguntas.

Texto del documento:
"""$pdfContext"""

Pregunta: $question
''';

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final headers = {
  'Authorization': 'Bearer ${dotenv.env['OPENROUTER_API_KEY']}',
  'Content-Type': 'application/json',
  'X-Title': 'Free ChatBot',
};

    final body = jsonEncode({
      'model': 'mistralai/mixtral-8x7b-instruct:free',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices']?[0]?['message']?['content'] ?? 'No response received.';
    } else {
      return 'Error: Código de respuesta ${response.statusCode}';
    }
  } catch (error) {
    print('❌ Error: $error');
    return 'Error: $error';
  }
}
