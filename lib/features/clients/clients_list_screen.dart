import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_shape.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/custom_bottom_sheet.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../home/home_foundation_scope.dart';
import '../home/widgets/home_loading_skeleton.dart';
import '../vouchers/inline_create_routes.dart';
import 'widgets/client_balance_card.dart';
import 'widgets/clients_list_filter_chips.dart';

class ClientsListScreen extends ConsumerWidget {
  const ClientsListScreen({super.key});

  Future<void> _addClient(BuildContext context, WidgetRef ref) async {
    final createdId = await CustomBottomSheet.show<String?>(
      context: context,
      builder: (_) => const InlineCreateClientPage(padForSystemChrome: false),
      nestedNavigator: false,
      showDragHandle: false,
    );
    if (createdId != null) {
      refreshAfterClientMutation(ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final filter = ref.watch(clientsListFilterProvider);
    final balances = ref.watch(clientsListBalancesProvider);

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final text = context.text;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: AppBar(
              backgroundColor: colors.canvas,
              elevation: 0,
              title: Text(l10n.navClients, style: text.pageTitle),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSize.screenPadding,
                    0,
                    AppSize.screenPadding,
                    AppSize.spaceSM,
                  ),
                  child: ClientsListFilterChips(),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSize.spaceMD),
                  child: Tooltip(
                    message: l10n.addClient,
                    child: AppPressable(
                      onPressed: () => _addClient(context, ref),
                      child: Material(
                        key: const Key('clients_app_bar_add'),
                        color: colors.accentTeal.tint,
                        shape: AppShape.superellipse(radius: AppSize.radiusSM),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: AppSize.buttonHeight,
                          height: AppSize.buttonHeight,
                          child: Center(
                            child: ShellNavIcon(
                              asset: Assets.icons.clientsAddOutline,
                              color: colors.primaryOnTint,
                              size: AppSize.icon,
                              semanticsLabel: l10n.addClient,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                AppSize.spaceSM,
                AppSize.screenPadding,
                AppSize.spaceMD,
              ),
              children: [
                AsyncValueBody(
                  value: balances,
                  loadingPlaceholder: const HomePersonListSkeleton(count: 4),
                  error: (e, _) => AppCard(
                    child: AppFallback.section(
                      icon: Icons.error_outline,
                      title: l10n.homeLoadErrorTitle,
                      description: e.toString(),
                      actions: [
                        AppFallbackAction(
                          label: l10n.retry,
                          onPressed: () => ref.read(clientsListBalancesProvider.notifier).refreshSilently(),
                          role: AppFallbackActionRole.tertiary,
                        ),
                      ],
                    ),
                  ),
                  data: (rows) {
                    if (rows.isEmpty) {
                      final empty = switch (filter) {
                        ClientListArchiveFilter.archived => (
                            title: l10n.clientsNoArchivedTitle,
                            description: l10n.clientsNoArchivedDescription,
                            showAdd: false,
                          ),
                        ClientListArchiveFilter.all => (
                            title: l10n.clientsNoClientsTitle,
                            description: l10n.homeNoActiveClientsDescription,
                            showAdd: true,
                          ),
                        ClientListArchiveFilter.active => (
                            title: l10n.homeNoActiveClientsTitle,
                            description: l10n.homeNoActiveClientsDescription,
                            showAdd: true,
                          ),
                      };
                      return AppCard(
                        child: AppFallback.section(
                          icon: Icons.people_outline,
                          title: empty.title,
                          description: empty.description,
                          actions: [
                            if (empty.showAdd)
                              AppFallbackAction(
                                label: l10n.addClient,
                                onPressed: () => _addClient(context, ref),
                                role: AppFallbackActionRole.tertiary,
                              ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < rows.length; i++) ...[
                          if (i > 0) AppSize.spaceMD.gap,
                          ClientBalanceCard(
                            name: rows[i].client.name,
                            receivedPiastres: rows[i].receivedPiastres,
                            spentPiastres: rows[i].spentPiastres,
                            amountPiastres: rows[i].remainingPiastres,
                            accentKey: clientAccentKeyFor(rows[i].client.id),
                            localeCode: localeCode,
                            onTap: () => context.push('/clients/${rows[i].client.id}'),
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
