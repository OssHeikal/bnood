import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../home/home_foundation_scope.dart';
import 'client_items_stats_provider.dart';
import 'widgets/client_detail_item_row.dart';
import 'widgets/client_items_stats_skeleton.dart';

class ClientItemsStatsScreen extends ConsumerWidget {
  const ClientItemsStatsScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final items = ref.watch(clientItemsStatsProvider(clientId));

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(title: l10n.navItems),
            body: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                AppSize.spaceSM,
                AppSize.screenPadding,
                AppSize.spaceMD + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                AsyncValueBody(
                  value: items,
                  loadingPlaceholder: const ClientItemsStatsSkeleton(),
                  error: (e, _) => AppCard(
                    child: AppFallback.section(
                      icon: Icons.error_outline,
                      title: l10n.homeLoadErrorTitle,
                      description: e.toString(),
                      actions: [
                        AppFallbackAction(
                          label: l10n.retry,
                          onPressed: () => ref.read(clientItemsStatsProvider(clientId).notifier).refreshSilently(),
                          role: AppFallbackActionRole.tertiary,
                        ),
                      ],
                    ),
                  ),
                  data: (rows) {
                    if (rows.isEmpty) {
                      return AppCard(
                        child: AppFallback.section(
                          icon: Icons.inventory_2_outlined,
                          title: l10n.clientDetailNoItemSpend,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < rows.length; i++) ...[
                          if (i > 0) AppSize.spaceMD.gap,
                          ClientDetailItemRow(
                            itemName: rows[i].name,
                            colorKey: rows[i].colorKey,
                            iconName: rows[i].iconName,
                            breakdown: rows[i].breakdown,
                            localeCode: localeCode,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
