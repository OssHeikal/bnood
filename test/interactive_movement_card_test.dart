import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/widgets/buttons/app_button.dart';
import 'package:bnood/features/clients/client_movement_lines.dart';
import 'package:bnood/features/clients/widgets/interactive_movement_card.dart';
import 'package:bnood/features/clients/voucher_draft_from_transaction.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/vouchers/voucher_draft.dart';
import 'package:bnood/features/vouchers/voucher_launcher.dart';
import 'package:bnood/features/vouchers/voucher_sheet.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('voucher draft from transaction preserves editing id and amount', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'اختبار');
    final project = (await repo.primaryActiveProject(client.id))!;
    final item = (await repo.watchActiveItems().first).first;
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 50000,
      date: DateTime(2025, 2, 1),
      method: 'cash',
      itemId: item.id,
      expenseType: 'materials',
    );
    final tx = (await repo.transactionsForProject(project.id)).single;
    final draft = await voucherDraftFromTransaction(repo, tx);
    expect(draft, isNotNull);
    expect(draft!.editingTransactionId, tx.id);
    expect(draft.amountPiastres, 50000);
    expect(draft.clientId, client.id);
  });

  testWidgets('movement card has no on-card delete affordance', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'بطاقة');
    final project = (await repo.primaryActiveProject(client.id))!;
    final item = (await repo.watchActiveItems().first).first;
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'receive',
      amountPiastres: 100000,
      date: DateTime(2025, 2, 1),
      method: 'cash',
    );
    final rows = await repo.transactionsForProject(project.id);
    final maps = await (
      itemById: {for (final i in await repo.watchActiveItems().first) i.id: i},
      supplierById: {for (final s in await repo.watchActiveSuppliers().first) s.id: s},
      craftsmanById: {for (final c in await repo.watchActiveCraftsmen().first) c.id: c},
    );
    final line = movementLineFromTransaction(
      rows.first,
      itemById: maps.itemById,
      supplierById: maps.supplierById,
      craftsmanById: maps.craftsmanById,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: InteractiveMovementCard(
              line: line,
              localeCode: 'ar',
              mutationsEnabled: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byTooltip('حذف'), findsNothing);
  });

  testWidgets('edit voucher sheet shows delete and cancel keeps ledger row', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'حذف');
    final project = (await repo.primaryActiveProject(client.id))!;
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'receive',
      amountPiastres: 100000,
      date: DateTime(2025, 2, 1),
      method: 'cash',
    );
    final tx = (await repo.transactionsForProject(project.id)).single;
    final draft = (await voucherDraftFromTransaction(repo, tx))!;
    final before = (await repo.transactionsForProject(project.id)).length;

    await tester.binding.setSurfaceSize(const Size(440, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repo),
          voucherDraftProvider.overrideWith((ref) => draft),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: Scaffold(
              body: SizedBox(height: 700, child: VoucherSheet()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppButton, 'حذف'), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'حذف'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('حذف الحركة دي؟'), findsOneWidget);

    await tester.tap(find.text('إلغاء'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final after = (await repo.transactionsForProject(project.id)).length;
    expect(after, before);
  });

  testWidgets('new voucher sheet has no delete action', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repo),
          voucherDraftProvider.overrideWith((ref) => VoucherDraft.fresh),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: Scaffold(body: SizedBox(height: 500, child: VoucherSheet())),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppButton, 'حذف'), findsNothing);
  });
}
