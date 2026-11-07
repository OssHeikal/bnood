import 'package:flutter/material.dart';

/// Semantic tokens aligned with the HTML prototype (#0D9B8A primary).
abstract final class AppColors {
  static const primary = Color(0xFF0D9B8A);
  static const primaryDark = Color(0xFF0A7A6C);
  static const success = Color(0xFF1B9E5A);
  static const danger = Color(0xFFD64545);
  static const warning = Color(0xFFE6A23C);

  static const lightBg = Color(0xFFF4F7F6);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightMuted = Color(0xFF5C6B68);
  static const lightOnSurface = Color(0xFF1A2422);

  static const darkBg = Color(0xFF121817);
  static const darkSurface = Color(0xFF1E2624);
  static const darkMuted = Color(0xFF9AA8A5);
  static const darkOnSurface = Color(0xFFE8EDEC);

  static Color accent(String key) => switch (key) {
        'teal' => primary,
        'green' => const Color(0xFF1B9E5A),
        'blue' => const Color(0xFF2B5BB0),
        'purple' => const Color(0xFF6B45C0),
        'pink' => const Color(0xFFD4569C),
        'orange' => const Color(0xFFE67E22),
        'gold' => const Color(0xFFC9A227),
        'brick' => const Color(0xFFB84A4A),
        'turquoise' => const Color(0xFF1AA89A),
        'olive' => const Color(0xFF6B8E23),
        _ => primary,
      };
}
