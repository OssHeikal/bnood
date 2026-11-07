import 'package:flutter/material.dart';

/// Feature accent ramp for tinted cards: 50 fill, 100 border, ink for icons.
class AppAccent {
  const AppAccent({required this.tint, required this.border, required this.ink});

  final Color tint;
  final Color border;
  final Color ink;

  LinearGradient cardGradient(Color surface) {
    return LinearGradient(
      begin: const AlignmentDirectional(-0.9, -1),
      end: const AlignmentDirectional(0.9, 1),
      colors: [surface, tint],
      stops: const [0.0609, 0.9304],
    );
  }
}
