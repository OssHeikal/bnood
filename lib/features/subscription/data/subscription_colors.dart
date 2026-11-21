import 'package:flutter/material.dart';

/// Bnood Premium / paywall violet (matches owner HTML mock).
abstract final class SubscriptionColors {
  static const violet = Color(0xFF6D28D9);
  static const violetDark = Color(0xFF5B21B6);
  static const violetSoft = Color(0xFFF4EBFF);
  static const paywallCanvas = Color(0xFFF7F4FA);
  static const paywallGradientTop = Color(0xFFEBE2FF);
  static const planIdle = Color(0xFFF1EEF3);
  static const onViolet = Color(0xFFFFFFFF);

  static Color parsePremiumAvatar(String? raw) {
    if (raw == null || raw.trim().isEmpty) return violet;
    final trimmed = raw.trim();
    if (trimmed.startsWith('#')) {
      final hex = trimmed.substring(1);
      final value = int.tryParse(hex.length <= 6 ? hex.padLeft(6, '0') : hex, radix: 16);
      if (value != null) return Color(0xFF000000 | value);
    }
    return violet;
  }
}
