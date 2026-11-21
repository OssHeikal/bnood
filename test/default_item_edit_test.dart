import 'package:bnood/features/items/data/items_api.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/items/data/item_api_record.dart';
import 'package:bnood/features/items/data/items_providers.dart';
import 'package:bnood/features/items/data/items_repository.dart';
import 'package:bnood/features/home/presentation/home_foundation_scope.dart';
import 'package:bnood/features/items/presentation/item_edit_sheet.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 11, 9);

  CatalogItem defaultItem({bool customized = false}) => CatalogItem(
        id: 'def-1',
        name: customized ? 'My label' : 'افتراضي',
        iconKey: 'category',
        colorKey: 'gold',
        isDefault: true,
        isCustomized: customized,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );

  Widget harness({required ItemsRepository repo, required Locale locale, required CatalogItem item}) {
    return ProviderScope(
      overrides: [
        itemsRepositoryProvider.overrideWithValue(repo),
        itemIconsCatalogProvider.overrideWith(
          (ref) async => const ItemIconsCatalog(
            colors: [
              ItemColorOption(key: 'gold', hex: '#C9A227'),
              ItemColorOption(key: 'pink', hex: '#D4569C'),
            ],
            iconKeys: ['category', 'layers'],
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        home: HomeFoundationScope(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => showItemEditSheet(context, item: item),
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('default item edit sheet shows only save + delete and a color picker', (tester) async {
    await tester.pumpWidget(
      harness(repo: _TrackingRepo(), locale: const Locale('ar'), item: defaultItem(customized: true)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('حذف'), findsOneWidget);
    expect(find.text('أرشفة'), findsNothing);
    expect(find.text('رجوع للأصلي'), findsNothing);
    expect(find.byKey(const ValueKey('item_color_pink')), findsOneWidget);
    expect(find.byKey(const ValueKey('item_icon_layers')), findsOneWidget);
  });

  testWidgets('editing a default item sends the chosen color', (tester) async {
    final repo = _TrackingRepo();
    await tester.pumpWidget(harness(repo: repo, locale: const Locale('en'), item: defaultItem()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('item_color_pink')));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(repo.updatedColorKey, 'pink');
  });

  testWidgets('delete on a default item runs the unified delete', (tester) async {
    final repo = _TrackingRepo();
    await tester.pumpWidget(harness(repo: repo, locale: const Locale('en'), item: defaultItem()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('item_edit_delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(repo.deletedIds, ['def-1']);
  });
}

class _TrackingRepo extends ItemsRepository {
  _TrackingRepo() : super(ItemsApi());

  final deletedIds = <String>[];
  String? updatedColorKey;

  @override
  Future<ItemDeleteResult> deleteItem(String id) async {
    deletedIds.add(id);
    return ItemDeleteResult.archived;
  }

  @override
  Future<CatalogItem> updateItem({required String id, String? name, String? iconKey, String? colorKey}) async {
    updatedColorKey = colorKey;
    final now = DateTime.utc(2026, 11, 9);
    return CatalogItem(
      id: id,
      name: name ?? 'Default',
      iconKey: iconKey ?? 'category',
      colorKey: colorKey ?? 'gold',
      isDefault: true,
      isCustomized: true,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }
}
