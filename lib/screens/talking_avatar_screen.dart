import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../hooks/use_voice.dart';
import '../components/voice_button.dart';
import '../components/file_picker_button.dart';
import '../services/ask_open_router.dart';
import '../services/chat_service.dart';

class TalkingAvatarScreen extends StatefulWidget {
  @override
  _TalkingAvatarScreenState createState() => _TalkingAvatarScreenState();
}

class _TalkingAvatarScreenState extends State<TalkingAvatarScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();

  String lastBotText = '';
  bool isSpeechEnabled = true;
  bool isSpeaking = false;
  bool isPaused = false;
  String? pdfText;
  String? pdfName;
  List<Map<String, String>> chatHistory = [];

  List<String> speechChunks = [];
  int currentChunkIndex = 0;

  late UseVoice useVoice;

  @override
  void initState() {
    super.initState();
    useVoice = UseVoice(
      onTranscriptChange: (transcript) {
        if (transcript.isNotEmpty && transcript != _inputController.text) {
          _inputController.text = transcript;
        }
      },
    );

    flutterTts.setLanguage('es');
    flutterTts.setCompletionHandler(() {
      if (!isPaused) {
        currentChunkIndex++;
        _speakNextChunk();
      }
    });
    flutterTts.setCancelHandler(() {
      setState(() {
        isSpeaking = false;
        // No cambiamos isPaused aquí
      });
    });
    flutterTts.setErrorHandler((msg) {
      setState(() {
        isSpeaking = false;
        isPaused = false;
      });
    });
  }

  List<String> _splitTextIntoChunks(String text) {
    final regex = RegExp(r'(?<=[.!?])\s+');
    return text.split(regex).where((s) => s.trim().isNotEmpty).toList();
  }

  Future<void> speakText(String text) async {
    await flutterTts.stop();

    speechChunks = _splitTextIntoChunks(text);
    currentChunkIndex = 0;

    _speakNextChunk();
  }

  void _speakNextChunk() async {
    if (currentChunkIndex < speechChunks.length) {
      setState(() {
        isSpeaking = true;
        isPaused = false;
      });

      await flutterTts.speak(speechChunks[currentChunkIndex]);
    } else {
      setState(() {
        isSpeaking = false;
      });
    }
  }

  Future<void> togglePauseResume() async {
    if (isPaused) {
      setState(() {
        isPaused = false;
      });
      _speakNextChunk();
    } else {
      await flutterTts.stop();
      setState(() {
        isPaused = true;
        isSpeaking = false;
      });
    }
  }

  Future<void> sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty && pdfText == null) return;

    /* if (useVoice.isListening) {
      await useVoice.stopListening();
      setState(() {});
    } */

    _inputController.clear();

    if (pdfText != null && pdfName != null) {
      chatHistory.add({'role': 'user', 'content': pdfText!});
      setState(() {
        lastBotText = '📄 Archivo cargado: $pdfName';
        pdfText = null;
        pdfName = null;
      });
    }

    if (text.isNotEmpty) {
      chatHistory.add({'role': 'user', 'content': text});
    }

    try {
      final botResponse = await askOpenRouter(text, pdfText ?? '', chatHistory);
      setState(() {
        lastBotText = botResponse;
        chatHistory.add({'role': 'assistant', 'content': botResponse});
      });

      if (isSpeechEnabled) await speakText(botResponse);
    } catch (e) {
      final errorText = 'Lo siento, ocurrió un error al obtener la respuesta.';
      setState(() => lastBotText = errorText);
      if (isSpeechEnabled) await speakText(errorText);
    }
  }

  void handleExtractedPdf(String text, [String? name]) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      isSpeaking ? 'assets/Pumi.gif' : 'assets/Pumi.png',
                      width: 400,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                    if (useVoice.isListening)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          '🎤 Escuchando...',
                          style: TextStyle(color: Colors.green, fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (pdfName != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/pdf-icon.png', width: 24, height: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pdfName!,
                        style: const TextStyle(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: clearPdf,
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFEEBA),
                    ),
                    onPressed: () => togglePauseResume(),
                    child: Text(
                      isPaused ? '▶️ Continuar' : '⏸️ Pausar',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD1ECF1),
                    ),
                    onPressed: () => speakText(lastBotText),
                    child: const Text('🔁 Repetir', style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF8D7DA),
                    ),
                    onPressed: () async {
                      await flutterTts.stop();
                      setState(() {
                        isSpeaking = false;
                        isPaused = false;
                      });
                    },
                    child: const Text('⏹️ Detener', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                        decoration: const InputDecoration(
                          hintText: 'Habla o escribe...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),
                    FilePickerButton(
                      onExtractText: (text, name) => handleExtractedPdf(text, name),
                    ),
                    VoiceButton(
                      onPress: () async {
                        await useVoice.startListening();
                        setState(() {});
                      },
                      icon: Icons.mic,
                      disabled: useVoice.isListening,
                      color: const Color(0xFF913D21),
                    ),
                    VoiceButton(
                      onPress: () async {
                        await useVoice.stopListening();
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
