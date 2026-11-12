import 'package:bnood/app/shell_scaffold.dart';
import 'package:bnood/app/widgets/floating_shell_dock.dart';
import 'package:bnood/app/widgets/shell_navigation_rail.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/layout/bnood_breakpoints.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/vouchers/voucher_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

void _setSurface(WidgetTester tester, double width) {
  tester.binding.window.physicalSizeTestValue = Size(width, 900);
  tester.binding.window.devicePixelRatioTestValue = 1.0;
  addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
}

Widget _shellApp({
  required GoRouter router,
  required double width,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    child: MaterialApp.router(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(size: Size(width, 900)),
          child: ResponsiveBreakpoints.builder(
            breakpoints: BnoodBreakpoints.all,
            child: child!,
          ),
        );
      },
      routerConfig: router,
    ),
  );
}

GoRouter _testShellRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (_, state) => NoTransitionPage(key: state.pageKey, child: const Text('home-body')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clients',
                pageBuilder: (_, state) => NoTransitionPage(key: state.pageKey, child: const Text('clients-body')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/directory',
                pageBuilder: (_, state) => NoTransitionPage(key: state.pageKey, child: const Text('directory-body')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/items',
                pageBuilder: (_, state) => NoTransitionPage(key: state.pageKey, child: const Text('items-body')),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: VoucherScreen.path, builder: (_, __) => const VoucherScreen()),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BnoodRepository repo;

  setUp(() {
    final db = openTestDatabase();
    repo = BnoodRepository(db);
    addTearDown(db.close);
  });

  for (final locale in [const Locale('en'), const Locale('ar')]) {
    final dir = locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
    final clientsLabel = locale.languageCode == 'ar' ? 'العملاء' : 'Clients';

    for (final width in [390.0, 820.0]) {
      testWidgets('dock only at $width (${locale.languageCode})', (tester) async {
        _setSurface(tester, width);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [repositoryProvider.overrideWithValue(repo)],
            child: _shellApp(router: _testShellRouter(), width: width, locale: locale),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FloatingShellDock), findsOneWidget);
        expect(find.byType(ShellNavigationRail), findsNothing);
        expect(find.byType(NavigationRail), findsNothing);

        final direction = tester.widget<Directionality>(find.byType(Directionality).first);
        expect(direction.textDirection, dir);
      });
    }

    testWidgets('rail at 1280 (${locale.languageCode})', (tester) async {
      _setSurface(tester, 1280);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [repositoryProvider.overrideWithValue(repo)],
          child: _shellApp(router: _testShellRouter(), width: 1280, locale: locale),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingShellDock), findsNothing);
      expect(find.byType(ShellNavigationRail), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
      final railTheme = tester.widget<NavigationRailTheme>(find.byType(NavigationRailTheme));
      expect(railTheme.data.minWidth, ShellNavigationRail.railMinWidth);
      expect(find.text('home-body'), findsOneWidget);

      final voucher = find.byKey(ShellNavigationRail.voucherButtonKey);
      expect(voucher, findsOneWidget);

      final rail = tester.getRect(find.byType(NavigationRail));
      final voucherRect = tester.getRect(voucher);
      expect(voucherRect.top, lessThan(rail.top + rail.height * 0.35));

      if (dir == TextDirection.ltr) {
        expect(rail.left, lessThan(120));
      } else {
        expect(rail.right, greaterThan(1160));
      }

      await tester.tap(find.text(clientsLabel));
      await tester.pumpAndSettle();
      expect(find.text('clients-body'), findsOneWidget);

      await tester.tap(find.byKey(ShellNavigationRail.voucherButtonKey));
      await tester.pumpAndSettle();
      expect(find.byType(VoucherScreen), findsOneWidget);
    });
  }

  testWidgets('mobile shell reserves dock clearance', (tester) async {
    _setSurface(tester, 390);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: _shellApp(router: _testShellRouter(), width: 390),
      ),
    );
    await tester.pumpAndSettle();

    final padded = tester.widgetList<MediaQuery>(
      find.descendant(of: find.byType(ShellScaffold), matching: find.byType(MediaQuery)),
    );
    expect(
      padded.any((mq) => mq.data.padding.bottom >= FloatingShellDock.clearanceHeight),
      isTrue,
    );
  });

  testWidgets('desktop shell does not reserve dock clearance', (tester) async {
    _setSurface(tester, 1280);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: _shellApp(router: _testShellRouter(), width: 1280),
      ),
    );
    await tester.pumpAndSettle();

    final padded = tester.widgetList<MediaQuery>(
      find.descendant(of: find.byType(ShellScaffold), matching: find.byType(MediaQuery)),
    );
    expect(
      padded.any((mq) => mq.data.padding.bottom >= FloatingShellDock.clearanceHeight),
      isFalse,
    );
  });
}
