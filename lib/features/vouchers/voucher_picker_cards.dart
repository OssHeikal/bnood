import 'package:flutter/material.dart';

import '../../core/config/extensions/text_style_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_shape.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/theme/app_colors.dart' as legacy;
import '../../core/utils/extensions/bidi_isolate.dart';
import '../../core/widgets/app_amount.dart';
import '../../core/widgets/entity_picker_row.dart';
import '../../features/clients/widgets/client_balance_card.dart';
import '../../features/items/item_semantic_icon.dart';
import '../../l10n/app_localizations.dart';

class VoucherPickerClientCard extends StatelessWidget {
  const VoucherPickerClientCard({
    super.key,
    required this.name,
    required this.clientId,
    required this.remainingPiastres,
    required this.localeCode,
    required this.selected,
    required this.onTap,
    this.showDivider = true,
  });

  final String name;
  final String clientId;
  final int remainingPiastres;
  final String localeCode;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  static const _leadingWidth = AppSize.hitMin;

  @override
  Widget build(BuildContext context) {
    final accent = legacy.AppColors.accent(clientAccentKeyFor(clientId));
    final l10n = AppLocalizations.of(context);
    return EntityPickerOptionRow(
      selected: selected,
      onSelect: onTap,
      leadingWidth: _leadingWidth,
      showDivider: showDivider,
      semanticLabel: name,
      leading: _InitialAvatar(initial: name.isNotEmpty ? name.characters.first : '?', accent: accent),
      title: name,
      subtitle: Row(
        children: [
          Text(l10n.remaining),
          const SizedBox(width: AppSize.spaceXS),
          AppAmount(
            piastres: remainingPiastres,
            role: AppAmountRole.remaining,
            size: AppAmountSize.small,
            localeCode: localeCode,
          ),
        ],
      ),
    );
  }
}

class VoucherPickerItemCard extends StatelessWidget {
  const VoucherPickerItemCard({
    super.key,
    required this.name,
    required this.colorKey,
    required this.iconName,
    required this.selected,
    required this.onTap,
    this.showDivider = true,
  });

  final String name;
  final String colorKey;
  final String iconName;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  static const _leadingWidth = AppSize.statIconBox;

  @override
  Widget build(BuildContext context) {
    final accent = itemSemanticAccentColor(colorKey);
    return EntityPickerOptionRow(
      selected: selected,
      onSelect: onTap,
      leadingWidth: _leadingWidth,
      showDivider: showDivider,
      semanticLabel: name,
      leading: Material(
        color: accent.withValues(alpha: 0.15),
        shape: AppShape.superellipse(radius: AppSize.radiusSM),
        clipBehavior: Clip.antiAlias,
        child: Center(
          child: itemSemanticIconWidget(iconKey: iconName, color: accent, size: AppSize.iconSmall),
        ),
      ),
      title: name,
    );
  }
}

class VoucherPickerCraftsmanCard extends StatelessWidget {
  const VoucherPickerCraftsmanCard({
    super.key,
    required this.name,
    required this.trade,
    required this.selected,
    required this.onTap,
    this.linkedToClient = false,
    this.showDivider = true,
  });

  final String name;
  final String? trade;
  final bool linkedToClient;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  static const _leadingWidth = AppSize.hitMin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitleText = trade?.trim();
    final l10n = AppLocalizations.of(context);
    return EntityPickerOptionRow(
      selected: selected,
      onSelect: onTap,
      leadingWidth: _leadingWidth,
      showDivider: showDivider,
      semanticLabel: name,
      leading: _InitialAvatar(initial: name.isNotEmpty ? name.characters.first : '?', accent: colors.primary),
      title: name,
      subtitle: subtitleText != null && subtitleText.isNotEmpty
          ? Text(subtitleText, maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: linkedToClient ? _LinkedToClientBadge(label: l10n.voucherProviderLinkedBadge) : null,
    );
  }
}

class VoucherPickerSupplierCard extends StatelessWidget {
  const VoucherPickerSupplierCard({
    super.key,
    required this.name,
    required this.phone,
    required this.selected,
    required this.onTap,
    this.linkedToClient = false,
    this.showDivider = true,
  });

  final String name;
  final String? phone;
  final bool linkedToClient;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  static const _leadingWidth = AppSize.hitMin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rawPhone = phone?.trim();
    final l10n = AppLocalizations.of(context);
    return EntityPickerOptionRow(
      selected: selected,
      onSelect: onTap,
      leadingWidth: _leadingWidth,
      showDivider: showDivider,
      semanticLabel: name,
      leading: _InitialAvatar(initial: name.isNotEmpty ? name.characters.first : '?', accent: colors.primaryDark),
      title: name,
      subtitle: rawPhone != null && rawPhone.isNotEmpty
          ? Text(
              LtrIsolate.isolate(rawPhone),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: linkedToClient ? _LinkedToClientBadge(label: l10n.voucherProviderLinkedBadge) : null,
    );
  }
}

class _LinkedToClientBadge extends StatelessWidget {
  const _LinkedToClientBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSize.screenPadding),
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.primaryTint, borderRadius: BorderRadius.circular(AppSize.radiusSM)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceSM, vertical: 2),
          child: Text(label, style: text.caption.semiBold.setColor(colors.primaryDark)),
        ),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initial, required this.accent});

  final String initial;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: AppShape.superellipse(radius: 14),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, Color.lerp(accent, Colors.black, 0.25)!],
          ),
        ),
        child: Center(
          child: Text(
            initial,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
