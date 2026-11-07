import 'package:bnood/app/widgets/floating_shell_dock.dart';
import 'package:bnood/app/widgets/shell_nav_destination.dart';
import 'package:bnood/app/widgets/shell_nav_icons.dart';
import 'package:bnood/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final destinations = [
    ShellNavDestination(icon: ShellNavIcons.home, label: 'Home', semanticsLabel: 'Home'),
    ShellNavDestination(icon: ShellNavIcons.clients, label: 'Clients', semanticsLabel: 'Clients'),
    ShellNavDestination(
      icon: ShellNavIcons.directory,
      label: 'Directory',
      semanticsLabel: 'Directory',
    ),
    ShellNavDestination(icon: ShellNavIcons.items, label: 'Items', semanticsLabel: 'Items'),
  ];

  Future<void> pumpDock(
    WidgetTester tester, {
    required Brightness brightness,
    required TextDirection direction,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 140));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: brightness,
          scaffoldBackgroundColor: brightness == Brightness.dark ? AppColors.darkBg : AppColors.lightBg,
        ),
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 140)),
          child: Directionality(
            textDirection: direction,
            child: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingShellDock(
                  selectedIndex: 0,
                  destinations: destinations,
                  voucherSemanticsLabel: 'New',
                  onDestinationSelected: _noopIndex,
                  onVoucher: _noop,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('nav dock light LTR golden', (tester) async {
    await pumpDock(tester, brightness: Brightness.light, direction: TextDirection.ltr);
    await expectLater(
      find.byType(FloatingShellDock),
      matchesGoldenFile('goldens/nav_dock_light_ltr.png'),
    );
  });

  testWidgets('nav dock dark LTR golden', (tester) async {
    await pumpDock(tester, brightness: Brightness.dark, direction: TextDirection.ltr);
    await expectLater(
      find.byType(FloatingShellDock),
      matchesGoldenFile('goldens/nav_dock_dark_ltr.png'),
    );
  });

  testWidgets('nav dock light RTL golden', (tester) async {
    await pumpDock(tester, brightness: Brightness.light, direction: TextDirection.rtl);
    await expectLater(
      find.byType(FloatingShellDock),
      matchesGoldenFile('goldens/nav_dock_light_rtl.png'),
    );
  });

  testWidgets('nav dock dark RTL golden', (tester) async {
    await pumpDock(tester, brightness: Brightness.dark, direction: TextDirection.rtl);
    await expectLater(
      find.byType(FloatingShellDock),
      matchesGoldenFile('goldens/nav_dock_dark_rtl.png'),
    );
  });
}

void _noopIndex(int _) {}

void _noop() {}
