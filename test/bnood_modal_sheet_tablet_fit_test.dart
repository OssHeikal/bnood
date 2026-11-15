import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/bnood_modal_sheet.dart';
import 'package:bnood/core/widgets/bounded_sheet_navigator.dart';
import 'package:bnood/core/widgets/sheet_drag_handle.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'bnood_modal_sheet_safe_area_test.dart' show _applyDeviceInsets;

const _tabletSize = Size(820, 1180);

void main() {
  testWidgets('BnoodModalSheet hugs short content on tablet width', (tester) async {
    tester.view.physicalSize = _tabletSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          breakpoints: const [
            Breakpoint(start: 0, end: 450, name: MOBILE),
            Breakpoint(start: 451, end: 1023, name: TABLET),
            Breakpoint(start: 1024, end: double.infinity, name: DESKTOP),
          ],
          child: child!,
        ),
        home: HomeFoundationScope(
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => BnoodModalSheet.show<void>(
                    context: context,
                    builder: (_) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SheetDragHandle(),
                          Text('Compact'),
                        ],
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final cap = SheetContentBounds.viewportCap(MediaQueryData(size: _tabletSize));
    final bounds = find.byKey(BnoodModalSheet.sheetBoundsKey);
    expect(tester.getSize(bounds).height, lessThan(cap * 0.35));
  });
}