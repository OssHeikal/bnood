import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/bounded_sheet_navigator.dart';
import 'package:bnood/core/widgets/custom_bottom_sheet.dart';
import 'package:bnood/core/widgets/sheet_drag_handle.dart';
import 'package:bnood/features/clients/profit_percentage_sheet.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _tallPhone = Size(390, 844);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpHost(WidgetTester tester, Widget child) async {
    await tester.binding.setSurfaceSize(_tallPhone);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(child: child),
      ),
    );
  }

  testWidgets('profit sheet hugs content under 80 percent cap', (tester) async {
    await pumpHost(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showProfitPercentageSheet(
              context: context,
              clientId: 'c1',
              projectId: 'p1',
              clientName: 'Tower',
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final cap = SheetContentBounds.viewportCap(MediaQueryData(size: _tallPhone));
    final handle = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(SheetDragHandle),
    );
    final material = find.ancestor(of: handle, matching: find.byType(Material));
    expect(tester.getSize(material.first).height, lessThan(cap * 0.75));
    expect(tester.getTopLeft(handle).dy, lessThan(160));
  });

  testWidgets('custom bottom sheet inline create respects viewport cap', (tester) async {
    await pumpHost(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => CustomBottomSheet.show<void>(
              context: context,
              nestedNavigator: false,
              builder: (_) => const SizedBox(
                height: 120,
                child: Center(child: Text('Short body')),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final cap = SheetContentBounds.viewportCap(MediaQueryData(size: _tallPhone));
    final text = find.descendant(of: find.byType(BottomSheet), matching: find.text('Short body'));
    final material = find.ancestor(of: text, matching: find.byType(Material));
    expect(tester.getSize(material.first).height, lessThan(cap * 0.5));
  });

  test('viewportCap is eighty percent of screen', () {
    const media = MediaQueryData(size: Size(400, 800));
    expect(SheetContentBounds.viewportCap(media), 640);
  });
}
