import 'dart:async';

import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/features/clients/client_detail_provider.dart';
import 'package:bnood/features/clients/client_detail_screen.dart';
import 'package:bnood/features/clients/client_detail_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('client detail shows skeleton on first load', (tester) async {
    final gate = Completer<ClientDetailSnapshot>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientDetailProvider.overrideWith(() => _PendingDetailNotifier(gate.future)),
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

  testWidgets('client detail renders remaining negative in EN', (tester) async {
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
        name: 'Project',
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
          clientDetailProvider.overrideWith(() => _StubDetailNotifier(snap)),
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
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.textContaining('Remaining in active funds'), findsNothing);
    expect(find.textContaining('300 EGP'), findsWidgets);
    expect(find.textContaining('−'), findsWidgets);
    expect(find.byKey(const Key('client_detail_action_receive')), findsOneWidget);
    expect(find.byKey(const Key('client_detail_action_statement')), findsOneWidget);
    expect(find.byKey(const Key('client_detail_edit')), findsOneWidget);
    expect(find.byType(Skeleton), findsNothing);
  });

  testWidgets('client detail AR layout at narrow width', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = ClientDetailSnapshot(
      client: Client(
        id: 'c1',
        workspaceId: 'w',
        name: 'برج',
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
      receivedPiastres: 100000,
      spentPiastres: 0,
      estimatedProfitPiastres: null,
      craftsmanPreviews: const [],
      topItems: const [],
      latestMovements: const [],
    );

    tester.view.physicalSize = const Size(440, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientDetailProvider.overrideWith(() => _StubDetailNotifier(snap)),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClientDetailScreen(clientId: 'c1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('صنايعية'), findsOneWidget);
    expect(find.textContaining('1,000 EGP'), findsWidgets);
    expect(AppLocalizations.of(tester.element(find.byType(ClientDetailScreen))).labor, 'مصنعية');
    expect(tester.takeException(), isNull);
  });

  testWidgets('silent refresh keeps detail content without skeleton', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final notifier = _SequencedDetailNotifier([
        ClientDetailSnapshot(
          client: Client(
            id: 'c1',
            workspaceId: 'w',
            name: 'Alpha',
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
          receivedPiastres: 10000,
          spentPiastres: 0,
          estimatedProfitPiastres: null,
          craftsmanPreviews: const [],
          topItems: const [],
          latestMovements: const [],
        ),
        ClientDetailSnapshot(
          client: Client(
            id: 'c1',
            workspaceId: 'w',
            name: 'Alpha',
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
          receivedPiastres: 25000,
          spentPiastres: 0,
          estimatedProfitPiastres: null,
          craftsmanPreviews: const [],
          topItems: const [],
          latestMovements: const [],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientDetailProvider.overrideWith(() => notifier),
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
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('100'), findsWidgets);
    expect(find.textContaining('EGP'), findsWidgets);

    final refresh = notifier.refreshSilently();
    await tester.pump();
    expect(find.byType(Skeleton), findsNothing);

    await refresh;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('250'), findsWidgets);
    expect(find.byType(Skeleton), findsNothing);
  });

  testWidgets('client detail empty sections show placeholders', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = ClientDetailSnapshot(
      client: Client(
        id: 'c1',
        workspaceId: 'w',
        name: 'Empty Client',
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientDetailProvider.overrideWith(() => _StubDetailNotifier(snap)),
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

    expect(find.text('Empty Client'), findsWidgets);
    expect(find.text('No movements yet'), findsOneWidget);
    expect(find.text('No item spend recorded yet'), findsOneWidget);
    expect(find.text('Assign craftsmen'), findsWidgets);
    expect(find.byType(Skeleton), findsNothing);
  });
}

class _PendingDetailNotifier extends ClientDetailNotifier {
  _PendingDetailNotifier(this._future);

  final Future<ClientDetailSnapshot> _future;

  @override
  Future<ClientDetailSnapshot> build(String arg) => _future;
}

class _StubDetailNotifier extends ClientDetailNotifier {
  _StubDetailNotifier(this.snapshot);

  final ClientDetailSnapshot snapshot;

  @override
  Future<ClientDetailSnapshot> build(String arg) async => snapshot;
}

class _SequencedDetailNotifier extends ClientDetailNotifier {
  _SequencedDetailNotifier(this._values);

  final List<ClientDetailSnapshot> _values;
  var _fetchCount = 0;

  @override
  Future<ClientDetailSnapshot> loadSnapshot(String clientId) async {
    final index = (_fetchCount++).clamp(0, _values.length - 1);
    return _values[index];
  }
}
