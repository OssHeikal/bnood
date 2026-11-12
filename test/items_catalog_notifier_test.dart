import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/items/item_api_record.dart';
import 'package:bnood/core/items/items_providers.dart';
import 'package:bnood/core/items/items_repository.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/items/items_catalog_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bnood/core/api/items_api.dart';

class _RecordingItemsRepository extends ItemsRepository {
  _RecordingItemsRepository(this._items) : super(ItemsApi());

  List<CatalogItem> _items;
  List<List<String>> reorderCalls = [];
  Object? reorderError;

  @override
  Future<ItemsListPage> listItems({String? q, int page = 1, int perPage = 50}) async {
    return ItemsListPage(items: _items, page: 1, perPage: perPage, total: _items.length);
  }

  @override
  Future<void> reorderItems(List<String> ids) async {
    reorderCalls.add(ids);
    if (reorderError != null) {
      throw reorderError!;
    }
  }
}

void main() {
  final now = DateTime.utc(2026, 11, 11);

  CatalogItem catalogItem(String id, {bool isDefault = false}) => CatalogItem(
        id: id,
        name: id,
        iconKey: 'layers',
        colorKey: 'teal',
        isDefault: isDefault,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );

  ProviderContainer container(_RecordingItemsRepository repo) {
    return ProviderContainer(overrides: [
      itemsRepositoryProvider.overrideWithValue(repo),
      authControllerProvider.overrideWith(() => _AuthStub()),
    ]);
  }

  test('reorderCatalogItem sends full id list and reverts on failure', () async {
    final repo = _RecordingItemsRepository([
      catalogItem('a'),
      catalogItem('b'),
      catalogItem('d', isDefault: true),
    ]);
    final c = container(repo);
    addTearDown(c.dispose);

    c.read(itemsCatalogProvider.notifier).state = AsyncValue.data([
      catalogItem('a'),
      catalogItem('b'),
      catalogItem('d', isDefault: true),
    ]);

    await c.read(itemsCatalogProvider.notifier).reorderCatalogItem(oldIndex: 0, newIndex: 2);
    expect(repo.reorderCalls.single, ['b', 'd', 'a']);
    expect(c.read(itemsCatalogProvider).value!.map((e) => e.id), ['b', 'd', 'a']);

    repo.reorderError = AuthApiException(statusCode: 422, message: 'reorder_invalid');
    await expectLater(
      c.read(itemsCatalogProvider.notifier).reorderCatalogItem(oldIndex: 1, newIndex: 0),
      throwsA(isA<AuthApiException>()),
    );
    expect(c.read(itemsCatalogProvider).value!.map((e) => e.id), ['b', 'd', 'a']);
  });
}

class _AuthStub extends AuthController {
  @override
  AuthState build() => AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        bootstrapStarted: true,
        user: User(id: 'u1', phone: '+201012345678', name: 'Test'),
      );
}
