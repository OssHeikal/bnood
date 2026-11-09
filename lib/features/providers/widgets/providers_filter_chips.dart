import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_pressable.dart';
import '../providers_list_paging.dart';

class ProvidersListFilterChips extends ConsumerWidget {
  const ProvidersListFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final filter = ref.watch(providersListTypeFilterProvider);

    void select(ProvidersListTypeFilter next) {
      if (filter == next) return;
      ref.read(providersListTypeFilterProvider.notifier).state = next;
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        spacing: AppSize.spaceSM,
        runSpacing: AppSize.spaceSM,
        children: [
          _FilterChip(
            key: const Key('providers_filter_all'),
            label: l10n.providersFilterAll,
            selected: filter == ProvidersListTypeFilter.all,
            onTap: () => select(ProvidersListTypeFilter.all),
            colors: colors,
            text: text,
          ),
          _FilterChip(
            key: const Key('providers_filter_suppliers'),
            label: l10n.suppliers,
            selected: filter == ProvidersListTypeFilter.supplier,
            onTap: () => select(ProvidersListTypeFilter.supplier),
            colors: colors,
            text: text,
          ),
          _FilterChip(
            key: const Key('providers_filter_craftsmen'),
            label: l10n.craftsmen,
            selected: filter == ProvidersListTypeFilter.craftsman,
            onTap: () => select(ProvidersListTypeFilter.craftsman),
            colors: colors,
            text: text,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.text,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColors colors;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colors.primary : colors.surface,
      shape: AppShape.superellipse(radius: AppSize.radiusSM),
      clipBehavior: Clip.antiAlias,
      child: AppPressable(
        onPressed: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.buttonHeightSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                label,
                style: text.bodyEmphasis.copyWith(
                  color: selected ? colors.onPrimary : colors.onSurfaceMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
