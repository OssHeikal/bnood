import 'package:flutter/services.dart';

import '../../../domain/formatting/display_digits.dart';
import 'app_input_type.dart';

List<TextInputFormatter> buildAppInputFormatters(
  AppInputType type, {
  List<TextInputFormatter>? formatters,
  int? maxLength,
  AppInputCounterPolicy policy = AppInputCounterPolicy.hard,
  bool allowNegative = false,
  int maxDecimalPlaces = 2,
  num? minValue,
  num? maxValue,
  bool groupThousands = false,
}) {
  final result = <TextInputFormatter>[...?formatters];
  switch (type) {
    case AppInputType.email:
    case AppInputType.url:
      result.add(FilteringTextInputFormatter.deny(RegExp(r'\s')));
    case AppInputType.phone:
      result.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() ]')));
    case AppInputType.number:
    case AppInputType.currency:
    case AppInputType.percentage:
      result.add(
        _NumberFormatter(
          allowDecimal: true,
          allowNegative: allowNegative,
          maxDecimalPlaces: maxDecimalPlaces,
          minValue: minValue,
          maxValue: maxValue,
        ),
      );
      if (type == AppInputType.currency) {
        result.add(const ThousandsGroupingFormatter(allowDecimal: true));
      }
    case AppInputType.integer:
      result.add(
        _NumberFormatter(
          allowDecimal: false,
          allowNegative: allowNegative,
          maxDecimalPlaces: 0,
          minValue: minValue,
          maxValue: maxValue,
        ),
      );
      if (groupThousands) {
        result.add(const ThousandsGroupingFormatter(allowDecimal: false));
      }
    case AppInputType.text:
    case AppInputType.password:
    case AppInputType.multiline:
    case AppInputType.search:
      break;
  }
  if (type != AppInputType.multiline) {
    result.add(FilteringTextInputFormatter.deny(RegExp(r'\n')));
  }
  if (maxLength != null && policy == AppInputCounterPolicy.hard) {
    result.add(LengthLimitingTextInputFormatter(maxLength));
  }
  return result;
}

String cleanAppInputValue(String value, AppInputType type) {
  if (!type.isNumeric) {
    return value;
  }
  return value.replaceAll(',', '').replaceAll(' ', '');
}

class _NumberFormatter extends TextInputFormatter {
  const _NumberFormatter({
    required this.allowDecimal,
    required this.allowNegative,
    required this.maxDecimalPlaces,
    required this.minValue,
    required this.maxValue,
  });

  final bool allowDecimal;
  final bool allowNegative;
  final int maxDecimalPlaces;
  final num? minValue;
  final num? maxValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = cleanAppInputValue(newValue.text, AppInputType.number);
    if (cleaned.isEmpty || _isPartial(cleaned)) {
      return _matches(cleaned) ? newValue : oldValue;
    }
    if (!_matches(cleaned)) {
      return oldValue;
    }
    final value = num.tryParse(cleaned);
    if (value == null) {
      return oldValue;
    }
    if (maxValue != null && value > maxValue!) {
      return oldValue;
    }
    if (minValue != null && value < minValue! && _cannotReachMin(cleaned)) {
      return oldValue;
    }
    return newValue;
  }

  bool _isPartial(String cleaned) {
    return cleaned == '-' ||
        cleaned == '.' ||
        cleaned == '-.' ||
        cleaned.endsWith('.');
  }

  bool _matches(String cleaned) {
    final sign = allowNegative ? '-?' : '';
    final body = allowDecimal ? '\\d*\\.?\\d{0,$maxDecimalPlaces}' : '\\d*';
    return RegExp('^$sign$body\$').hasMatch(cleaned);
  }

  bool _cannotReachMin(String cleaned) {
    final minDigits = minValue!.abs().truncate().toString().length;
    final intPart = cleaned.replaceAll('-', '').split('.').first;
    return intPart.length >= minDigits;
  }
}

/// Inserts `,` group separators into numeric input; keeps selection stable.
class ThousandsGroupingFormatter extends TextInputFormatter {
  const ThousandsGroupingFormatter({required this.allowDecimal});

  final bool allowDecimal;

  static String formatDisplay(String raw, {required bool allowDecimal}) {
    if (raw.isEmpty) return raw;
    final western = DisplayDigits.toWesternDigits(
      raw.replaceAll(',', '').replaceAll(' ', ''),
    );
    if (western.isEmpty) return western;

    var negative = false;
    var body = western;
    if (body.startsWith('-') || body.startsWith('−')) {
      negative = true;
      body = body.substring(1);
    }

    String frac = '';
    if (allowDecimal) {
      final dot = body.indexOf('.');
      if (dot >= 0) {
        frac = body.substring(dot);
        body = body.substring(0, dot);
      }
    }

    body = body.replaceAll(RegExp(r'[^0-9]'), '');
    if (body.isEmpty && frac.isEmpty) {
      return negative ? '-' : '';
    }

    final grouped = _groupDigits(body);
    final out = '${negative ? '-' : ''}$grouped$frac';
    return out;
  }

  static String _groupDigits(String digits) {
    if (digits.isEmpty) return digits;
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  static int _significantCountBefore(String text, int offset) {
    final end = offset.clamp(0, text.length);
    var count = 0;
    for (var i = 0; i < end; i++) {
      final c = text[i];
      if (c == ',' || c == ' ') continue;
      if (RegExp(r'[0-9.\-−]').hasMatch(c)) count++;
    }
    return count;
  }

  static int _offsetForSignificantCount(String formatted, int sigCount) {
    if (sigCount <= 0) return 0;
    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      final c = formatted[i];
      if (c == ',' || c == ' ') continue;
      if (RegExp(r'[0-9.\-−]').hasMatch(c)) {
        seen++;
        if (seen == sigCount) return i + 1;
      }
    }
    return formatted.length;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    final formatted = formatDisplay(raw, allowDecimal: allowDecimal);
    final baseSig = _significantCountBefore(
      newValue.text,
      newValue.selection.baseOffset,
    );
    final extentSig = _significantCountBefore(
      newValue.text,
      newValue.selection.extentOffset,
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection(
        baseOffset: _offsetForSignificantCount(formatted, baseSig),
        extentOffset: _offsetForSignificantCount(formatted, extentSig),
      ),
      composing: TextRange.empty,
    );
  }
}
