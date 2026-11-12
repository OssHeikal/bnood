import 'dart:async';

import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/widgets/custom_text_field.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/features/clients/client_detail_snapshot.dart';
import 'package:bnood/features/suppliers/craftsman_detail_provider.dart';
import 'package:bnood/features/suppliers/craftsman_detail_screen.dart';
import 'package:bnood/features/suppliers/craftsman_detail_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('craftsman detail shows skeleton on first load', (tester) async {
    final gate = Completer<CraftsmanDetailSnapshot>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [craftsmanDetailProvider.overrideWith(() => _PendingCraftsmanDetailNotifier(gate.future))],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CraftsmanDetailScreen(craftsmanId: 'cr1'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Skeleton), findsWidgets);
  });

  testWidgets('craftsman detail EN job metrics and null agreement', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = CraftsmanDetailSnapshot(
      craftsman: CraftsmenData(
        id: 'cr1',
        workspaceId: 'w',
        name: 'Ahmed Plumber',
        phone: '01012345678',
        trade: 'Plumbing',
        createdAt: now,
        updatedAt: now,
      ),
      totalLaborPaidPiastres: 250_00,
      linkedProjectCount: 1,
      jobs: const [
        CraftsmanDetailJobRow(
          projectId: 'p1',
          clientId: 'c1',
          clientName: 'Tower B',
          paidPiastres: 250_00,
          agreedPiastres: null,
          remainingPiastres: null,
        ),
      ],
      history: [
        CraftsmanDetailHistoryEntry(
          clientId: 'c1',
          clientName: 'Tower B',
          line: ClientDetailMovementLine(
            transaction: Transaction(
              id: 't1',
              workspaceId: 'w',
              projectId: 'p1',
              kind: 'spend',
              amountPiastres: 250_00,
              date: now,
              method: 'cash',
              createdAt: now,
              updatedAt: now,
              expenseType: 'labor',
              craftsmanId: 'cr1',
            ),
            itemName: 'Labor',
            payeeName: 'Ahmed Plumber',
            payeeIsSupplier: false,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [craftsmanDetailProvider.overrideWith(() => _StubCraftsmanDetailNotifier(snap))],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CraftsmanDetailScreen(craftsmanId: 'cr1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Ahmed Plumber'), findsOneWidget);
    expect(find.text('Craftsman'), findsNothing);
    expect(find.text('Plumbing'), findsOneWidget);
    expect(find.textContaining('01012345678'), findsOneWidget);
    expect(find.text('Total labor paid'), findsOneWidget);
    expect(find.textContaining('250 EGP'), findsWidgets);
    expect(find.text('No agreed amount'), findsOneWidget);
    expect(find.text('Tower B'), findsWidgets);
    expect(find.text('Edit agreement'), findsOneWidget);
    expect(find.text('Remaining'), findsNothing);
    expect(find.byType(Skeleton), findsNothing);
  });

  testWidgets('edit agreement opens focused amount sheet not roster picker', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = CraftsmanDetailSnapshot(
      craftsman: CraftsmenData(
        id: 'cr1',
        workspaceId: 'w',
        name: 'Ahmed Plumber',
        phone: '01012345678',
        createdAt: now,
        updatedAt: now,
      ),
      totalLaborPaidPiastres: 100_00,
      linkedProjectCount: 1,
      jobs: const [
        CraftsmanDetailJobRow(
          projectId: 'p1',
          clientId: 'c1',
          clientName: 'Tower B',
          paidPiastres: 100_00,
          agreedPiastres: 500_00,
          remainingPiastres: 400_00,
        ),
      ],
      history: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [craftsmanDetailProvider.overrideWith(() => _StubCraftsmanDetailNotifier(snap))],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CraftsmanDetailScreen(craftsmanId: 'cr1'),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Edit agreement'));
    await tester.pumpAndSettle();

    expect(find.text('Assign craftsmen'), findsNothing);
    expect(find.textContaining('Tower B'), findsWidgets);
    expect(find.text('Ahmed Plumber'), findsWidgets);
    expect(find.byType(CustomTextField), findsOneWidget);
  });

  testWidgets('craftsman detail shows negative remaining when agreed is zero', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = CraftsmanDetailSnapshot(
      craftsman: CraftsmenData(
        id: 'cr2',
        workspaceId: 'w',
        name: 'Painter',
        phone: '01099998888',
        createdAt: now,
        updatedAt: now,
      ),
      totalLaborPaidPiastres: 500_00,
      linkedProjectCount: 1,
      jobs: const [
        CraftsmanDetailJobRow(
          projectId: 'p1',
          clientId: 'c1',
          clientName: 'Site',
          paidPiastres: 500_00,
          agreedPiastres: 0,
          remainingPiastres: -500_00,
        ),
      ],
      history: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [craftsmanDetailProvider.overrideWith(() => _StubCraftsmanDetailNotifier(snap))],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CraftsmanDetailScreen(craftsmanId: 'cr2'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Agreed'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.textContaining('500 EGP'), findsWidgets);
    expect(find.textContaining('−'), findsWidgets);
  });

  testWidgets('craftsman detail AR narrow Western digits', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = CraftsmanDetailSnapshot(
      craftsman: CraftsmenData(
        id: 'cr3',
        workspaceId: 'w',
        name: 'سبّاك',
        phone: '01011112222',
        createdAt: now,
        updatedAt: now,
      ),
      totalLaborPaidPiastres: 0,
      linkedProjectCount: 0,
      jobs: const [],
      history: const [],
    );

    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [craftsmanDetailProvider.overrideWith(() => _StubCraftsmanDetailNotifier(snap))],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CraftsmanDetailScreen(craftsmanId: 'cr3'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('إجمالي المصنعية المدفوعة'), findsOneWidget);
    expect(find.textContaining('01011112222'), findsOneWidget);
    expect(find.textContaining('٠'), findsNothing);
    expect(find.textContaining('ج.م'), findsNothing);
  });

  testWidgets('craftsman detail silent refresh keeps data without skeleton', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final notifier = _SequencedCraftsmanDetailNotifier([
      CraftsmanDetailSnapshot(
        craftsman: CraftsmenData(
          id: 'cr9',
          workspaceId: 'w',
          name: 'Live',
          phone: '01000000005',
          createdAt: now,
          updatedAt: now,
        ),
        totalLaborPaidPiastres: 100_00,
        linkedProjectCount: 1,
        jobs: const [
          CraftsmanDetailJobRow(
            projectId: 'p1',
            clientId: 'c1',
            clientName: 'Alpha',
            paidPiastres: 100_00,
            agreedPiastres: 500_00,
            remainingPiastres: 400_00,
          ),
        ],
        history: const [],
      ),
      CraftsmanDetailSnapshot(
        craftsman: CraftsmenData(
          id: 'cr9',
          workspaceId: 'w',
          name: 'Live',
          phone: '01000000005',
          createdAt: now,
          updatedAt: now,
        ),
        totalLaborPaidPiastres: 250_00,
        linkedProjectCount: 1,
        jobs: const [
          CraftsmanDetailJobRow(
            projectId: 'p1',
            clientId: 'c1',
            clientName: 'Alpha',
            paidPiastres: 250_00,
            agreedPiastres: 500_00,
            remainingPiastres: 250_00,
          ),
        ],
        history: const [],
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [craftsmanDetailProvider.overrideWith(() => notifier)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CraftsmanDetailScreen(craftsmanId: 'cr9'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('400 EGP'), findsWidgets);
    expect(find.byType(Skeleton), findsNothing);

    final refresh = notifier.refreshSilently();
    await tester.pump();
    expect(find.byType(Skeleton), findsNothing);

    await refresh;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('250 EGP'), findsWidgets);
    expect(find.byType(Skeleton), findsNothing);
  });

  testWidgets('zero-paid linked job still visible', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = CraftsmanDetailSnapshot(
      craftsman: CraftsmenData(
        id: 'cr0',
        workspaceId: 'w',
        name: 'Idle',
        phone: '01000000000',
        createdAt: now,
        updatedAt: now,
      ),
      totalLaborPaidPiastres: 0,
      linkedProjectCount: 1,
      jobs: const [
        CraftsmanDetailJobRow(
          projectId: 'p1',
          clientId: 'c1',
          clientName: 'Quiet Site',
          paidPiastres: 0,
          agreedPiastres: 1000_00,
          remainingPiastres: 1000_00,
        ),
      ],
      history: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [craftsmanDetailProvider.overrideWith(() => _StubCraftsmanDetailNotifier(snap))],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CraftsmanDetailScreen(craftsmanId: 'cr0'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Quiet Site'), findsOneWidget);
    expect(find.textContaining('0 EGP'), findsWidgets);
  });

  testWidgets('craftsman detail not found', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          craftsmanDetailProvider.overrideWith(() => _ErrorCraftsmanDetailNotifier(const CraftsmanDetailNotFound())),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CraftsmanDetailScreen(craftsmanId: 'missing'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Craftsman not found'), findsOneWidget);
  });
}

class _PendingCraftsmanDetailNotifier extends CraftsmanDetailNotifier {
  _PendingCraftsmanDetailNotifier(this.future);
  @override
  final Future<CraftsmanDetailSnapshot> future;
  @override
  Future<CraftsmanDetailSnapshot> build(String arg) => future;
}

class _StubCraftsmanDetailNotifier extends CraftsmanDetailNotifier {
  _StubCraftsmanDetailNotifier(this.value);
  final CraftsmanDetailSnapshot value;
  @override
  Future<CraftsmanDetailSnapshot> build(String arg) async => value;
}

class _ErrorCraftsmanDetailNotifier extends CraftsmanDetailNotifier {
  _ErrorCraftsmanDetailNotifier(this.error);
  final Object error;
  @override
  Future<CraftsmanDetailSnapshot> build(String arg) => Future.error(error);
}

class _SequencedCraftsmanDetailNotifier extends CraftsmanDetailNotifier {
  _SequencedCraftsmanDetailNotifier(this._values);

  final List<CraftsmanDetailSnapshot> _values;
  var _fetchCount = 0;

  @override
  Future<CraftsmanDetailSnapshot> build(String arg) => loadSnapshot(arg);

  @override
  Future<CraftsmanDetailSnapshot> loadSnapshot(String craftsmanId) async {
    final index = (_fetchCount++).clamp(0, _values.length - 1);
    return _values[index];
  }
}
