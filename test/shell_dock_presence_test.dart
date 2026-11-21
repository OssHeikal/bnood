import 'package:bnood/app/widgets/floating_shell_dock.dart';
import 'package:bnood/app/widgets/shell_nav_destination.dart';
import 'package:bnood/app/widgets/shell_nav_icons.dart';
import 'package:bnood/core/services/config/navigation/root_navigator_key.dart';
import 'package:bnood/core/services/config/theme/app_size.dart';
import 'package:bnood/core/ui/widgets/app_toaster.dart';
import 'package:bnood/core/ui/widgets/toast/app_toast.dart';
import 'package:bnood/core/ui/widgets/toast/shell_dock_presence.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for ShellScaffold: registers itself like the real shell does.
class _FakeShell extends StatelessWidget {
  const _FakeShell({required this.hasDock});

  final bool hasDock;

  @override
  Widget build(BuildContext context) {
    ShellDockPresence.register(context, hasDock: hasDock);
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    useRootNavigator: true,
                    builder: (sheetCtx) => TextButton(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        AppToaster.success('after-sheet');
                      },
                      child: const Text('close-and-toast'),
                    ),
                  ),
                  child: const Text('sheet'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('details')),
                    ),
                  ),
                  child: const Text('details'),
                ),
              ],
            ),
          ),
          if (hasDock)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingShellDock(
                selectedIndex: 3,
                onDestinationSelected: (_) {},
                onVoucher: () {},
                voucherSemanticsLabel: 'add',
                destinations: [
                  ShellNavDestination(
                    icon: ShellNavIcons.home,
                    label: 'Home',
                    semanticsLabel: 'Home',
                  ),
                  ShellNavDestination(
                    icon: ShellNavIcons.items,
                    label: 'Items',
                    semanticsLabel: 'Items',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// iPhone-style bottom safe area (home indicator), 34 logical px.
void _simulateHomeIndicator(WidgetTester tester) {
  final inset = FakeViewPadding(bottom: 34 * tester.view.devicePixelRatio);
  tester.view.padding = inset;
  tester.view.viewPadding = inset;
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);
}

/// Toast bottom must sit just above the real dock's top edge (small gap, not 100px up).
Future<void> expectToastJustAboveDock(WidgetTester tester) async {
  final dockTop = tester.getRect(find.byType(FloatingShellDock)).top;
  final toastBottom = tester.getRect(find.byType(AppToast)).bottom;
  final gap = dockTop - toastBottom;
  expect(
    gap,
    inInclusiveRange(AppSize.spaceXS, AppSize.spaceMD),
    reason: 'gap between toast and dock = $gap',
  );
}

void main() {
  setUp(ShellDockPresence.resetForTesting);

  Widget app({required bool hasDock, bool useRootKey = true}) {
    return MaterialApp(
      navigatorKey: useRootKey ? rootNavigatorKey : null,
      builder: BotToastInit(),
      navigatorObservers: [
        BotToastNavigatorObserver(),
        ShellDockPresence.createObserver(),
      ],
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeFoundationScope(child: _FakeShell(hasDock: hasDock)),
    );
  }

  testWidgets('dock stays visible under sheets and hides under pushed pages', (
    tester,
  ) async {
    await tester.pumpWidget(app(hasDock: true));
    expect(ShellDockPresence.visible, isTrue);

    await tester.tap(find.text('sheet'));
    await tester.pumpAndSettle();
    expect(
      ShellDockPresence.visible,
      isTrue,
      reason: 'popup route keeps the dock underneath',
    );

    await tester.tap(find.text('close-and-toast'));
    expect(
      ShellDockPresence.visible,
      isTrue,
      reason: 'resolved at show time, right after pop',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('details'));
    await tester.pumpAndSettle();
    expect(
      ShellDockPresence.visible,
      isFalse,
      reason: 'full page covers the dock',
    );

    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    expect(ShellDockPresence.visible, isTrue);
    AppToaster.clear();
    await tester.pumpAndSettle();
  });

  testWidgets('desktop shell without dock never reserves clearance', (
    tester,
  ) async {
    await tester.pumpWidget(app(hasDock: false));
    expect(ShellDockPresence.visible, isFalse);
  });

  testWidgets('toast fired as a sheet closes sits just above the dock', (
    tester,
  ) async {
    _simulateHomeIndicator(tester);
    await tester.pumpWidget(app(hasDock: true));
    await tester.tap(find.text('sheet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('close-and-toast'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await expectToastJustAboveDock(tester);

    AppToaster.clear();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'toast keeps dock clearance even without the root navigator key',
    (tester) async {
      _simulateHomeIndicator(tester);
      await tester.pumpWidget(app(hasDock: true, useRootKey: false));
      await tester.tap(find.text('sheet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('close-and-toast'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await expectToastJustAboveDock(tester);

      AppToaster.clear();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('pushed details page (no dock) uses safe area + standard gap', (
    tester,
  ) async {
    _simulateHomeIndicator(tester);
    await tester.pumpWidget(app(hasDock: true));
    await tester.tap(find.text('details'));
    await tester.pumpAndSettle();
    AppToaster.success('on-details');
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final screen = tester.getRect(find.byType(MaterialApp).first);
    final toastBottom = tester.getRect(find.byType(AppToast)).bottom;
    expect(screen.bottom - toastBottom, moreOrLessEquals(34 + AppSize.spaceMD));
    AppToaster.clear();
    await tester.pumpAndSettle();
  });
}
