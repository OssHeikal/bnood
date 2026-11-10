import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../core/config/theme/app_size.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../home/home_foundation_scope.dart';
import 'app_menu_body.dart';

/// Full-screen **Menu** (formerly settings hub).
class AppMenuScreen extends StatelessWidget {
  const AppMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HomeFoundationScope(
      child: Scaffold(
        appBar: CustomAppBar(title: l10n.menuTitle),
        body: const SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: AppSize.spaceMD),
          child: AppMenuBody(),
        ),
      ),
    );
  }
}

/// @deprecated Use [AppMenuScreen]. Kept for incremental test/import migration.
typedef AppSettingsScreen = AppMenuScreen;
