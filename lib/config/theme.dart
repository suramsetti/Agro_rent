import 'package:flutter/material.dart';

ThemeData buildAgroTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green.shade700,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
}

