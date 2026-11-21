import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Flip to true when the online Items tab is ready (defined here to avoid editing `features/items`).
final appRemoteItemsTabEnabledProvider = Provider<bool>((ref) => true);

/// Flip to true when the online Directory (providers) tab is ready.
final appRemoteProvidersTabEnabledProvider = Provider<bool>((ref) => true);

/// Bottom-nav tabs in [ShellScaffold].
enum AppShellTabId { home, clients, directory, items }

/// Shell tab bodies (all online in SLICE 1).
final appShellTabOnlineProvider = Provider.family<bool, AppShellTabId>((
  ref,
  tab,
) {
  return switch (tab) {
    AppShellTabId.clients => true,
    AppShellTabId.items => ref.watch(appRemoteItemsTabEnabledProvider),
    AppShellTabId.directory => ref.watch(appRemoteProvidersTabEnabledProvider),
    AppShellTabId.home => true,
  };
});
