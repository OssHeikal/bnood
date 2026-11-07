import 'dart:async';

import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/features/suppliers/supplier_detail_provider.dart';
import 'package:bnood/features/suppliers/supplier_detail_screen.dart';
import 'package:bnood/features/clients/client_detail_snapshot.dart';
import 'package:bnood/features/suppliers/supplier_detail_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('supplier detail shows skeleton on first load', (tester) async {
    final gate = Completer<SupplierDetailSnapshot>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supplierDetailProvider.overrideWith(() => _PendingSupplierDetailNotifier(gate.future)),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SupplierDetailScreen(supplierId: 's1'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Skeleton), findsWidgets);
  });

  testWidgets('supplier detail hero profile spend and client link EN', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = SupplierDetailSnapshot(
      supplier: Supplier(
        id: 's1',
        workspaceId: 'w',
        name: 'Steel Co',
        phone: '01098765432',
        notes: 'Deliver before noon',
        createdAt: now,
        updatedAt: now,
      ),
      totalPaidPiastres: 150_00,
      history: [
        SupplierDetailHistoryEntry(
          clientId: 'c1',
          clientName: 'Tower B',
          line: ClientDetailMovementLine(
            transaction: Transaction(
              id: 't1',
              workspaceId: 'w',
              projectId: 'p1',
              kind: 'spend',
              amountPiastres: 150_00,
              date: now,
              method: 'cash',
              createdAt: now,
              updatedAt: now,
              itemId: 'item1',
              expenseType: 'materials',
              supplierId: 's1',
            ),
            itemName: 'Steel',
            payeeName: 'Steel Co',
            payeeIsSupplier: true,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supplierDetailProvider.overrideWith(() => _StubSupplierDetailNotifier(snap)),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SupplierDetailScreen(supplierId: 's1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Steel Co'), findsOneWidget);
    expect(find.text('Materials supplier'), findsNothing);
    expect(find.textContaining('01098765432'), findsOneWidget);
    expect(find.text('Total paid to supplier'), findsOneWidget);
    expect(find.textContaining('150 EGP'), findsWidgets);
    expect(find.text('Tower B'), findsOneWidget);
    expect(find.text('Transaction history'), findsOneWidget);
    expect(find.byKey(const Key('supplier_detail_statement')), findsOneWidget);
    expect(find.byType(Skeleton), findsNothing);
  });

  testWidgets('supplier detail AR narrow width', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = SupplierDetailSnapshot(
      supplier: Supplier(
        id: 's1',
        workspaceId: 'w',
        name: 'حديد',
        createdAt: now,
        updatedAt: now,
      ),
      totalPaidPiastres: 0,
      history: const [],
    );

    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supplierDetailProvider.overrideWith(() => _StubSupplierDetailNotifier(snap)),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SupplierDetailScreen(supplierId: 's1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('حديد'), findsWidgets);
    expect(find.text('إجمالي المدفوع للمورد'), findsOneWidget);
    expect(find.text('لا توجد تعاملات مسجلة'), findsOneWidget);
    expect(find.textContaining('٠'), findsNothing);
    expect(find.textContaining('ج.م'), findsNothing);
  });

  testWidgets('supplier detail not found fallback', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supplierDetailProvider.overrideWith(() => _ErrorSupplierDetailNotifier(const SupplierDetailNotFound())),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SupplierDetailScreen(supplierId: 'missing'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Supplier not found'), findsOneWidget);
    expect(find.byKey(const Key('supplier_detail_statement')), findsNothing);
  });
}

class _PendingSupplierDetailNotifier extends SupplierDetailNotifier {
  _PendingSupplierDetailNotifier(this.future);

  final Future<SupplierDetailSnapshot> future;

  @override
  Future<SupplierDetailSnapshot> build(String arg) => future;
}

class _StubSupplierDetailNotifier extends SupplierDetailNotifier {
  _StubSupplierDetailNotifier(this.value);

  final SupplierDetailSnapshot value;

  @override
  Future<SupplierDetailSnapshot> build(String arg) async => value;
}

class _ErrorSupplierDetailNotifier extends SupplierDetailNotifier {
  _ErrorSupplierDetailNotifier(this.error);

  final Object error;

  @override
  Future<SupplierDetailSnapshot> build(String arg) => Future.error(error);
}
