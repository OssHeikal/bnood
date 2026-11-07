import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/clients/engineer_edit_sheet.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('engineer fee sheet validates percent and shows caption', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: HomeFoundationScope(
            child: EngineerFeeSheet(clientId: 'c1', projectId: 'p1', clientName: 'Tower', engineerBasisPoints: null),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Profit percentage'), findsWidgets);
    expect(find.text('Tower'), findsOneWidget);
    expect(find.textContaining('Estimated internal profit'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '150');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter 0–100 or leave blank'), findsOneWidget);
  });
}
