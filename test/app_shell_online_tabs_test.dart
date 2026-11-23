import 'package:bnood/app/app_shell_online_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shell tabs online flags', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(appShellTabOnlineProvider(AppShellTabId.projects)),
      isTrue,
    );
    expect(
      container.read(appShellTabOnlineProvider(AppShellTabId.home)),
      isTrue,
    );
    expect(
      container.read(appShellTabOnlineProvider(AppShellTabId.providers)),
      isTrue,
    );
    expect(
      container.read(appShellTabOnlineProvider(AppShellTabId.more)),
      isTrue,
    );
  });

  test('items tab flag follows remote provider', () {
    final container = ProviderContainer(
      overrides: [
        appRemoteItemsTabEnabledProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(appRemoteItemsTabEnabledProvider), isFalse);
    expect(
      container.read(appShellTabOnlineProvider(AppShellTabId.home)),
      isTrue,
    );
  });
}