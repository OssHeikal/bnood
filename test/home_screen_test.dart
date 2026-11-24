import 'package:bnood/core/domain/ledger/ledger_entities.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import 'package:bnood/features/home/presentation/screens/home_screen.dart';
import 'package:bnood/features/projects/data/project_list_row.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_notifier_stubs.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    HomeTotals? totals,
    List<ProjectListRow>? projects,
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
          homeActiveProjectsOverride(projects ?? const []),
          suppliers != null
              ? homeSupplierSpendsOverride(suppliers)
              : emptyHomeSupplierSpendsOverride(),
          emptyHomeCraftsmenOverride(),
          emptyHomeSuppliersOverride(),
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

  testWidgets('renders stat totals and active project card', (tester) async {
    await pumpHome(
      tester,
      totals: const HomeTotals(receivedPiastres: 100000, spentPiastres: 40000),
      projects: const [
        ProjectListRow(
          projectId: 'p1',
          projectName: 'Nile Tower',
          clientId: 'c1',
          clientName: 'Client One',
          remainingPiastres: 60000,
          receivedPiastres: 100000,
          spentPiastres: 40000,
        ),
      ],
    );

    expect(find.text('Received'), findsOneWidget);
    expect(find.text('Nile Tower'), findsOneWidget);
    expect(find.text('Client One'), findsOneWidget);
    expect(find.textContaining('New'), findsNothing);
    expect(find.textContaining('Directory'), findsNothing);
  });

  testWidgets('home header app name follows locale', (tester) async {
    const totals = HomeTotals(receivedPiastres: 0, spentPiastres: 0);
    await pumpHome(
      tester,
      locale: const Locale('en'),
      totals: totals,
      projects: const [],
    );
    expect(find.text('Bnood'), findsOneWidget);
    expect(find.text('بنود'), findsNothing);

    await pumpHome(
      tester,
      locale: const Locale('ar'),
      totals: totals,
      projects: const [],
    );
    expect(find.text('بنود'), findsOneWidget);
    expect(find.text('Bnood'), findsNothing);
  });

  testWidgets('Arabic home at 1.2 text scale', (tester) async {
    await pumpHome(
      tester,
      locale: const Locale('ar'),
      textScaler: TextScaler.linear(1.2),
      totals: const HomeTotals(receivedPiastres: 0, spentPiastres: 0),
      projects: const [],
    );

    expect(find.text('الدليل'), findsNothing);
    expect(find.text('مشاريع نشطة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('negative project remaining uses signed display', (tester) async {
    await pumpHome(
      tester,
      projects: const [
        ProjectListRow(
          projectId: 'p2',
          projectName: 'Overdrawn Site',
          clientId: 'c2',
          clientName: 'Overdrawn Co',
          remainingPiastres: -25000,
          receivedPiastres: 10000,
          spentPiastres: 35000,
        ),
      ],
      totals: const HomeTotals(receivedPiastres: 10000, spentPiastres: 35000),
    );

    expect(find.text('Overdrawn Site'), findsOneWidget);
    expect(find.textContaining('−'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('see all navigates callback wired', (tester) async {
    await pumpHome(
      tester,
      totals: const HomeTotals(receivedPiastres: 0, spentPiastres: 0),
      projects: const [],
    );

    expect(find.text('See all'), findsWidgets);
  });

  testWidgets('suppliers section is below craftsmen on remote home', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 11, 1);
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeTotalsOverride(
            const HomeTotals(receivedPiastres: 0, spentPiastres: 0),
          ),
          homeActiveProjectsOverride(const []),
          emptyHomeSupplierSpendsOverride(),
          emptyHomeCraftsmenOverride(),
          homeSuppliersProvider.overrideWith(
            () => StubHomeSuppliersNotifier([
              HomeCraftsmanActivityRow(
                craftsman: CraftsmenData(
                  id: 's1',
                  workspaceId: 'w',
                  name: 'Steel Co',
                  phone: '',
                  createdAt: now,
                  updatedAt: now,
                ),
                paidPiastres: 1_800_000,
                lastLaborAt: now,
                remainingPiastres: null,
                clientsCount: 1,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final craftsmenTitle = tester.getTopLeft(
      find.text('Craftsmen with recent labor'),
    );
    final supplierTitle = tester.getTopLeft(find.text('Suppliers'));
    expect(craftsmenTitle.dy, lessThan(supplierTitle.dy));
    expect(find.text('Steel Co'), findsOneWidget);
  });
}
