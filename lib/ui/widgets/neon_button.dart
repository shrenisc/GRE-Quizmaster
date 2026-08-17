import 'package:flutter/material.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color neonColor; // We'll keep the prop name for compatibility, but it will act as the button color.

  const NeonButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.neonColor = const Color(0xFF111827), // Default to dark gray/black
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? neonColor : Colors.grey.shade300,
          foregroundColor: isEnabled ? Colors.white : Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
