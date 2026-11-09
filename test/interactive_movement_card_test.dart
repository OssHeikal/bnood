import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/widgets/buttons/app_button.dart';
import 'package:bnood/features/clients/client_detail_snapshot.dart';
import 'package:bnood/features/clients/voucher_draft_from_transaction.dart';
import 'package:bnood/features/clients/widgets/interactive_movement_card.dart';
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
    final date = DateTime(2025, 2, 1);
    final line = ClientDetailMovementLine(
      transaction: Transaction(
        id: 't-card',
        workspaceId: 'w',
        projectId: 'p',
        kind: 'receive',
        amountPiastres: 100000,
        date: date,
        method: 'cash',
        description: null,
        receiptImagePath: null,
        itemId: null,
        expenseType: null,
        supplierId: null,
        craftsmanId: null,
        createdAt: date,
        updatedAt: date,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Scaffold(
              body: InteractiveMovementCard(
                line: line,
                localeCode: 'ar',
                mutationsEnabled: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.delete), findsNothing);
    expect(find.byType(IconButton), findsNothing);
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.widgetWithText(AppButton, 'حذف'), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'حذف'));
    await tester.pump();
    Object? dialogTitle;
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      final hit = find.text('حذف الحركة دي؟');
      if (hit.evaluate().isNotEmpty) {
        dialogTitle = hit;
        break;
      }
    }
    expect(dialogTitle, isNotNull);

    await tester.tap(find.text('إلغاء'));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('حذف الحركة دي؟').evaluate().isEmpty) break;
    }

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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.widgetWithText(AppButton, 'حذف'), findsNothing);
  });
}
