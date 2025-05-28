import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String sender;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.sender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final parts = text.split('\n📄 Archivo:');
    final mainText = parts[0];
    final pdfName = parts.length > 1 ? parts[1] : null;

    final isUser = sender == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFDFF8C6) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mainText,
              style: const TextStyle(fontSize: 16),
            ),
            if (pdfName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '📄 Archivo:$pdfName',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
