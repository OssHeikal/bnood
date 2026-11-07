import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/brand/app_brand_lockup.dart';
import 'package:bnood/features/statements/client_statement_screen.dart';
import 'package:bnood/features/statements/supplier_statement_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpStatement(
    WidgetTester tester, {
    required Widget child,
    required BnoodRepository repo,
    Locale locale = const Locale('ar'),
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      ),
    );
  }

  testWidgets('client statement has text-only app bar and no logo lockup', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'عميل طويل الاسم للاختبار على الشاشة الضيقة');

    await pumpStatement(tester, repo: repo, child: ClientStatementScreen(clientId: client.id));
    await tester.pump();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.textContaining('عميل طويل').evaluate().isNotEmpty) break;
    }

    expect(find.byType(AppBrandLockup), findsNothing);
    expect(find.text('كشف حساب'), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(5));
    await tester.tap(find.text('تخصيص الفترة'));
    await tester.pumpAndSettle();
    expect(find.text('من'), findsOneWidget);
    expect(find.text('إلى'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supplier statement EN layout loads without logo', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final supplier = await repo.createSupplier(name: 'Long Supplier Name For Narrow Layout');

    await pumpStatement(
      tester,
      repo: repo,
      locale: const Locale('en'),
      child: SupplierStatementScreen(supplierId: supplier.id),
    );
    await tester.pump();
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Long Supplier Name').evaluate().isNotEmpty) break;
    }

    expect(find.byType(AppBrandLockup), findsNothing);
    expect(find.text('Statement'), findsOneWidget);
    expect(find.text('Since last export'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
