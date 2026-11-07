import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/statements/client_statement_screen.dart';
import 'package:bnood/features/statements/supplier_statement_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void mockBrokenPrefs() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (call) async => throw PlatformException(
        code: 'channel-error',
        message:
            'Unable to establish connection on channel: "dev.flutter.pigeon.shared_preferences_foundation.LegacyUserDefaultsApi.getAll".',
      ),
    );
  }

  void clearMockPrefs() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/shared_preferences'), null);
  }

  testWidgets('client statement loads without crash when prefs channel fails', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'عميل كشف');
    mockBrokenPrefs();
    addTearDown(clearMockPrefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ClientStatementScreen(clientId: client.id),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('عميل كشف').evaluate().isNotEmpty) break;
    }

    expect(find.text('كشف حساب'), findsOneWidget);
    expect(find.text('من آخر تصدير'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supplier statement loads without crash when prefs channel fails', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final supplier = await repo.createSupplier(name: 'مورد كشف');
    mockBrokenPrefs();
    addTearDown(clearMockPrefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SupplierStatementScreen(supplierId: supplier.id),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('مورد كشف').evaluate().isNotEmpty) break;
    }

    expect(find.text('كشف حساب'), findsOneWidget);
    expect(find.text('كشف حساب مورد'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
