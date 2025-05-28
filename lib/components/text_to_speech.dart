import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechHandle {
  final VoidCallback stop;
  final VoidCallback pause;

  TextToSpeechHandle({
    required this.stop,
    required this.pause,
  });
}

class TextToSpeech extends StatefulWidget {
  final String text;
  final bool enabled;
  final void Function(TextToSpeechHandle)? onInit;

  const TextToSpeech({
    Key? key,
    required this.text,
    this.enabled = true,
    this.onInit,
  }) : super(key: key);

  @override
  State<TextToSpeech> createState() => _TextToSpeechState();
}

class _TextToSpeechState extends State<TextToSpeech> {
  final FlutterTts _flutterTts = FlutterTts();
  List<dynamic> voices = [];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    voices = await _flutterTts.getVoices;
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.95);

    widget.onInit?.call(TextToSpeechHandle(
      stop: () => _flutterTts.stop(),
      pause: () => _flutterTts.pause(),
    ));
  }

  String _detectLanguage(String text) {
    final spanishPattern = RegExp(r'[áéíóúñüÁÉÍÓÚÑÜ]');
    final englishPattern = RegExp(r'[a-zA-Z]');

    if (spanishPattern.hasMatch(text)) return 'es-ES';
    if (englishPattern.hasMatch(text)) return 'en-US';
    return 'es-ES';
  }

  Future<void> _speak() async {
    if (!widget.enabled || widget.text.isEmpty) return;

    final lang = _detectLanguage(widget.text);
    final voice = voices.firstWhere(
      (v) => v['locale'] == lang && v['name'].toString().toLowerCase().contains('enhanced'),
      orElse: () => null,
    );

    await _flutterTts.setLanguage(lang);
    if (voice != null) {
      await _flutterTts.setVoice({
        'name': voice['name'],
        'locale': voice['locale'],
      });
    }

    await _flutterTts.speak(widget.text);
  }

  @override
  void didUpdateWidget(TextToSpeech oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text || widget.enabled != oldWidget.enabled) {
      _speak();
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Equivalente a "return null" en React
  }
}
