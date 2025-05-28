import 'package:flutter/material.dart';

class VoiceButton extends StatelessWidget {
  final VoidCallback onPress;
  final IconData icon;
  final bool disabled;
  final Color color;

  const VoiceButton({
    Key? key,
    required this.onPress,
    required this.icon,
    this.disabled = false,
    this.color = const Color(0xFFFF5733), // Color por defecto
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: IconButton(
          icon: Icon(icon, size: 24, color: disabled ? Colors.grey.shade800 : color),
          onPressed: disabled ? null : onPress,
          padding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}
