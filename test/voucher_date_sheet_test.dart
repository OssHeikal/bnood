import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/vouchers/voucher_date_sheet.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppFoundationTheme.light(),
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SizedBox(height: 900, child: child),
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> tallSurface(WidgetTester tester, Future<void> Function() body) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await body();
  }

  testWidgets('date sheet confirm returns staged day', (tester) async {
    DateTime? result;
    await tallSurface(tester, () async {
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await Navigator.of(context).push<DateTime>(
                MaterialPageRoute(
                  builder: (_) => VoucherDateSheetPage(
                    initial: DateTime(2026, 3, 10),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('voucher-day-2026-3-15')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('voucher-date-confirm')));
    await tester.pumpAndSettle();

    expect(result, DateTime(2026, 3, 15));
    });
  });

  testWidgets('date sheet back cancels without result', (tester) async {
    DateTime? result;
    await tallSurface(tester, () async {
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await Navigator.of(context).push<DateTime>(
                MaterialPageRoute(
                  builder: (_) => VoucherDateSheetPage(
                    initial: DateTime(2026, 3, 10),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('voucher-day-2026-3-22')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(result, isNull);
    });
  });

  testWidgets('month year wheel cancel leaves staged date', (tester) async {
    DateTime? result;
    await tallSurface(tester, () async {
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await Navigator.of(context).push<DateTime>(
                MaterialPageRoute(
                  builder: (_) => VoucherDateSheetPage(
                    initial: DateTime(2026, 3, 10),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('voucher-calendar-title')));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('voucher-date-confirm')));
    await tester.pumpAndSettle();
    expect(result, DateTime(2026, 3, 10));
    });
  });
}
