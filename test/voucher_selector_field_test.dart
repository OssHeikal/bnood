import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/vouchers/voucher_selector_field.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selector field rebuild shows updated value under floated label', (tester) async {
    var value = 'Osama';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: VoucherSelectorField(
                label: 'العملاء',
                value: value,
                placeholder: 'اختر العميل',
                onTap: () => setState(() => value = 'Ahmed'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Osama'), findsOneWidget);

    await tester.tap(find.text('Osama'));
    await tester.pumpAndSettle();
    expect(find.text('Ahmed'), findsOneWidget);
    expect(find.text('اختر العميل'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
