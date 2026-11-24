import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/widgets/app_card.dart';
import '../../../../app/widgets/shell_nav_icon.dart';
import 'package:bnood/features/notifications/data/inbox_notification_record.dart';
import 'notification_type_visual.dart';

class NotificationInboxCard extends StatelessWidget {
  const NotificationInboxCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final InboxNotificationRecord item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final visual = NotificationTypeVisual.resolve(
      context,
      type: item.type,
      data: item.data,
    );
    final locale = Localizations.localeOf(context).languageCode;
    final timeLabel = DateFormat.yMMMd(locale).add_jm().format(item.createdAt);

    return AppCard(
      onTap: onTap,
      borderColor: item.isUnread ? colors.primary.withValues(alpha: 0.35) : null,
      borderWidth: item.isUnread ? 1 : 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TypeDisc(visual: visual),
          const SizedBox(width: AppSize.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: text.cardTitle.copyWith(
                          fontWeight: item.isUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsetsDirectional.only(
                          start: AppSize.spaceXS,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSize.spaceXS),
                Text(
                  item.body,
                  style: text.body.copyWith(color: colors.onSurfaceMuted),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSize.spaceSM),
                Text(
                  timeLabel,
                  style: text.caption.copyWith(color: colors.onSurfaceMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeDisc extends StatelessWidget {
  const _TypeDisc({required this.visual});

  final NotificationTypeVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: visual.background,
        borderRadius: BorderRadius.circular(AppSize.radiusMD),
      ),
      child: ShellNavIcon(
        asset: visual.icon,
        size: AppSize.icon,
        color: visual.foreground,
      ),
    );
  }
}