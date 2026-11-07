import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/providers/dashboard_providers.dart';
import '../../../core/repositories/bnood_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_pressable.dart';

class ClientsListFilterChips extends ConsumerWidget {
  const ClientsListFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final filter = ref.watch(clientsListFilterProvider);

    void select(ClientListArchiveFilter next) {
      if (filter == next) return;
      ref.read(clientsListFilterProvider.notifier).state = next;
      ref.read(clientsListBalancesProvider.notifier).refreshSilently();
    }

    return Row(
      children: [
        Expanded(
          child: _FilterChip(
            key: const Key('clients_filter_all'),
            label: l10n.clientsFilterAll,
            selected: filter == ClientListArchiveFilter.all,
            onTap: () => select(ClientListArchiveFilter.all),
            colors: colors,
            text: text,
          ),
        ),
        AppSize.spaceSM.gap,
        Expanded(
          child: _FilterChip(
            key: const Key('clients_filter_active'),
            label: l10n.clientsFilterActive,
            selected: filter == ClientListArchiveFilter.active,
            onTap: () => select(ClientListArchiveFilter.active),
            colors: colors,
            text: text,
          ),
        ),
        AppSize.spaceSM.gap,
        Expanded(
          child: _FilterChip(
            key: const Key('clients_filter_archived'),
            label: l10n.clientsFilterArchived,
            selected: filter == ClientListArchiveFilter.archived,
            onTap: () => select(ClientListArchiveFilter.archived),
            colors: colors,
            text: text,
          ),
        ),
      ],
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
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              label,
              style: text.bodyEmphasis.copyWith(
                color: selected ? colors.onPrimary : colors.onSurfaceMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
