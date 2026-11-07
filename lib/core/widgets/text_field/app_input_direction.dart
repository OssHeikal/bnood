import 'package:flutter/material.dart';

TextDirection inferTextDirection(String text, TextDirection ambient) {
  for (final rune in text.runes) {
    if (_isStrongRtl(rune)) {
      return TextDirection.rtl;
    }
    if (_isStrongLtr(rune)) {
      return TextDirection.ltr;
    }
  }
  return ambient;
}

/// LTR copy on an RTL screen aligns to the layout start edge (physical right).
TextAlign alignTextInAmbient(String text, TextDirection ambient) {
  final content = inferTextDirection(text, ambient);
  if (ambient == TextDirection.rtl && content == TextDirection.ltr) {
    return TextAlign.right;
  }
  return TextAlign.start;
}

bool _isStrongRtl(int rune) {
  return (rune >= 0x0590 && rune <= 0x08FF) || (rune >= 0xFB1D && rune <= 0xFDFF) || (rune >= 0xFE70 && rune <= 0xFEFF);
}

bool _isStrongLtr(int rune) {
  if (rune >= 0x0041 && rune <= 0x005A) {
    return true;
  }
  if (rune >= 0x0061 && rune <= 0x007A) {
    return true;
  }
  if (rune >= 0x00C0 && rune <= 0x02FF) {
    return true;
  }
  if (rune >= 0x0370 && rune <= 0x052F) {
    return true;
  }
  return false;
}
