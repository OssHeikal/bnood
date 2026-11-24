import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/config/theme/app_colors.dart';
import '../../core/services/config/theme/app_size.dart';
import '../../core/ui/resources/gen/assets.gen.dart';
import '../../core/ui/widgets/custom_app_bar.dart';
import 'package:bnood/features/notifications/presentation/providers/notifications_unread_provider.dart';
import 'package:bnood/features/notifications/presentation/screens/notifications_inbox_screen.dart';
import 'shell_nav_icon.dart';

/// Notifications inbox action for the home shell app bar only.
class ShellNotificationsAction extends ConsumerWidget {
  const ShellNotificationsAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final unread = ref.watch(notificationsUnreadCountProvider).valueOrNull ?? 0;
    final colors = context.colors;

    return CustomAppBarAction(
      tooltip: l10n.notificationsScreenTitle,
      onPressed: () {
        refreshNotificationsUnreadCount(ref);
        context.push(NotificationsInboxScreen.path);
      },
      child: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        backgroundColor: colors.primary,
        textColor: colors.onPrimary,
        child: ShellNavIcon(
          asset: Assets.icons.notification,
          size: AppSize.icon,
          color: colors.onSurface,
          semanticsLabel: l10n.notificationsScreenTitle,
        ),
      ),
    );
  }
}