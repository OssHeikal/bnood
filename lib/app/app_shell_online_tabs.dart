import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clients/clients_providers.dart';

/// Flip to true when the online Items tab is ready (defined here to avoid editing `features/items`).
final appRemoteItemsTabEnabledProvider = Provider<bool>((ref) => true);

/// Flip to true when the online Directory (providers) tab is ready.
final appRemoteProvidersTabEnabledProvider = Provider<bool>((ref) => true);

/// Bottom-nav tabs in [ShellScaffold].
enum AppShellTabId {
  home,
  clients,
  directory,
  items,
}

/// Online/session gate for shell tab bodies (avoids local Drift on remote sessions).
final appShellTabOnlineProvider = Provider.family<bool, AppShellTabId>((ref, tab) {
  final remoteSession = ref.watch(remoteClientsEnabledProvider);
  if (!remoteSession) {
    return true;
  }
  return switch (tab) {
    AppShellTabId.clients => true,
    AppShellTabId.items => ref.watch(appRemoteItemsTabEnabledProvider),
    AppShellTabId.directory => ref.watch(appRemoteProvidersTabEnabledProvider),
    AppShellTabId.home => true,
  };
});
