import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/bnood_modal_sheet.dart';
import 'package:bnood/core/widgets/sheet_drag_handle.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/vouchers/voucher_receipt_source_sheet.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpHost(WidgetTester tester, {required double width}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        darkTheme: AppFoundationTheme.dark(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          breakpoints: const [
            Breakpoint(start: 0, end: 450, name: MOBILE),
            Breakpoint(start: 451, end: 1023, name: TABLET),
            Breakpoint(start: 1024, end: double.infinity, name: DESKTOP),
          ],
          child: child ?? const SizedBox.shrink(),
        ),
        home: HomeFoundationScope(
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showVoucherReceiptSourceSheet(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('receipt source sheet shows camera and gallery tiles', (tester) async {
    await pumpHost(tester, width: 390);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(SheetDragHandle), findsOneWidget);
    expect(find.text('الكاميرا'), findsOneWidget);
    expect(find.text('المعرض'), findsOneWidget);
    expect(find.text('الملفات'), findsNothing);
    expect(find.byKey(BnoodModalSheet.sheetBoundsKey), findsOneWidget);

    await tester.tap(find.text('الكاميرا'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('tablet receipt source sheet respects modal max width', (tester) async {
    await pumpHost(tester, width: 820);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final bounds = tester.renderObject<RenderBox>(find.byKey(BnoodModalSheet.sheetBoundsKey));
    expect(bounds.size.width, lessThanOrEqualTo(600));
  });
}