import 'package:bnood/core/formatting/display_digits.dart';
import 'package:bnood/core/money/money_format.dart';
import 'package:bnood/core/widgets/app_amount.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MoneyFormat ar uses western digits', () {
    final text = MoneyFormat.formatPiastres(1_234_567, locale: 'ar_EG');
    expect(text, contains('12,345.67'));
    expect(text, contains('EGP'));
    expect(text, isNot(contains('ج.م')));
    expect(text, isNot(contains('١')));
  });

  test('parseEgpInput accepts eastern arabic digits', () {
    expect(MoneyFormat.parseEgpInput('١٢٣٤.٥٠'), 123450);
  });

  test('AppAmount remaining negative ar keeps minus and western digits', () async {
    final text = AppAmount.format(piastres: 5000, localeCode: 'ar');
    expect(text, contains('50'));
    expect(text, contains('EGP'));
    expect(text, isNot(contains('ج.م')));
    expect(text, isNot(contains('٥')));

    final negativeDisplay = '−${MoneyFormat.formatPiastres(12500, locale: 'ar_EG')}';
    expect(negativeDisplay, startsWith('−'));
    expect(negativeDisplay, contains('125'));
  });

  test('formatInteger uses comma grouping', () {
    expect(DisplayDigits.formatInteger(1000), '1,000');
  });

  testWidgets('AppAmount widget ar locale shows western digits', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        home: const Scaffold(
          body: AppAmount(piastres: 990000, role: AppAmountRole.remaining, localeCode: 'ar'),
        ),
      ),
    );
    await tester.pump();
    final data = tester.widget<Text>(find.byType(Text)).data!;
    expect(data, contains('9,900'));
    expect(data, isNot(contains('٩')));
  });
}
