import 'package:bnood/core/items/item_api_record.dart';
import 'package:bnood/core/items/items_providers.dart';
import 'package:bnood/core/items/items_repository.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/items/items_list_paging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bnood/core/api/items_api.dart';

class _FakeItemsRepository extends ItemsRepository {
  _FakeItemsRepository() : super(ItemsApi());

  int lastPage = 0;

  @override
  Future<ItemsListPage> listItems({
    String? q,
    int page = 1,
    int perPage = 50,
  }) async {
    lastPage = page;
    final now = DateTime.utc(2026, 11, 9);
    if (page == 1) {
      return ItemsListPage(
        items: [
          CatalogItem(
            id: 'a',
            name: 'A',
            iconKey: 'category',
            colorKey: 'teal',
            isDefault: true,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        page: 1,
        perPage: perPage,
        total: 60,
      );
    }
    return ItemsListPage(items: const [], page: 2, perPage: perPage, total: 60);
  }
}

void main() {
  test('items list fetcher pages when remote enabled', () async {
    final user = User(id: 'u1', phone: '+201000000000', name: 'Test');
    final container = ProviderContainer(overrides: [
      itemsRepositoryProvider.overrideWithValue(_FakeItemsRepository()),
      authControllerProvider.overrideWith(() => _AuthStub(user)),
    ]);
    addTearDown(container.dispose);

    final fetch = container.read(itemsListPageFetcherProvider);
    final page1 = await fetch(page: 1, pageSize: 50);
    expect(page1.hasMore, isTrue);
    expect(page1.items.single.isDefault, isTrue);

    final page2 = await fetch(page: 2, pageSize: 50);
    expect(page2.hasMore, isFalse);
  });
}

class _AuthStub extends AuthController {
  _AuthStub(this._user);

  final User _user;

  @override
  AuthState build() => AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: _user,
        bootstrapStarted: true,
      );
}
