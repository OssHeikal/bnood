import 'package:bnood/core/api/items_api.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/items/item_api_record.dart';
import 'package:bnood/core/items/items_providers.dart';
import 'package:bnood/core/items/items_repository.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/items/item_edit_sheet.dart';
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

  testWidgets('customized default edit sheet shows reset to original', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemIconsCatalogProvider.overrideWith(
            (ref) async => const ItemIconsCatalog(
              colors: [ItemColorOption(key: 'gold', hex: '#000000')],
              iconKeys: ['category', 'layers'],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () => showItemEditSheet(context, item: defaultItem(customized: true)),
                      child: const Text('open'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('رجوع للأصلي'), findsOneWidget);
    expect(find.text('أرشفة'), findsOneWidget);
    expect(find.text('حذف'), findsNothing);
  });

  testWidgets('resetDefaultItemCustomization calls repository', (tester) async {
    var cleared = false;
    final repo = _ResetTrackingRepo(onClear: () => cleared = true);
    final botToastBuilder = BotToastInit();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemsRepositoryProvider.overrideWithValue(repo),
          itemIconsCatalogProvider.overrideWith(
            (ref) async => const ItemIconsCatalog(
              colors: [ItemColorOption(key: 'gold', hex: '#000000')],
              iconKeys: ['category'],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: botToastBuilder,
          navigatorObservers: [BotToastNavigatorObserver()],
          home: HomeFoundationScope(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () => showItemEditSheet(context, item: defaultItem(customized: true)),
                      child: const Text('open'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset to original'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(cleared, isTrue);
  });
}

class _ResetTrackingRepo extends ItemsRepository {
  _ResetTrackingRepo({required this.onClear}) : super(ItemsApi());

  final VoidCallback onClear;

  @override
  Future<CatalogItem> clearCustomization(String id) async {
    onClear();
    final now = DateTime.utc(2026, 11, 9);
    return CatalogItem(
      id: id,
      name: 'Default',
      iconKey: 'category',
      colorKey: 'gold',
      isDefault: true,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }
}