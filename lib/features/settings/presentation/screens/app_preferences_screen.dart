import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/layout/bnood_list_canvas.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/settings/presentation/widgets/app_preferences_body.dart';

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
