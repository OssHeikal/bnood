import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_keyboard_scope.dart';
import 'package:bnood/core/widgets/bnood_modal_sheet.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('barrier tap dismisses BnoodModalSheet under AppKeyboardScope', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppKeyboardScope(
          child: HomeFoundationScope(
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => BnoodModalSheet.show<void>(
                      context: context,
                      builder: (_) => const Padding(
                        padding: EdgeInsets.all(24),
                        child: TextField(decoration: InputDecoration(labelText: 'Name')),
                      ),
                    ),
                    child: const Text('open'),
                  ),
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
    expect(find.byType(TextField), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
  });
}