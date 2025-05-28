import 'dart:convert';
import 'package:http/http.dart' as http;

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

    // ✅ Ahora apuntamos al backend seguro en Vercel
    final url = Uri.parse('https://sinlimites.vercel.app/api/openrouter');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      'model': 'mistralai/mixtral-8x7b-instruct:free',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices']?[0]?['message']?['content'] ?? 'No se recibió respuesta del modelo.';
    } else {
      return 'Error: Código de respuesta ${response.statusCode}';
    }
  } catch (error) {
    print('❌ Error: $error');
    return 'Error: $error';
  }
}
