import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceController extends ChangeNotifier {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcript = '';

  final void Function(String text) onResult;
  final void Function(bool listening) onListeningStatus;

  bool get isListening => _isListening;
  String get transcript => _transcript;

  VoiceController({
    required this.onResult,
    required this.onListeningStatus,
  }) {
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        _isListening = status == 'listening';
        notifyListeners();
        onListeningStatus(_isListening);
      },
      onError: (error) {
        print('Speech error: $error');
        _isListening = false;
        notifyListeners();
        onListeningStatus(false);
      },
    );
    if (!available) {
      print('Speech recognition not available');
    }
  }

  void startListening() async {
    if (!_isListening) {
      _transcript = '';
      _isListening = true;
      notifyListeners();
      onListeningStatus(true);

      await _speech.listen(
        onResult: (result) {
          _transcript = result.recognizedWords;
          notifyListeners();
          onResult(_transcript);
        },
      );
    }
  }

  void stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
      onListeningStatus(false);
    }
  }

  void cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
      _transcript = '';
      notifyListeners();
      onListeningStatus(false);
    }
  }
}
