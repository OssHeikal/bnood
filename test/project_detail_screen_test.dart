import 'dart:async';

import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/core/domain/ledger/ledger_entities.dart';
import 'package:bnood/core/ui/widgets/skeleton/skeleton.dart';
import 'package:bnood/features/clients/presentation/models/client_detail_snapshot.dart';
import 'package:bnood/features/projects/domain/project_detail_params.dart';
import 'package:bnood/features/projects/presentation/providers/project_detail_provider.dart';
import 'package:bnood/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _params = (clientId: 'c1', projectId: 'p1');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('project detail shows skeleton on first load', (tester) async {
    final gate = Completer<ClientDetailSnapshot>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectDetailProvider.overrideWith(
            () => _PendingDetailNotifier(gate.future),
          ),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProjectDetailScreen(clientId: 'c1', projectId: 'p1'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Skeleton), findsWidgets);
  });

  testWidgets('project detail renders remaining negative in EN', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = ClientDetailSnapshot(
      client: Client(
        id: 'c1',
        workspaceId: 'w',
        name: 'Tower B',
        phone: '01012345678',
        createdAt: now,
        updatedAt: now,
      ),
      project: Project(
        id: 'p1',
        workspaceId: 'w',
        clientId: 'c1',
        name: 'Villa',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      ),
      receivedPiastres: 50000,
      spentPiastres: 80000,
      estimatedProfitPiastres: null,
      craftsmanPreviews: const [],
      topItems: const [],
      latestMovements: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectDetailProvider.overrideWith(() => _StubDetailNotifier(snap)),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProjectDetailScreen(clientId: 'c1', projectId: 'p1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Villa'), findsWidgets);
    expect(find.text('Tower B'), findsWidgets);
    expect(find.text('Remaining'), findsOneWidget);
    expect(
      find.byKey(const Key('client_detail_action_receive')),
      findsOneWidget,
    );
    expect(find.byType(Skeleton), findsNothing);
  });
}

class _PendingDetailNotifier extends ProjectDetailNotifier {
  _PendingDetailNotifier(this._future);

  final Future<ClientDetailSnapshot> _future;

  @override
  Future<ClientDetailSnapshot> build(ProjectDetailParams arg) => _future;
}

class _StubDetailNotifier extends ProjectDetailNotifier {
  _StubDetailNotifier(this.snapshot);

  final ClientDetailSnapshot snapshot;

  @override
  Future<ClientDetailSnapshot> build(ProjectDetailParams arg) async => snapshot;
}