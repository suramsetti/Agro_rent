import 'package:flutter/material.dart';

class DriverBadge extends StatelessWidget {
  const DriverBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.verified, color: Colors.green, size: 18),
      label: const Text('Verified Driver'),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.green.shade200),
      ),
      backgroundColor: Colors.green.shade50,
    );
  }
}

