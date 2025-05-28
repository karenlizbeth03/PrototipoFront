import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TalkingAvatar extends StatefulWidget {
  @override
  _TalkingAvatarState createState() => _TalkingAvatarState();
}

class _TalkingAvatarState extends State<TalkingAvatar> {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> hablar(String texto) async {
    setState(() {
      isSpeaking = true;
    });
    await flutterTts.speak(texto);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isSpeaking ? 'assets/Pumi.gif' : 'assets/Pumi.png',
              width: 400,
              height: 300,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => hablar('Hola, soy tu asistente. ¿En qué puedo ayudarte hoy?'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
              ),
              child: Text('HABLAR'),
            ),
          ],
        ),
      ),
    );
  }
}
