// chat_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../components/chat_bubble.dart';
import '../components/file_picker_button.dart';
import '../components/text_to_speech.dart';
import '../hooks/use_voice.dart';
import '../services/ask_open_router.dart';
import '../components/voice_button.dart';
import '../services/chat_service.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:http_parser/http_parser.dart'; // Para MediaType


class Message {
  final String id;
  final String text;
  final String sender;

  Message({required this.id, required this.text, required this.sender});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  bool _isSendingMessage = false;
  List<Message> messages = [];
  bool isSpeechEnabled = true;

  String? pdfText;
  String? pdfName;
  List<Map<String, String>> chatHistory = [];
  String lastBotText = '';

  late UseVoice useVoice;

  @override
  void initState() {
    super.initState();
    useVoice = UseVoice(
  onTranscriptChange: (transcript) {
    if (transcript.isNotEmpty) {
      final lower = transcript.toLowerCase();

      if (lower.contains('cargar archivo')) {
        // Simula presionar el botón para cargar archivo
        pickFileProgrammatically();
        useVoice.cancelListening();
        return;
      } else if (lower.contains('enviar mensaje')) {
        sendMessage();
        useVoice.cancelListening();
        return;
      }

      // Actualiza el campo de texto si no es un comando
      if (transcript != _inputController.text) {
        _inputController.text = transcript;
      }
    }
  },
);

    flutterTts.setLanguage('es');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }
  

  Future<String> getBotResponse(String userInput) async {
    try {
      final response = await askOpenRouter(
        userInput,
        pdfText ?? '',
        chatHistory,
      );
      return response;
    } catch (e) {
      print('Error al obtener respuesta: $e');
      return 'Lo siento, hubo un error al obtener la respuesta.';
    }
  }

  Future<void> sendMessage() async {
    final text = _inputController.text.trim();

    if (text.isEmpty && pdfText == null) return;
    // Detén escucha de voz si está activa
    if (useVoice.isListening) {
      await useVoice.stopListening();
    }

    // Limpia input inmediatamente para que el usuario vea el campo limpio
    _inputController.clear();
    if (pdfText != null && pdfName != null) {
      final pdfMessage = Message(
        id: DateTime.now().toIso8601String(),
        text: '📄 Archivo PDF: $pdfName',
        sender: 'user',
      );
      setState(() {
        messages.add(pdfMessage);
        chatHistory.add({'role': 'user', 'content': pdfText!});
        pdfText = null;
        pdfName = null;
      });
    }

    if (text.isNotEmpty) {
      final userMessage = Message(
        id: DateTime.now().toIso8601String(),
        text: text,
        sender: 'user',
      );
      setState(() {
        messages.add(userMessage);
        _inputController.clear();
        chatHistory.add({'role': 'user', 'content': text});
      });
    }

    _scrollToBottom();

    try {
      final botResponse = await getBotResponse(text);
      final botMessage = Message(
        id: DateTime.now().toIso8601String(),
        text: botResponse,
        sender: 'bot',
      );
      setState(() {
        messages.add(botMessage);
        lastBotText = botResponse;
        chatHistory.add({'role': 'assistant', 'content': botResponse});
      });

      _scrollToBottom();
    } catch (e) {
      final errorMessage = Message(
        id: DateTime.now().toIso8601String(),
        text: 'Lo siento, hubo un error.',
        sender: 'bot',
      );
      setState(() {
        messages.add(errorMessage);
      });
      _scrollToBottom();
    }
  }

  void handleExtractedPdf(String text, String name) {
    setState(() {
      pdfText = text;
      pdfName = name;
    });
    setPDFContext(text);
  }

  void clearPdf() {
    setState(() {
      pdfText = null;
      pdfName = null;
    });
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void pickFileProgrammatically() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );

  if (result != null) {
    final file = result.files.single;
    final fileName = file.name;

    if (file.extension?.toLowerCase() != 'pdf') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solo se permiten archivos PDF")),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://backendpdf-production-57c7.up.railway.app/upload-pdf'),
    );

    try {
      if (kIsWeb) {
        if (file.bytes == null) return;
        request.files.add(
          http.MultipartFile.fromBytes(
            'pdf',
            file.bytes!,
            filename: fileName,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pdf',
            file.path!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final decoded = json.decode(responseData.body);
        handleExtractedPdf(decoded['text'], fileName);
      } else {
        handleExtractedPdf('Error al procesar el archivo PDF.', fileName);
      }
    } catch (e) {
      handleExtractedPdf('Error de red.', fileName);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 20, top: 15),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return ChatBubble(text: msg.text, sender: msg.sender);
                },
              ),
            ),

            // Mostrar nombre PDF cargado justo arriba del input (puedes comentar si quieres ocultar)
            if (pdfName != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/pdf-icon.png', width: 24, height: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pdfName!,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: clearPdf,
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        enabled: !useVoice.isListening,
                        decoration: InputDecoration(
                          hintText: 'Habla o escribe...',
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),
                    FilePickerButton(
                      onExtractText:
                          (text, name) => handleExtractedPdf(text, name),
                    ),
                    VoiceButton(
                      onPress: () {
                        useVoice.startListening();
                        setState(() {});
                      },
                      icon: Icons.mic,
                      disabled: useVoice.isListening,
                      color: const Color(0xFF913D21),
                    ),
                    VoiceButton(
                      onPress: () {
                        useVoice.stopListening();
                        setState(() {});
                      },
                      icon: Icons.stop,
                      disabled: !useVoice.isListening,
                      color: const Color(0xFF913D21),
                    ),
                    IconButton(
                      onPressed: sendMessage,
                      icon: const Icon(Icons.send),
                      color: const Color.fromARGB(255, 33, 145, 65),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
