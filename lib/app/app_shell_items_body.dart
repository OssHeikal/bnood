import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/items/items_screen.dart';
import 'app_shell_online_tabs.dart';

/// Items shell branch body. Remote sessions never mount this (see [AppShellTabGate]).
/// When [appRemoteItemsTabEnabledProvider] is enabled, swap in the online items screen.
class AppShellItemsBody extends ConsumerWidget {
  const AppShellItemsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(appRemoteItemsTabEnabledProvider)) {
      return const ItemsScreen();
    }
    return const SizedBox.shrink();
  }
}
