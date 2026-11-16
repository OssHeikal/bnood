import 'package:bnood/core/api/clients_api.dart';
import 'package:bnood/core/clients/clients_providers.dart';
import 'package:bnood/core/clients/clients_repository.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/features/clients/client_detail_provider.dart';
import 'package:bnood/features/clients/client_detail_screen.dart';
import 'package:bnood/features/clients/client_detail_snapshot.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ClientDetailSnapshot snapshot({String name = 'Tower B'}) {
    final now = DateTime.utc(2026, 11, 1);
    return ClientDetailSnapshot(
      client: Client(
        id: 'c1',
        workspaceId: 'w',
        name: name,
        phone: '01012345678',
        createdAt: now,
        updatedAt: now,
      ),
      project: Project(
        id: 'p1',
        workspaceId: 'w',
        clientId: 'c1',
        name: 'Project',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      ),
      receivedPiastres: 0,
      spentPiastres: 0,
      estimatedProfitPiastres: null,
      craftsmanPreviews: const [],
      topItems: const [],
      latestMovements: const [],
    );
  }

  testWidgets('delete confirm calls API and shows purge copy', (tester) async {
    var deleteCalled = false;
    final botToastBuilder = BotToastInit();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          remoteClientsEnabledProvider.overrideWithValue(true),
          clientsRepositoryProvider.overrideWithValue(_FakeClientsRepo(onDelete: () => deleteCalled = true)),
          clientDetailProvider.overrideWith(() => _StubDetail(snapshot())),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: botToastBuilder,
          navigatorObservers: [BotToastNavigatorObserver()],
          home: const _DeleteTestHost(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('client_detail_overflow')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete client?'), findsOneWidget);
    expect(find.textContaining('permanently deleted'), findsOneWidget);

    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(deleteCalled, isTrue);
    expect(find.text('Clients list'), findsOneWidget);
  });
}

class _DeleteTestHost extends StatelessWidget {
  const _DeleteTestHost();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: const [
        MaterialPage(child: Scaffold(body: Text('Clients list'))),
        MaterialPage(
          child: HomeFoundationScope(child: ClientDetailScreen(clientId: 'c1')),
        ),
      ],
    );
  }
}

class _FakeClientsRepo extends ClientsRepository {
  _FakeClientsRepo({required this.onDelete}) : super(ClientsApi());

  final VoidCallback onDelete;

  @override
  Future<void> deleteClient(String id) async {
    onDelete();
  }
}

class _StubDetail extends ClientDetailNotifier {
  _StubDetail(this.data);
  final ClientDetailSnapshot data;
  @override
  Future<ClientDetailSnapshot> build(String arg) async => data;
}