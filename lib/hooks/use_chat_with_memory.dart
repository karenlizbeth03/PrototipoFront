import 'package:flutter/material.dart';

// Modelo para los mensajes
class ChatMessage {
  final String role; // 'user', 'assistant', 'system'
  final String content;

  ChatMessage({required this.role, required this.content});
}

// Servicio simulado para pedir respuesta (reemplaza con tu implementación real)
Future<String> askOpenRouter(
    String userMessage, String memory, List<ChatMessage> chatHistory) async {
  // Aquí va la lógica para llamar a tu backend o API
  await Future.delayed(Duration(seconds: 1)); // Simulación de demora
  return "Respuesta simulada para: $userMessage";
}

// Clase ChangeNotifier para manejar el estado del chat con memoria
class ChatWithMemoryProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  String _memory;

  ChatWithMemoryProvider({String initialMemory = ''}) : _memory = initialMemory;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<String> sendMessage(String userMessage) async {
    final chatHistory = List<ChatMessage>.from(_messages);

    final response = await askOpenRouter(userMessage, _memory, chatHistory);

    _messages = [
      ...chatHistory,
      ChatMessage(role: 'user', content: userMessage),
      ChatMessage(role: 'assistant', content: response),
    ];

    notifyListeners();

    return response;
  }

  void resetChat() {
    _messages = [];
    _memory = '';
    notifyListeners();
  }

  void setMemory(String newMemory) {
    _memory = newMemory;
  }
}
