import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_toaster.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/statements/statement_pdf_export.dart';
import 'package:bnood/features/statements/statement_screen_toast.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(StatementPdfExport.resetShareForTests);

  testWidgets('sharePositionOriginFor returns non-zero rect from export button', (tester) async {
    Rect? captured;
    StatementPdfExport.shareFromFile = (_, _, {sharePositionOrigin}) async {
      captured = sharePositionOrigin;
    };

    final buttonKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: AppFoundationTheme.light(),
        home: HomeFoundationScope(
          child: Scaffold(
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(key: buttonKey, onPressed: () {}, child: const Text('Share PDF')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final ctx = buttonKey.currentContext!;
    final origin = StatementPdfExport.sharePositionOriginFor(ctx);
    await StatementPdfExport.shareFromFile('x.pdf', 'x.pdf', sharePositionOrigin: origin);

    expect(captured, isNotNull);
    expect(captured!.width, greaterThan(1));
    expect(captured!.height, greaterThan(1));
    expect(captured!.left, greaterThanOrEqualTo(0));
    expect(captured!.top, greaterThanOrEqualTo(0));
  });

  testWidgets('statement share failure toast does not throw without AppColors on root theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: ThemeData.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => StatementScreenToast.failure(context, 'تعذّرت المشاركة'),
                  child: const Text('fail'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('fail'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    expect(find.text('تعذّرت المشاركة'), findsOneWidget);
  });
}
