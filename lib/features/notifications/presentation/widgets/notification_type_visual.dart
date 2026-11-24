import 'package:flutter/material.dart';

import '../../../../core/network/push/push_payload_routing.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/ui/resources/gen/assets.gen.dart';

class NotificationTypeVisual {
  const NotificationTypeVisual({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final SvgGenImage icon;
  final Color foreground;
  final Color background;

  static NotificationTypeVisual resolve(
    BuildContext context, {
    required String type,
    Map<String, dynamic> data = const {},
  }) {
    final colors = context.colors;
    final target = data['target']?.toString().trim();

    if (type == PushPayloadType.lowBalance) {
      return NotificationTypeVisual(
        icon: Assets.icons.balanceWalletOutline,
        foreground: colors.warning,
        background: colors.warningBg,
      );
    }
    if (type == PushPayloadType.subscriptionExpiry) {
      return NotificationTypeVisual(
        icon: Assets.icons.crownOutline,
        foreground: colors.primaryOnTint,
        background: colors.primaryTint,
      );
    }
    if (type == PushPayloadType.broadcast ||
        type == PushPayloadType.adminBroadcast) {
      if (target == PushBroadcastTarget.subscription) {
        return NotificationTypeVisual(
          icon: Assets.icons.crownOutline,
          foreground: colors.primaryOnTint,
          background: colors.primaryTint,
        );
      }
      return NotificationTypeVisual(
        icon: Assets.icons.notification,
        foreground: colors.primary,
        background: colors.primaryTint,
      );
    }
    return NotificationTypeVisual(
      icon: Assets.icons.infoCircleOutline,
      foreground: colors.onSurfaceMuted,
      background: colors.primarySoft,
    );
  }
}