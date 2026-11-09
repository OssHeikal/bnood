import 'package:bnood/app/app_shell_online_tabs.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('remote session: clients and items tabs are online', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(authControllerProvider.notifier).adoptSessionForTest(
          const User(id: 'u', phone: '+2010', name: 'Eng'),
        );

    expect(container.read(appShellTabOnlineProvider(AppShellTabId.clients)), isTrue);
    expect(container.read(appShellTabOnlineProvider(AppShellTabId.home)), isFalse);
    expect(container.read(appShellTabOnlineProvider(AppShellTabId.directory)), isTrue);
    expect(container.read(appShellTabOnlineProvider(AppShellTabId.items)), isTrue);
  });

  test('unsigned session treats all shell tabs as online', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(authControllerProvider), const AuthState());
    expect(container.read(appShellTabOnlineProvider(AppShellTabId.home)), isTrue);
    expect(container.read(appShellTabOnlineProvider(AppShellTabId.items)), isTrue);
  });
}
