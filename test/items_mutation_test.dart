import 'package:bnood/core/network/api/auth_api_exception.dart';
import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/features/items/data/item_api_record.dart'
    show ItemDeleteResult;
import 'package:bnood/features/items/data/items_api.dart';
import 'package:bnood/features/items/data/items_providers.dart';
import 'package:bnood/features/items/data/items_repository.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/items/presentation/actions/item_mutation_actions.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('duplicateItemNameFieldError maps 422 duplicate_name', (
    tester,
  ) async {
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
    final error = AuthApiException(
      statusCode: 422,
      message: 'dup',
      code: 'duplicate_name',
    );
    expect(
      duplicateItemNameFieldError(l10n, error),
      l10n.itemDuplicateNameError,
    );
  });

  testWidgets(
    'confirmDeleteItem confirms then runs unified delete (no archive prompt)',
    (tester) async {
      final deletedIds = <String>[];
      final botToastBuilder = BotToastInit();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemsRepositoryProvider.overrideWithValue(
              _UnifiedDeleteRepo(
                onDelete: deletedIds.add,
                result: ItemDeleteResult.archived,
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

      expect(deletedIds, ['01X']);
      expect(find.text('Archive'), findsNothing);
    },
  );
}

class _UnifiedDeleteRepo extends ItemsRepository {
  _UnifiedDeleteRepo({required this.onDelete, required this.result})
    : super(ItemsApi());

  final void Function(String id) onDelete;
  final ItemDeleteResult result;

  @override
  Future<ItemDeleteResult> deleteItem(String id) async {
    onDelete(id);
    return result;
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
          onPressed: () =>
              confirmDeleteItem(context, ref, itemId: itemId, name: name),
          child: const Text('Delete item'),
        ),
      ),
    );
  }
}
