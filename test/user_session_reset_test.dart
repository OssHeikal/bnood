import 'package:bnood/core/api/home_api.dart';
import 'package:bnood/core/clients/clients_providers.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/core/home/app_home_dashboard.dart';
import 'package:bnood/core/home/home_riverpod.dart';
import 'package:bnood/core/home/home_repository.dart';
import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/session/user_session_lifecycle.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'support/fake_session_store.dart';

class _SwitchingHomeRepository extends HomeRepository {
  _SwitchingHomeRepository(this._receivedForUser)
      : super(HomeApi(sessionStore: FakeSessionStore()));

  final int Function(String? userId) _receivedForUser;

  @override
  Future<AppHomeDashboard> getHomeDashboard() async {
    final userId = _currentUserId;
    return AppHomeDashboard.fromDataJson({
      'received': _receivedForUser(userId),
      'spent': 0,
      'remaining': _receivedForUser(userId),
      'clients': const [],
      'craftsmen': const [],
      'suppliers': const [],
    });
  }

  static String? _currentUserId;

  static void bindUser(String? userId) => _currentUserId = userId;
}

User _user(String id, String name) => User(
      id: id,
      phone: '+201000000001',
      name: name,
      phoneVerifiedAt: DateTime.utc(2026),
    );

void main() {
  test('logout then login as another user reloads home without manual refresh', () async {
    final store = FakeSessionStore();
    final container = ProviderContainer(
      overrides: [
        sessionStoreProvider.overrideWithValue(store),
        remoteClientsEnabledProvider.overrideWithValue(true),
        homeRepositoryProvider.overrideWith(
          (ref) => _SwitchingHomeRepository((userId) => userId == 'user-a' ? 1_000_000 : 9_000_000),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(userSessionLifecycleProvider);

    final auth = container.read(authControllerProvider.notifier);
    _SwitchingHomeRepository.bindUser('user-a');
    auth.adoptSessionForTest(_user('user-a', 'Account A'));
    final totalsA = await container.read(homeTotalsProvider.future);
    expect(totalsA.receivedPiastres, 1_000_000);

    await auth.logout();
    _SwitchingHomeRepository.bindUser('user-b');
    auth.adoptSessionForTest(_user('user-b', 'Account B'));

    final totalsB = await container.read(homeTotalsProvider.future);
    expect(totalsB.receivedPiastres, 9_000_000);
    expect(totalsB.receivedPiastres, isNot(totalsA.receivedPiastres));
  });
}
