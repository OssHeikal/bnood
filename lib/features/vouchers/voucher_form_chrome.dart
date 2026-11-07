import 'package:flutter/material.dart';

import '../../core/config/extensions/text_style_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_motion.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_pressable.dart';

/// Prototype `toggle-pair`: receive (success) / spend (danger) — not Material [SegmentedButton].
class VoucherTogglePair extends StatelessWidget {
  const VoucherTogglePair({
    super.key,
    required this.receiveLabel,
    required this.spendLabel,
    required this.selectedKind,
    required this.onKindChanged,
    this.enabled = true,
  });

  final String receiveLabel;
  final String spendLabel;
  final String selectedKind;
  final ValueChanged<String> onKindChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final muted = colors.textTertiary;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.surfaceSunken, borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _ToggleSlot(
                label: receiveLabel,
                selected: selectedKind == 'receive',
                activeColor: colors.success,
                mutedColor: muted,
                enabled: enabled,
                onTap: () => onKindChanged('receive'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToggleSlot(
                label: spendLabel,
                selected: selectedKind == 'spend',
                activeColor: colors.spend,
                mutedColor: muted,
                enabled: enabled,
                onTap: () => onKindChanged('spend'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleSlot extends StatelessWidget {
  const _ToggleSlot({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.mutedColor,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final bool selected;
  final Color activeColor;
  final Color mutedColor;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : mutedColor;
    final bg = selected ? activeColor : Colors.transparent;
    return AppPressable(
      onPressed: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected
              ? [BoxShadow(color: activeColor.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(label, style: context.text.body.semiBold.setColor(fg)),
      ),
    );
  }
}

/// Prototype `.segmented` / expense category (خامات · مصنعية).
class VoucherExpenseSegment extends StatelessWidget {
  const VoucherExpenseSegment({
    super.key,
    required this.materialsLabel,
    required this.laborLabel,
    required this.selected,
    required this.onChanged,
  });

  final String materialsLabel;
  final String laborLabel;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return VoucherChipRow(
      options: [
        (value: 'materials', label: materialsLabel, icon: Assets.icons.materialsPackageOutline),
        (value: 'labor', label: laborLabel, icon: Assets.icons.laborHardHatOutline),
      ],
      selected: selected,
      onChanged: onChanged,
    );
  }
}

/// Prototype `pay-chips` (كاش · تحويل).
class VoucherPayChips extends StatelessWidget {
  const VoucherPayChips({
    super.key,
    required this.cashLabel,
    required this.transferLabel,
    required this.selected,
    required this.onChanged,
  });

  final String cashLabel;
  final String transferLabel;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return VoucherChipRow(
      options: [
        (value: 'cash', label: cashLabel, icon: Assets.icons.cashExchangeOutline),
        (value: 'transfer', label: transferLabel, icon: Assets.icons.cardTransferOutline),
      ],
      selected: selected,
      onChanged: onChanged,
    );
  }
}

class VoucherChipRow extends StatelessWidget {
  const VoucherChipRow({super.key, required this.options, required this.selected, required this.onChanged});

  final List<({String value, String label, SvgGenImage icon})> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AppPressable(
              onPressed: () => onChanged(options[i].value),
              child: Semantics(
                button: true,
                selected: selected == options[i].value,
                label: options[i].label,
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  height: AppSize.fieldHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.radiusMD),
                    border: Border.all(color: selected == options[i].value ? colors.primary : colors.outline),
                    color: selected == options[i].value ? colors.primaryTint : colors.surface,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      options[i].icon.svg(
                        width: AppSize.iconCompact,
                        height: AppSize.iconCompact,
                        colorFilter: ColorFilter.mode(
                          selected == options[i].value
                              ? colors.primaryDark
                              : colors.onSurfaceMuted,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: AppSize.spaceSM),
                      Text(
                        options[i].label,
                        style: context.text.body.semiBold.setColor(
                          selected == options[i].value ? colors.primaryDark : colors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
