import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> askOpenRouter(
  String userMessage,
  String memory,
  List<Map<String, String>> chatHistory,
) async {
  try {
    final systemContent =
        memory.isNotEmpty
            ? 'El siguiente documento es tu única fuente de información. Úsalo como referencia para responder todas las preguntas del usuario.\n\n$memory'
            : 'Eres un asistente conversacional amigable que responde como una persona normal. Si el usuario te saluda, responde con un saludo también.';

    final messages = [
      {'role': 'system', 'content': systemContent},
      ...chatHistory,
      {'role': 'user', 'content': userMessage},
    ];

    final url = Uri.parse('https://sinlimites.vercel.app/api/openrouter');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({'messages': messages});


    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final assistantMessage =
          data['choices']?[0]?['message']?['content'] ??
          'No se recibió respuesta del modelo.';
      return assistantMessage;
    } else {
      return 'Error: Código de respuesta ${response.statusCode}';
    }
  } catch (error) {
    print('❌ Error al hacer la petición a OpenRouter: $error');
    return 'Error: $error';
  }
}
