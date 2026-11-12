import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../core/config/theme/app_size.dart';
import '../../core/layout/bnood_list_canvas.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../home/home_foundation_scope.dart';
import 'app_preferences_body.dart';

class AppPreferencesScreen extends StatelessWidget {
  const AppPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HomeFoundationScope(
      child: Scaffold(
        appBar: CustomAppBar(title: l10n.settingsTitle),
        body: const BnoodListCanvas(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: AppSize.spaceMD),
            child: AppPreferencesBody(),
          ),
        ),
      ),
    );
  }
}
