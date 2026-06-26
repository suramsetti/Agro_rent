import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.check),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }
}

