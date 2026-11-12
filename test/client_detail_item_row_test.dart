import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/money/ledger_math.dart';
import 'package:bnood/core/money/remote_money_units.dart';
import 'package:bnood/features/clients/widgets/client_detail_item_row.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('item row shows materials and labor split at remote scale', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: ClientDetailItemRow(
            itemName: 'Plumbing',
            colorKey: 'cyan',
            iconName: 'category',
            breakdown: const ItemExpenseBreakdown(
              materialsPiastres: 1_000_000,
              laborPiastres: 300_000,
            ),
            localeCode: 'en',
            minorPerMajor: RemoteMoneyUnits.minorPerMajor,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Materials'), findsOneWidget);
    expect(find.text('Labor'), findsOneWidget);
    expect(find.textContaining('10,000'), findsWidgets);
    expect(find.textContaining('3,000'), findsWidgets);
    expect(find.textContaining('13,000'), findsOneWidget);
  });
}
