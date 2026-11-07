import 'package:bnood/core/config/theme/app_motion.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/entity_picker_page.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('entity picker search filters compact list', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const EntityPickerPage(
          title: 'Clients',
          entries: [
            ('a', 'Alpha Co'),
            ('b', 'Beta Studio'),
            ('c', 'Gamma LLC'),
          ],
          onCreateRoute: _FakeCreate.new,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Alpha Co'), findsOneWidget);
    expect(find.text('Beta Studio'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'beta');
    await tester.pump(AppMotion.searchDebounce);
    await tester.pumpAndSettle();

    expect(find.text('Beta Studio'), findsOneWidget);
    expect(find.text('Alpha Co'), findsNothing);
    expect(find.text('No matches'), findsNothing);
  });

  testWidgets('entity picker no search hits shows fallback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const EntityPickerPage(
          title: 'Items',
          entries: [('a', 'Alpha')],
          onCreateRoute: _FakeCreate.new,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump(AppMotion.searchDebounce);
    await tester.pumpAndSettle();
    expect(find.text('No matches'), findsOneWidget);
    expect(find.text('Create new'), findsOneWidget);
  });
}

class _FakeCreate extends StatelessWidget {
  const _FakeCreate();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
