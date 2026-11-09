import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers_api/providers_riverpod.dart';
import '../features/providers/providers_screen.dart';
import '../features/suppliers/directory_screen.dart';
import 'app_shell_online_tabs.dart';

/// Directory shell branch. Remote sessions use the online providers catalog when enabled.
class AppShellDirectoryBody extends ConsumerWidget {
  const AppShellDirectoryBody({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteCatalog =
        ref.watch(remoteProvidersEnabledProvider) && ref.watch(appRemoteProvidersTabEnabledProvider);
    if (remoteCatalog) {
      return const ProvidersScreen();
    }
    return DirectoryScreen(initialTabIndex: initialTabIndex);
  }
}
