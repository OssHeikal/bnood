import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/layout/bnood_list_canvas.dart';
import '../../../../core/ui/resources/gen/assets.gen.dart';
import '../../../../core/ui/widgets/app_fallback.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';

/// Placeholder until a notifications inbox API exists.
class NotificationsInboxPlaceholderScreen extends StatelessWidget {
  const NotificationsInboxPlaceholderScreen({super.key});

  static const path = '/notifications';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HomeFoundationScope(
      child: Scaffold(
        appBar: CustomAppBar(title: l10n.notificationSettingsTitle),
        body: BnoodListCanvas(
          child: Padding(
            padding: const EdgeInsets.all(AppSize.screenPadding),
            child: AppFallback.section(
              leading: Assets.icons.emptyInboxOutline.svg(
                width: AppSize.iconExtraLarge,
                height: AppSize.iconExtraLarge,
              ),
              title: l10n.notificationsInboxTitle,
              description: l10n.notificationsInboxDescription,
            ),
          ),
        ),
      ),
    );
  }
}