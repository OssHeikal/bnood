import 'dart:async';

import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/core/domain/ledger/ledger_entities.dart';
import 'package:bnood/core/ui/widgets/skeleton/skeleton.dart';
import 'package:bnood/features/clients/presentation/models/client_identity_snapshot.dart';
import 'package:bnood/features/clients/presentation/providers/client_identity_provider.dart';
import 'package:bnood/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('client detail shows skeleton on first load', (tester) async {
    final gate = Completer<ClientIdentitySnapshot>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientIdentityProvider.overrideWith(
            () => _PendingIdentityNotifier(gate.future),
          ),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClientDetailScreen(clientId: 'c1'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Skeleton), findsWidgets);
  });

  testWidgets('client detail lists projects section', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = ClientIdentitySnapshot(
      client: Client(
        id: 'c1',
        workspaceId: 'w',
        name: 'Tower B',
        phone: '01012345678',
        createdAt: now,
        updatedAt: now,
      ),
      receivedPiastres: 50000,
      spentPiastres: 80000,
      remainingPiastres: -30000,
      projects: const [
        ClientProjectPreviewRow(
          projectId: 'p1',
          projectName: 'Villa',
          remainingPiastres: -30000,
          receivedPiastres: 50000,
          spentPiastres: 80000,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientIdentityProvider.overrideWith(() => _StubIdentityNotifier(snap)),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClientDetailScreen(clientId: 'c1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Tower B'), findsWidgets);
    expect(find.textContaining('01012345678'), findsOneWidget);
    expect(find.byKey(const Key('client_detail_whatsapp')), findsOneWidget);
    expect(find.text('Villa'), findsOneWidget);
    expect(find.byKey(const Key('client_detail_action_receive')), findsNothing);
    expect(find.byKey(const Key('client_detail_overflow')), findsOneWidget);
    expect(find.byType(Skeleton), findsNothing);
  });
}

class _PendingIdentityNotifier extends ClientIdentityNotifier {
  _PendingIdentityNotifier(this._future);

  final Future<ClientIdentitySnapshot> _future;

  @override
  Future<ClientIdentitySnapshot> build(String arg) => _future;
}

class _StubIdentityNotifier extends ClientIdentityNotifier {
  _StubIdentityNotifier(this.snapshot);

  final ClientIdentitySnapshot snapshot;

  @override
  Future<ClientIdentitySnapshot> build(String arg) async => snapshot;
}