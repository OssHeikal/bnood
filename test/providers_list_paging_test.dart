import 'package:bnood/core/api/providers_api.dart';
import 'package:bnood/core/providers_api/app_provider_record.dart';
import 'package:bnood/core/providers_api/providers_repository.dart';
import 'package:bnood/core/providers_api/providers_riverpod.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/providers/providers_list_paging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProvidersRepository extends ProvidersRepository {
  _FakeProvidersRepository() : super(ProvidersApi());

  AppProviderType? lastType;

  @override
  Future<ProvidersListPage> listProviders({
    String? q,
    AppProviderType? type,
    int page = 1,
    int perPage = 50,
  }) async {
    lastType = type;
    final now = DateTime.utc(2026, 11, 9);
    if (page == 1) {
      return ProvidersListPage(
        items: [
          AppProvider(
            id: 'a',
            name: 'A',
            phone: null,
            type: AppProviderType.supplier,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        page: 1,
        perPage: perPage,
        total: 60,
      );
    }
    return ProvidersListPage(items: const [], page: 2, perPage: perPage, total: 60);
  }
}

void main() {
  test('providers list fetcher pages and applies type filter', () async {
    final user = User(id: 'u1', phone: '+201000000000', name: 'Test');
    final fake = _FakeProvidersRepository();
    final container = ProviderContainer(overrides: [
      appProvidersRepositoryProvider.overrideWithValue(fake),
      authControllerProvider.overrideWith(() => _AuthStub(user)),
    ]);
    addTearDown(container.dispose);
    container.read(providersListTypeFilterProvider.notifier).state =
        ProvidersListTypeFilter.craftsman;

    final fetch = container.read(providersListPagingProvider);
    final page1 = await fetch(page: 1, pageSize: 50);
    expect(page1.hasMore, isTrue);
    expect(fake.lastType, AppProviderType.craftsman);

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
