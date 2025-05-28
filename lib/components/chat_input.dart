import 'package:flutter/material.dart';
import './voice_button.dart'; // Asegúrate de tener este archivo migrado también

class ChatInput extends StatelessWidget {
  final String input;
  final Function(String) setInput;
  final VoidCallback sendMessage;
  final VoidCallback startListening;
  final VoidCallback stopListening;
  final bool isListening;

  const ChatInput({
    Key? key,
    required this.input,
    required this.setInput,
    required this.sendMessage,
    required this.startListening,
    required this.stopListening,
    required this.isListening,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  enabled: !isListening,
                  onChanged: setInput,
                  onSubmitted: (_) => sendMessage(),
                  controller: TextEditingController(text: input),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Escribe o habla...',
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              VoiceButton(
                onPress: startListening,
                icon: Icons.mic,
                disabled: isListening,
              ),
              const SizedBox(width: 4),
              VoiceButton(
                onPress: stopListening,
                icon: Icons.stop,
                disabled: !isListening,
              ),
              const SizedBox(width: 4),
              VoiceButton(
                onPress: sendMessage,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
