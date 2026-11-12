import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/clients_api.dart';
import 'package:bnood/core/clients/clients_providers.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/layout/bnood_breakpoints.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/statements/client_statement_screen.dart';
import 'package:bnood/features/statements/supplier_statement_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('client statement loads without crash when prefs unavailable', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'عميل كشف');
    SharedPreferences.setMockInitialValues({});

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
    expect(find.byType(FilterChip), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('supplier statement loads without crash when prefs unavailable', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final supplier = await repo.createSupplier(name: 'مورد كشف');
    SharedPreferences.setMockInitialValues({});

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
    expect(find.text('مورد كشف'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('remote client statement renders period controls and document on iPad width', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(768, 1024);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    final dio = createAppDio(FakeSessionStore(token: 'tok'));
    Uri? statementRequestUri;
    dio.httpClientAdapter = ScriptedDioAdapter((options) async {
      if (options.path.endsWith('/statement') && !options.path.endsWith('.pdf')) {
        statementRequestUri = options.uri;
        return jsonResponse(
          '{"success":true,"data":{"period_start":"2026-09-15","from":"2026-09-15","to":"2026-11-09","received":1000,"spent":500,"remaining":500,"items":[]}}',
        );
      }
      if (options.path.contains('/clients/c1')) {
        return jsonResponse(
          '{"success":true,"data":{"id":"c1","name":"عميل كشف","phone":null,"archived_at":null,"created_at":"2026-11-09T10:00:00Z","updated_at":"2026-11-09T10:00:00Z","project":{"id":"p1","name":"عميل كشف","status":"active"},"balances":null}}',
        );
      }
      if (options.path.contains('/items')) {
        return jsonResponse('{"success":true,"data":{"items":[],"icons":{"colors":[],"icon_keys":[]}}}');
      }
      return jsonResponse('{"success":false}', statusCode: 404);
    });
    final api = ClientsApi(dio: dio);
    addTearDown(api.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          remoteClientsEnabledProvider.overrideWith((ref) => true),
          clientsApiProvider.overrideWith((ref) => api),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(size: const Size(768, 1024)),
            child: ResponsiveBreakpoints.builder(
              breakpoints: BnoodBreakpoints.all,
              child: HomeFoundationScope(child: child!),
            ),
          ),
          home: const ClientStatementScreen(clientId: 'c1'),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(tester.takeException(), isNull);
    expect(find.text('عميل كشف'), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(5));
    expect(statementRequestUri, isNotNull);
    expect(statementRequestUri!.queryParameters.containsKey('from'), isFalse);
    expect(statementRequestUri!.queryParameters['to'], isNotEmpty);
  });
}
