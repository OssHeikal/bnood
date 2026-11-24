import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/config/theme/app_colors.dart';
import '../../core/services/config/theme/app_size.dart';
import '../../core/ui/resources/gen/assets.gen.dart';
import '../../core/ui/widgets/custom_app_bar.dart';
import 'package:bnood/features/notifications/presentation/screens/notifications_inbox_placeholder_screen.dart';
import 'shell_nav_icon.dart';

/// Notifications inbox action for the home shell app bar only.
class ShellNotificationsAction extends StatelessWidget {
  const ShellNotificationsAction({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CustomAppBarAction(
      tooltip: l10n.notificationSettingsTitle,
      onPressed: () => context.push(NotificationsInboxPlaceholderScreen.path),
      child: ShellNavIcon(
        asset: Assets.icons.notification,
        size: AppSize.icon,
        color: context.colors.onSurface,
        semanticsLabel: l10n.notificationSettingsTitle,
      ),
    );
  }
}