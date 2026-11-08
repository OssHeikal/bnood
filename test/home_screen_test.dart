import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/widgets/app_amount.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/home/home_screen.dart';
import 'package:bnood/features/home/widgets/home_person_card.dart';
import 'support/home_notifier_stubs.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    HomeTotals? totals,
    List<HomeClientBalanceRow>? clients,
    List<HomeSupplierSpendRow>? suppliers,
    Locale locale = const Locale('en'),
    TextScaler textScaler = TextScaler.noScaling,
    Size surface = const Size(390, 844),
  }) async {
    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (totals != null) homeTotalsOverride(totals),
          if (clients != null) homeClientBalancesOverride(clients),
          suppliers != null
              ? homeSupplierSpendsOverride(suppliers)
              : emptyHomeSupplierSpendsOverride(),
          emptyHomeCraftsmenOverride(),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(textScaler: textScaler),
            child: const HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders stat totals and active client card', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    await pumpHome(
      tester,
      totals: const HomeTotals(receivedPiastres: 100000, spentPiastres: 40000),
      clients: [
        HomeClientBalanceRow(
          client: Client(
            id: 'c1',
            workspaceId: 'w',
            name: 'Nile Tower',
            phone: '01000000000',
            createdAt: now,
            updatedAt: now,
          ),
          remainingPiastres: 60000,
          receivedPiastres: 100000,
          spentPiastres: 40000,
        ),
      ],
    );

    expect(find.text('Received'), findsOneWidget);
    expect(find.text('Nile Tower'), findsOneWidget);
    expect(find.textContaining('New'), findsNothing);
    expect(find.textContaining('Directory'), findsNothing);
  });

  testWidgets('home header app name follows locale', (tester) async {
    const totals = HomeTotals(receivedPiastres: 0, spentPiastres: 0);
    await pumpHome(tester, locale: const Locale('en'), totals: totals, clients: const []);
    expect(find.text('Bnood'), findsOneWidget);
    expect(find.text('بنود'), findsNothing);

    await pumpHome(tester, locale: const Locale('ar'), totals: totals, clients: const []);
    expect(find.text('بنود'), findsOneWidget);
    expect(find.text('Bnood'), findsNothing);
  });

  testWidgets('Arabic home at 1.2 text scale', (tester) async {
    await pumpHome(
      tester,
      locale: const Locale('ar'),
      textScaler: TextScaler.linear(1.2),
      totals: const HomeTotals(receivedPiastres: 0, spentPiastres: 0),
      clients: const [],
    );

    expect(find.text('الدليل'), findsNothing);
    expect(find.textContaining('للعملاء الناشطين'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('negative client remaining uses signed display', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    await pumpHome(
      tester,
      clients: [
        HomeClientBalanceRow(
          client: Client(
            id: 'c2',
            workspaceId: 'w',
            name: 'Overdrawn Co',
            phone: null,
            createdAt: now,
            updatedAt: now,
          ),
          remainingPiastres: -25000,
          receivedPiastres: 10000,
          spentPiastres: 35000,
        ),
      ],
      totals: const HomeTotals(receivedPiastres: 10000, spentPiastres: 35000),
    );

    expect(find.text('Overdrawn Co'), findsOneWidget);
    expect(find.textContaining('−'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('see all navigates callback wired', (tester) async {
    await pumpHome(
      tester,
      totals: const HomeTotals(receivedPiastres: 0, spentPiastres: 0),
      clients: const [],
    );

    expect(find.text('See all'), findsWidgets);
  });

  testWidgets('supplier spend is last and shows the amount without a label', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    await pumpHome(
      tester,
      totals: const HomeTotals(receivedPiastres: 0, spentPiastres: 0),
      clients: const [],
      surface: const Size(390, 1400),
      suppliers: [
        HomeSupplierSpendRow(
          supplier: Supplier(
            id: 's1',
            workspaceId: 'w',
            name: 'Steel Co',
            createdAt: now,
            updatedAt: now,
          ),
          spentPiastres: 1800000,
        ),
      ],
    );

    final craftsmenTitle = tester.getTopLeft(find.text('Craftsmen with recent labor'));
    final supplierTitle = tester.getTopLeft(find.text('Supplier material spend'));
    expect(craftsmenTitle.dy, lessThan(supplierTitle.dy));

    final card = find.widgetWithText(HomePersonCard, 'Steel Co');
    expect(find.descendant(of: card, matching: find.text('Paid')), findsNothing);
    expect(find.descendant(of: card, matching: find.text('Remaining')), findsNothing);
    expect(find.descendant(of: card, matching: find.text('Active clients only')), findsNothing);
    expect(find.descendant(of: card, matching: find.byType(AppAmount)), findsOneWidget);
  });
}
