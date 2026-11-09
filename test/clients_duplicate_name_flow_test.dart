import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/api/clients_api.dart';
import 'package:bnood/core/clients/client_api_record.dart';
import 'package:bnood/core/clients/clients_providers.dart';
import 'package:bnood/core/clients/clients_repository.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/features/clients/client_mutation_actions.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _DuplicateClientsRepository extends ClientsRepository {
  _DuplicateClientsRepository() : super(ClientsApi());

  var calls = 0;

  @override
  Future<ClientApiRecord> createClient({
    required String name,
    String? phone,
    bool confirmDuplicateName = false,
  }) async {
    calls++;
    if (calls == 1) {
      throw AuthApiException(statusCode: 409, message: 'dup', code: 'duplicate_name');
    }
    final now = DateTime.utc(2026, 11, 9);
    return ClientApiRecord(
      client: Client(
        id: 'c1',
        workspaceId: 'remote',
        name: name,
        phone: phone,
        createdAt: now,
        updatedAt: now,
      ),
      project: Project(
        id: 'p1',
        workspaceId: 'remote',
        clientId: 'c1',
        name: name,
        status: 'active',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}

class _Harness extends ConsumerStatefulWidget {
  const _Harness({required this.onResult});

  final void Function(Client? client) onResult;

  @override
  ConsumerState<_Harness> createState() => _HarnessState();
}

class _HarnessState extends ConsumerState<_Harness> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final created = await saveClientCreate(
              ref: ref,
              context: context,
              name: 'Ahmed',
            );
            widget.onResult(created);
          },
          child: const Text('save'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('duplicate name confirm resends with confirm_duplicate_name', (tester) async {
    final repo = _DuplicateClientsRepository();
    Client? created;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          remoteClientsEnabledProvider.overrideWithValue(true),
          clientsRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _Harness(onResult: (c) => created = c),
        ),
      ),
    );

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(repo.calls, 2);
    expect(created?.name, 'Ahmed');
  });
}
