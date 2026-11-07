import 'dart:async';

import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/items/items_catalog_provider.dart';
import 'package:bnood/features/items/items_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap({
    required Widget child,
    required List<Override> overrides,
    Locale locale = const Locale('ar'),
    Size size = const Size(390, 844),
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, appChild) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: size,
              padding: itemsScreenMediaQueryForTests(context),
              disableAnimations: true,
            ),
            child: HomeFoundationScope(child: appChild!),
          );
        },
        home: child,
      ),
    );
  }

  testWidgets('items catalog shows skeleton until first stream value', (tester) async {
    final controller = StreamController<List<Item>>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      wrap(
        child: const ItemsScreen(),
        overrides: [
          itemsCatalogProvider.overrideWith((ref) => controller.stream),
        ],
      ),
    );
    await tester.pump();
    expect(find.byType(Skeleton), findsWidgets);

    controller.add([]);
    await tester.pumpAndSettle();
    expect(find.byType(Skeleton), findsNothing);
  });

  testWidgets('items grid renders seeded catalog RTL', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final items = await repo.watchActiveItems().first;
    expect(items, isNotEmpty);
    final firstName = items.first.name;

    await tester.pumpWidget(
      wrap(
        child: const ItemsScreen(),
        overrides: [repositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('items_catalog_grid')), findsOneWidget);
    expect(find.text(firstName), findsOneWidget);
    expect(find.textContaining('الإضافة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('create item rejects empty name in sheet', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    await tester.pumpWidget(
      wrap(
        child: const ItemsScreen(),
        overrides: [repositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('items_app_bar_add')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('اكتب اسم البند'), findsOneWidget);
  });

  testWidgets('create item updates grid without skeleton flash', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final before = await repo.watchActiveItems().first;

    await tester.pumpWidget(
      wrap(
        child: const ItemsScreen(),
        overrides: [repositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Skeleton), findsNothing);

    await tester.tap(find.byKey(const Key('items_app_bar_add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).last, 'بند اختبار');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('بند اختبار'), findsOneWidget);
    final after = await repo.watchActiveItems().first;
    expect(after.length, before.length + 1);
    expect(find.byType(Skeleton), findsNothing);
  });

  testWidgets('archive from edit sheet cancel keeps item', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    await repo.createItem(name: 'للأرشفة', colorKey: 'teal', iconName: 'category');

    await tester.pumpWidget(
      wrap(
        child: const ItemsScreen(),
        overrides: [repositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('للأرشفة'));
    await tester.pumpAndSettle();
    expect(find.text('تعديل البند'), findsOneWidget);
    await tester.tap(find.text('أرشفة').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect(find.text('للأرشفة'), findsOneWidget);
  });

  testWidgets('archive from edit sheet confirm removes item from grid', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final custom = await repo.createItem(name: 'للأرشفة', colorKey: 'teal', iconName: 'category');

    await tester.pumpWidget(
      wrap(
        child: const ItemsScreen(),
        overrides: [repositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('للأرشفة'));
    await tester.pumpAndSettle();
    expect(find.text('تعديل البند'), findsOneWidget);
    await tester.tap(find.text('أرشفة').last);
    await tester.pumpAndSettle();
    final dialog = find.byType(Dialog);
    await tester.tap(find.descendant(of: dialog, matching: find.text('أرشفة')));
    await tester.pumpAndSettle();

    expect(find.text('للأرشفة'), findsNothing);
    final stored = await repo.getItem(custom.id);
    expect(stored, isNotNull);
    expect(stored!.archivedAt, isNotNull);
    final active = await repo.watchActiveItems().first;
    expect(active.any((i) => i.id == custom.id), isFalse);
  });

  testWidgets('tap tile opens edit sheet', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final item = await repo.createItem(name: 'للتعديل', colorKey: 'gold', iconName: 'layers');

    await tester.pumpWidget(
      wrap(
        child: const ItemsScreen(),
        overrides: [repositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('للتعديل'));
    await tester.pumpAndSettle();
    expect(find.text('تعديل البند'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).last, 'بعد التعديل');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('بعد التعديل'), findsOneWidget);
    final updated = await repo.getItem(item.id);
    expect(updated?.name, 'بعد التعديل');
  });
}
