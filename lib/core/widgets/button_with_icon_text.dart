import 'package:flutter/material.dart';

class ButtonWithIconText extends StatelessWidget {

  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String text;

  const ButtonWithIconText({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.backgroundColor = Colors.black12,
    this.foregroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: foregroundColor),
      label: Text(text, style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    );
  }
}