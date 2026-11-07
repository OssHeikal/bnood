import 'package:bnood/app/widgets/floating_shell_dock.dart';
import 'package:bnood/app/widgets/shell_nav_destination.dart';
import 'package:bnood/app/widgets/shell_nav_icons.dart';
import 'package:bnood/core/config/theme/app_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final destinations = [
    ShellNavDestination(icon: ShellNavIcons.home, label: 'Home', semanticsLabel: 'Home'),
    ShellNavDestination(icon: ShellNavIcons.clients, label: 'Clients', semanticsLabel: 'Clients'),
    ShellNavDestination(icon: ShellNavIcons.directory, label: 'Directory', semanticsLabel: 'Directory'),
    ShellNavDestination(icon: ShellNavIcons.items, label: 'Items', semanticsLabel: 'Items'),
  ];

  Widget dock({
    required int selected,
    void Function(int)? onTab,
    void Function()? onVoucher,
    TextScaler textScaler = TextScaler.noScaling,
    TextDirection direction = TextDirection.ltr,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: FloatingShellDock(
              selectedIndex: selected,
              destinations: destinations,
              voucherSemanticsLabel: 'New voucher',
              onDestinationSelected: onTab ?? (_) {},
              onVoucher: onVoucher ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('four tabs and voucher satellite', (tester) async {
    var tab = 0;
    var voucher = 0;
    await tester.pumpWidget(dock(selected: 0, onTab: (_) => tab++, onVoucher: () => voucher++));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Items'), findsOneWidget);
    expect(find.byType(FloatingShellDock), findsOneWidget);

    final voucherHit = tester.getSize(find.bySemanticsLabel('New voucher'));
    expect(voucherHit.width, FloatingShellDock.pillTrackExtent);
    expect(voucherHit.height, FloatingShellDock.pillTrackExtent);

    final materials = tester.widgetList<Material>(
      find.descendant(of: find.byType(FloatingShellDock), matching: find.byType(Material)),
    );
    final pill = materials.firstWhere((m) => m.shape is StadiumBorder);
    final pillBox = tester.getSize(find.descendant(of: find.byWidget(pill), matching: find.byType(SizedBox)).first);
    expect(pillBox.height, FloatingShellDock.pillTrackExtent);
    expect(FloatingShellDock.voucherDiscDiameter, lessThan(FloatingShellDock.pillTrackExtent));

    await tester.tap(find.bySemanticsLabel('New voucher'));
    await tester.pump();
    expect(voucher, 1);

    await tester.tap(find.text('Clients'));
    await tester.pump();
    expect(tab, 1);
  });

  testWidgets('selected tab shows teal cell fill', (tester) async {
    await tester.pumpWidget(dock(selected: 0));
    await tester.pumpAndSettle();

    final containers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(
      containers.any((c) => c.decoration is BoxDecoration && (c.decoration! as BoxDecoration).color != null),
      isTrue,
    );

    await tester.pumpWidget(dock(selected: 1));
    await tester.pumpAndSettle();

    final fills = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .map((c) => (c.decoration as BoxDecoration?)?.color)
        .whereType<Color>()
        .where((c) => c.a > 0)
        .toList();
    expect(fills.length, 1);
  });

  testWidgets('selected tab has selected semantics', (tester) async {
    await tester.pumpWidget(dock(selected: 2));
    await tester.pumpAndSettle();

    final semantics = tester.getSemantics(find.text('Directory'));
    expect(semantics.hasFlag(SemanticsFlag.isSelected), isTrue);
  });

  testWidgets('RTL keeps pill then satellite in child order', (tester) async {
    await tester.pumpWidget(dock(direction: TextDirection.rtl, selected: 0));
    await tester.pumpAndSettle();

    final dockRect = tester.getRect(find.byType(FloatingShellDock));
    final voucherRect = tester.getRect(find.bySemanticsLabel('New voucher'));
    expect(voucherRect.left, lessThan(dockRect.center.dx));
  });

  testWidgets('outer pill and satellite use stadium or circle shape', (tester) async {
    await tester.pumpWidget(dock(selected: 0));
    await tester.pumpAndSettle();

    final materials = tester.widgetList<Material>(
      find.descendant(of: find.byType(FloatingShellDock), matching: find.byType(Material)),
    );
    expect(materials.any((m) => m.shape is StadiumBorder), isTrue);
    expect(materials.any((m) => m.shape is CircleBorder), isTrue);
  });

  testWidgets('pill spans most of 390pt width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(dock(selected: 0));
    await tester.pumpAndSettle();

    final dockRect = tester.getRect(find.byType(FloatingShellDock));
    expect(dockRect.width, greaterThan(360));
  });

  testWidgets('survives text scale 1.2 and 2.0 without overflow', (tester) async {
    for (final scale in [1.2, 2.0]) {
      await tester.binding.setSurfaceSize(const Size(320, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(dock(selected: 1, textScaler: TextScaler.linear(scale)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
