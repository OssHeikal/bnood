import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/items/item_api_record.dart';
import 'package:bnood/core/api/items_api.dart';
import 'package:bnood/core/items/items_providers.dart';
import 'package:bnood/core/items/items_repository.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/items/item_mutation_actions.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('duplicateItemNameFieldError maps 422 duplicate_name', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    final error = AuthApiException(statusCode: 422, message: 'dup', code: 'duplicate_name');
    expect(duplicateItemNameFieldError(l10n, error), l10n.itemDuplicateNameError);
  });

  testWidgets('confirmDeleteItem on 409 offers archive', (tester) async {
    var archived = false;
    final botToastBuilder = BotToastInit();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemsRepositoryProvider.overrideWithValue(_InUseItemsRepo(onArchive: () => archived = true)),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: botToastBuilder,
          navigatorObservers: [BotToastNavigatorObserver()],
          home: const HomeFoundationScope(
            child: _DeleteItemHarness(itemId: '01X', name: 'Tiles'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Item is in use'), findsOneWidget);
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(archived, isTrue);
  });
}

class _InUseItemsRepo extends ItemsRepository {
  _InUseItemsRepo({required this.onArchive}) : super(ItemsApi());

  final VoidCallback onArchive;

  @override
  Future<void> deleteItem(String id) async {
    throw AuthApiException(statusCode: 409, message: 'in use', code: 'item_in_use');
  }

  @override
  Future<CatalogItem> archiveItem(String id) async {
    onArchive();
    final now = DateTime.utc(2026, 11, 9);
    return CatalogItem(
      id: id,
      name: 'Tiles',
      iconKey: 'layers',
      colorKey: 'teal',
      isDefault: false,
      sortOrder: 1,
      createdAt: now,
      updatedAt: now,
      archivedAt: now,
    );
  }
}

class _DeleteItemHarness extends ConsumerWidget {
  const _DeleteItemHarness({required this.itemId, required this.name});

  final String itemId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => confirmDeleteItem(context, ref, itemId: itemId, name: name),
          child: const Text('Delete item'),
        ),
      ),
    );
  }
}
