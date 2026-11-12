import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/clients_api.dart';
import 'package:bnood/core/clients/clients_providers.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/statements/client_statement_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('remote statement shows Share PDF footer when loaded', (tester) async {
    final dio = createAppDio(FakeSessionStore(token: 'tok'));
    dio.httpClientAdapter = ScriptedDioAdapter((options) async {
      if (options.path.endsWith('/statement') && !options.path.endsWith('.pdf')) {
        return jsonResponse(
          '{"success":true,"data":{"period_start":"2026-09-15","from":"2026-09-15","to":"2026-11-09","received":0,"spent":0,"remaining":0,"items":[]}}',
        );
      }
      if (options.path.endsWith('/clients/c1')) {
        return jsonResponse(
          '{"success":true,"data":{"id":"c1","name":"Ahmed","phone":null,"archived_at":null,"created_at":"2026-11-09T10:00:00Z","updated_at":"2026-11-09T10:00:00Z","project":{"id":"p1","name":"Ahmed","status":"active"},"balances":null}}',
        );
      }
      return jsonResponse('{"success":false,"message":"unexpected"}', statusCode: 404);
    });
    final api = ClientsApi(dio: dio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          remoteClientsEnabledProvider.overrideWith((ref) => true),
          clientsApiProvider.overrideWith((ref) => api),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: ClientStatementScreen(clientId: 'c1'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Share PDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
    api.close();
  });
}
