import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/money/money_format.dart';
import 'package:bnood/core/widgets/custom_text_field.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAmountField(WidgetTester tester, Locale locale) async {
    final controller = TextEditingController(text: '1000');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CustomTextField(
            controller: controller,
            label: locale.languageCode == 'ar' ? 'المبلغ' : 'Amount',
            type: AppInputType.currency,
            ltrValue: true,
            suffix: Text(MoneyFormat.currencyLabel),
            clearable: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('currency field keeps ambient text direction in Arabic', (tester) async {
    await pumpAmountField(tester, const Locale('ar'));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.textDirection, TextDirection.rtl);
    expect(field.textAlign, TextAlign.start);
  });

  testWidgets('currency field uses LTR ambient direction in English', (tester) async {
    await pumpAmountField(tester, const Locale('en'));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.textDirection, TextDirection.ltr);
    expect(field.textAlign, TextAlign.start);
  });
}
