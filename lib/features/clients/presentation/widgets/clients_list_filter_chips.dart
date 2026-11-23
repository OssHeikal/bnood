import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_shape.dart';
import '../../../../core/services/config/theme/app_size.dart';
import 'package:bnood/features/clients/data/client_list_archive_filter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/widgets/app_pressable.dart';
import 'package:bnood/features/clients/presentation/providers/clients_list_providers.dart';

class ClientsListFilterChips extends ConsumerWidget {
  ClientsListFilterChips({
    super.key,
    StateProvider<ClientListArchiveFilter>? filterProvider,
  }) : filterProvider = filterProvider ?? clientsListFilterProvider;

  final StateProvider<ClientListArchiveFilter> filterProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final filter = ref.watch(filterProvider);

    void select(ClientListArchiveFilter next) {
      if (filter == next) return;
      ref.read(filterProvider.notifier).state = next;
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        spacing: AppSize.spaceSM,
        runSpacing: AppSize.spaceSM,
        children: [
          _FilterChip(
            key: const Key('clients_filter_all'),
            label: l10n.clientsFilterAll,
            selected: filter == ClientListArchiveFilter.all,
            onTap: () => select(ClientListArchiveFilter.all),
            colors: colors,
            text: text,
          ),
          _FilterChip(
            key: const Key('clients_filter_active'),
            label: l10n.clientsFilterActive,
            selected: filter == ClientListArchiveFilter.active,
            onTap: () => select(ClientListArchiveFilter.active),
            colors: colors,
            text: text,
          ),
          _FilterChip(
            key: const Key('clients_filter_archived'),
            label: l10n.clientsFilterArchived,
            selected: filter == ClientListArchiveFilter.archived,
            onTap: () => select(ClientListArchiveFilter.archived),
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
          constraints: const BoxConstraints(
            minHeight: AppSize.buttonHeightSmall,
          ),
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
