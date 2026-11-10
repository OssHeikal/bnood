import 'package:bnood/core/clients/client_statement_record.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/clients/client_movements_filters.dart';
import 'package:bnood/features/clients/widgets/client_movements_filter_sheets.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sort sheet closes after selection without navigator assert', (tester) async {
    ClientMovementsSort? result;

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
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showMovementsSortSheet(
                      context,
                      current: ClientMovementsSort.dateDesc,
                    );
                  },
                  child: const Text('Open sort'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sort'));
    await tester.pumpAndSettle();

    expect(find.text('Sort'), findsOneWidget);
    await tester.tap(find.text('Oldest'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Sort'), findsNothing);
    expect(result, ClientMovementsSort.dateAsc);
  });

  testWidgets('item sheet shows semantic icon and closes on pick', (tester) async {
    MovementsItemPickResult? result;

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
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showMovementsItemSheet(
                      context,
                      items: const [
                        AppClientStatementItemSpend(
                          id: 'i-plumb',
                          name: 'Plumbing',
                          spentMinor: 0,
                          materialsMinor: 0,
                          laborMinor: 0,
                          colorKey: 'teal',
                          iconKey: 'plumbing',
                        ),
                      ],
                    );
                  },
                  child: const Text('Open item'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open item'));
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsWidgets);
    await tester.tap(find.text('Plumbing'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Item'), findsNothing);
    expect(result?.itemId, 'i-plumb');
    expect(result?.itemName, 'Plumbing');
  });

  testWidgets('item sheet shows empty state when list is empty', (tester) async {
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
                child: ElevatedButton(
                  onPressed: () => showMovementsItemSheet(context, items: const []),
                  child: const Text('Open item'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open item'));
    await tester.pumpAndSettle();

    expect(find.text('No item spend recorded yet'), findsOneWidget);
  });

  testWidgets('date sheet opens voucher date picker', (tester) async {
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
                child: ElevatedButton(
                  onPressed: () => showMovementsDateSheet(context),
                  child: const Text('Open date'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open date'));
    await tester.pumpAndSettle();

    expect(find.text('From'), findsOneWidget);
    await tester.tap(find.text('From'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('voucher-date-confirm')), findsOneWidget);
  });
}
