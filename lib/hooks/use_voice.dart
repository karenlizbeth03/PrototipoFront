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
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'listening') {
          isListening = true;
        } else {
          isListening = false;
        }
      },
      onError: (error) {
        print('Speech error: $error');
        isListening = false;
      },
    );
  }

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
    localeId: 'es_ES',
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
