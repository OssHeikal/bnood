import 'package:bnood/core/widgets/text_field/app_input_formatters.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ThousandsGroupingFormatter groups integer part with commas', () {
    expect(
      ThousandsGroupingFormatter.formatDisplay('1000000', allowDecimal: false),
      '1,000,000',
    );
    expect(
      ThousandsGroupingFormatter.formatDisplay('1000000.50', allowDecimal: true),
      '1,000,000.50',
    );
  });

  test('ThousandsGroupingFormatter preserves caret after insert', () {
    const formatter = ThousandsGroupingFormatter(allowDecimal: false);
    const oldValue = TextEditingValue(text: '1,000', selection: TextSelection.collapsed(offset: 5));
    const newValue = TextEditingValue(text: '1,0000', selection: TextSelection.collapsed(offset: 6));
    final result = formatter.formatEditUpdate(oldValue, newValue);
    expect(result.text, '10,000');
    expect(result.selection.baseOffset, result.text.length);
  });
}