import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/resources/gen/assets.gen.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../app/widgets/shell_nav_icon.dart';
import '../../../l10n/app_localizations.dart';

class ClientDetailActionGrid extends StatelessWidget {
  const ClientDetailActionGrid({
    super.key,
    required this.onReceive,
    required this.onSpend,
    required this.onStatement,
    required this.onArchive,
    required this.isArchived,
    this.mutationsEnabled = true,
    this.onlineIdentityOnly = false,
    this.onDelete,
  });

  final VoidCallback onReceive;
  final VoidCallback onSpend;
  final VoidCallback onStatement;
  final VoidCallback onArchive;
  final VoidCallback? onDelete;
  final bool isArchived;
  final bool mutationsEnabled;
  final bool onlineIdentityOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    if (onlineIdentityOnly) {
      return Row(
        children: [
          if (!isArchived)
            Expanded(
              child: _ActionTile(
                key: const Key('client_detail_action_archive'),
                label: l10n.archive,
                tint: colors.onSurfaceMuted,
                tintBg: colors.surfaceSunken,
                icon: Assets.icons.archiveRestoreOutline,
                onPressed: onArchive,
                enabled: mutationsEnabled,
              ),
            ),
          if (!isArchived && onDelete != null) AppSize.spaceSM.gap,
          if (onDelete != null)
            Expanded(
              child: _ActionTile(
                key: const Key('client_detail_action_delete'),
                label: l10n.delete,
                tint: colors.spend,
                tintBg: colors.errorBg,
                icon: Assets.icons.deleteSquareOutline,
                onPressed: onDelete!,
                enabled: true,
              ),
            ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            key: const Key('client_detail_action_receive'),
            label: l10n.receive,
            tint: colors.receive,
            tintBg: colors.successBg,
            icon: Assets.icons.arrowDownLeftCircleOutline,
            onPressed: onReceive,
            enabled: mutationsEnabled,
          ),
        ),
        AppSize.spaceSM.gap,
        Expanded(
          child: _ActionTile(
            key: const Key('client_detail_action_spend'),
            label: l10n.spend,
            tint: colors.spend,
            tintBg: colors.errorBg,
            icon: Assets.icons.arrowUpRightCircleOutline,
            onPressed: onSpend,
            enabled: mutationsEnabled,
          ),
        ),
        AppSize.spaceSM.gap,
        Expanded(
          child: _ActionTile(
            key: const Key('client_detail_action_statement'),
            label: l10n.statement,
            tint: colors.primary,
            tintBg: colors.accentTeal.tint,
            icon: Assets.icons.documentAttachmentOutline,
            onPressed: onStatement,
            enabled: mutationsEnabled,
          ),
        ),
        AppSize.spaceSM.gap,
        if (!isArchived)
          Expanded(
            child: _ActionTile(
              key: const Key('client_detail_action_archive'),
              label: l10n.archive,
              tint: colors.onSurfaceMuted,
              tintBg: colors.surfaceSunken,
              icon: Assets.icons.archiveRestoreOutline,
              onPressed: onArchive,
              enabled: mutationsEnabled,
            ),
          ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.label,
    required this.tint,
    required this.tintBg,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final Color tint;
  final Color tintBg;
  final SvgGenImage icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelStyle = context.text.caption.copyWith(
      fontWeight: FontWeight.w700,
      color: enabled ? colors.onSurface : colors.onSurfaceMuted,
    );
    final iconColor = enabled ? tint : colors.onSurfaceMuted;
    final iconBg = enabled ? tintBg : colors.surfaceSunken;
    return AppPressable(
      enabled: enabled,
      onPressed: onPressed,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceXS, vertical: AppSize.spaceMD),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: iconBg,
                shape: AppShape.superellipse(radius: AppSize.radiusSM),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: AppSize.buttonHeight,
                  height: AppSize.buttonHeight,
                  child: Center(child: ShellNavIcon(asset: icon, color: iconColor, size: AppSize.icon)),
                ),
              ),
              AppSize.spaceXS.gap,
              Text(label, style: labelStyle, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
