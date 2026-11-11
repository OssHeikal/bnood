import 'package:bnood/app/widgets/shell_navigation_rail.dart';
import 'package:bnood/app/widgets/shell_nav_destination.dart';
import 'package:bnood/app/widgets/shell_nav_icon.dart';
import 'package:bnood/app/widgets/shell_nav_icons.dart';
import 'package:bnood/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final destinations = [
    ShellNavDestination(icon: ShellNavIcons.home, label: 'Home', semanticsLabel: 'Home'),
    ShellNavDestination(icon: ShellNavIcons.clients, label: 'Clients', semanticsLabel: 'Clients'),
    ShellNavDestination(icon: ShellNavIcons.directory, label: 'Directory', semanticsLabel: 'Directory'),
    ShellNavDestination(icon: ShellNavIcons.items, label: 'Items', semanticsLabel: 'Items'),
  ];

  testWidgets('rail uses widened theme and larger destination icons', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Row(
            children: [
              ShellNavigationRail(
                selectedIndex: 0,
                destinations: destinations,
                voucherSemanticsLabel: 'New',
                onDestinationSelected: (_) {},
                onVoucher: () {},
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final theme = tester.widget<NavigationRailTheme>(find.byType(NavigationRailTheme));
    expect(theme.data.minWidth, ShellNavigationRail.railMinWidth);

    final icons = tester.widgetList<ShellNavIcon>(find.byType(ShellNavIcon));
    expect(
      icons.any((icon) => icon.size == ShellNavigationRail.destinationIconSize),
      isTrue,
    );

    final indicator = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(indicator.indicatorShape, isA<RoundedRectangleBorder>());
  });
}
