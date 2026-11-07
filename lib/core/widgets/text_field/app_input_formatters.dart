import 'package:flutter/services.dart';

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
