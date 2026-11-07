import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/features/home/home_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'support/home_notifier_stubs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('initial load skeleton then silent refresh keeps content visible', (tester) async {
    final totalsNotifier = SequencedHomeTotalsNotifier(const [
      HomeTotals(receivedPiastres: 10000, spentPiastres: 0),
      HomeTotals(receivedPiastres: 25000, spentPiastres: 0),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeTotalsProvider.overrideWith(() => totalsNotifier),
          homeClientBalancesOverride(const []),
          emptyHomeSupplierSpendsOverride(),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );

    expect(find.byType(Skeleton), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byType(Skeleton), findsNothing);
    expect(find.text('Received'), findsOneWidget);

    final refresh = totalsNotifier.refreshSilently();
    await tester.pump();
    expect(find.byType(Skeleton), findsNothing);

    await refresh;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(Skeleton), findsNothing);
  });

  testWidgets('failed silent refresh retains previous totals', (tester) async {
    final totalsNotifier = ThrowingHomeTotalsNotifier(
      first: const HomeTotals(receivedPiastres: 50000, spentPiastres: 10000),
      failNext: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeTotalsProvider.overrideWith(() => totalsNotifier),
          homeClientBalancesOverride(const []),
          emptyHomeSupplierSpendsOverride(),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Received'), findsOneWidget);

    await totalsNotifier.refreshSilently();
    await tester.pumpAndSettle();

    expect(find.text('Received'), findsOneWidget);
    expect(find.byType(Skeleton), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
