import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
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

  testWidgets('voucher sheet shows client supplier item craftsman labels from draft', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Osama');
    final project = (await repo.primaryActiveProject(client.id))!;
    final item = await repo.createItem(name: 'Tiles', colorKey: 'teal', iconName: 'category');
    final supplier = await repo.createSupplier(name: 'Ahmed Tiles');
    await repo.createCraftsman(name: 'Karim', phone: '010');

    await tester.binding.setSurfaceSize(const Size(440, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final seed = VoucherDraft(
      kind: 'spend',
      clientId: client.id,
      clientLabel: client.name,
      projectId: project.id,
      itemId: item.id,
      itemLabel: item.name,
      supplierId: supplier.id,
      supplierLabel: supplier.name,
      craftsmanId: null,
      expenseType: 'materials',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repo),
          voucherDraftProvider.overrideWith((ref) => seed),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: Scaffold(
              body: SizedBox(
                height: 874 * 0.88,
                width: 440,
                child: VoucherSheet(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Osama'), findsWidgets);
    expect(find.text('Tiles'), findsOneWidget);
    expect(find.text('Ahmed Tiles'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('draft mutation after pick updates selector value on sheet', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Osama');
    final project = (await repo.primaryActiveProject(client.id))!;

    await tester.binding.setSurfaceSize(const Size(440, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repo),
          voucherDraftProvider.overrideWith((ref) => VoucherDraft.fresh.copyWith(kind: 'spend')),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: Scaffold(
              body: SizedBox(
                height: 874 * 0.88,
                width: 440,
                child: VoucherSheet(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(VoucherSheet));
    final container = ProviderScope.containerOf(element);
    container.read(voucherDraftProvider.notifier).state = VoucherDraft(
      kind: 'spend',
      clientId: client.id,
      clientLabel: client.name,
      projectId: project.id,
      supplierId: null,
      supplierLabel: 'Ahmed Tiles',
      expenseType: 'materials',
    );
    await tester.pumpAndSettle();

    expect(find.text('Osama'), findsWidgets);
    expect(find.text('Ahmed Tiles'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
