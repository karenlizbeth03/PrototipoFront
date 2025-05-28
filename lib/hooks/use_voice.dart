import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class UseVoice {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final void Function(String) onTranscriptChange;

  bool isListening = false;
  String transcript = '';

  UseVoice({required this.onTranscriptChange}) {
    _initSpeech();
  }

 void _initSpeech() async {
  bool available = await _speech.initialize(
    onStatus: (status) {
      isListening = status == 'listening';
    },
    onError: (error) {
      print('Speech error: $error');
      isListening = false;
    },
  );

  if (available) {
    var locales = await _speech.locales();
    print('Locales disponibles:');
    for (var locale in locales) {
      print(' - ${locale.localeId} (${locale.name})');
    }
    // Puedes escoger un locale compatible aquí, por ejemplo:
    // localeId = locales.firstWhere((l) => l.localeId.startsWith('es')).localeId;
  }
}


String localeIdToUse = 'es_ES'; // por defecto

Future<void> startListening() async {
  if (!_speech.isAvailable) {
    print('Speech recognition no disponible.');
    return;
  }

  transcript = '';
  isListening = true;

  await _speech.listen(
    onResult: (result) {
      transcript = result.recognizedWords;
      onTranscriptChange(transcript);
    },
    localeId: localeIdToUse,  // usa el localeId correcto
    listenMode: stt.ListenMode.dictation,
    partialResults: true,
    pauseFor: const Duration(hours: 1),
    listenFor: const Duration(hours: 1),
  );
}

  Future<void> stopListening() async {
  if (isListening) {
    await _speech.stop();
    isListening = false;
  }
}


  void cancelListening() {
    _speech.cancel();
    isListening = false;
  }
}
