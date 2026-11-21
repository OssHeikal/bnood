import 'package:flutter/material.dart';

import '../features/providers/presentation/providers_screen.dart';

/// Directory shell branch — online providers catalog.
class AppShellDirectoryBody extends StatelessWidget {
  const AppShellDirectoryBody({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return const ProvidersScreen();
  }
}