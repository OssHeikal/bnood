import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/features/clients/data/clients_api.dart';
import 'package:bnood/features/clients/data/clients_providers.dart';
import 'package:bnood/features/clients/data/clients_repository.dart';
import 'package:bnood/features/items/data/item_api_record.dart';
import 'package:bnood/features/items/data/items_providers.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/statements/presentation/screens/client_statement_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('remote statement shows Share PDF footer when loaded', (
    tester,
  ) async {
    final dio = createAppDio(FakeSessionStore(token: 'tok'));
    dio.httpClientAdapter = ScriptedDioAdapter((options) async {
      if (options.path.endsWith('/statement') &&
          !options.path.endsWith('.pdf')) {
        return jsonResponse(
          '{"success":true,"data":{"period_start":"2026-09-15","from":"2026-09-15","to":"2026-11-09","received":0,"spent":0,"remaining":0,"items":[]}}',
        );
      }
      if (options.path.endsWith('/clients/c1')) {
        return jsonResponse(
          '{"success":true,"data":{"id":"c1","name":"Ahmed","phone":null,"archived_at":null,"created_at":"2026-11-09T10:00:00Z","updated_at":"2026-11-09T10:00:00Z","project":{"id":"p1","name":"Ahmed","status":"active"},"balances":null}}',
        );
      }
      return jsonResponse(
        '{"success":false,"message":"unexpected"}',
        statusCode: 404,
      );
    });
    final api = ClientsApi(dio: dio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientsApiProvider.overrideWith((ref) => api),
          clientsRepositoryProvider.overrideWith(
            (ref) => ClientsRepository(api),
          ),
          itemsCatalogByIdProvider.overrideWith(
            (ref) async => const <String, CatalogItem>{},
          ),
          authControllerProvider.overrideWith(() => _AuthStub()),
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
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Share PDF').evaluate().isNotEmpty) break;
    }

    expect(find.text('Share PDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
    api.close();
  });
}

class _AuthStub extends AuthController {
  @override
  AuthState build() => AuthState(
    bootstrapStatus: AuthBootstrapStatus.authenticated,
    user: const User(id: 'usr', phone: '+201012345678', name: 'Eng'),
    bootstrapStarted: true,
  );
}
