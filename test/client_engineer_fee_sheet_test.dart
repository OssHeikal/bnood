import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/features/clients/presentation/sheets/engineer_edit_sheet.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('engineer fee sheet validates percent and shows caption', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showEngineerFeeSheet(
                    context: context,
                    clientId: 'c1',
                    projectId: 'p1',
                    clientName: 'Tower',
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Profit percentage'), findsWidgets);
    expect(find.text('Tower'), findsOneWidget);
    expect(find.textContaining('Estimated internal profit'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '150');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter 0–100 or leave blank'), findsOneWidget);
  });
}
