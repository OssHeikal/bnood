import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/craftsmen/craftsman_snapshot_limit.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/money/remote_money_units.dart';
import '../../core/formatting/see_all_label.dart';
import '../../core/home/home_section_counts.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_amount.dart';
import '../../core/widgets/app_fallback.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_paths.dart';
import '../providers/providers_list_paging.dart';
import '../providers/widgets/remote_craftsman_summary_card.dart';
import 'home_foundation_scope.dart';
import '../../core/widgets/app_card.dart';
import 'widgets/home_person_card.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import 'widgets/home_loading_skeleton.dart';
import 'widgets/home_section_header.dart';
import 'widgets/home_stat_grid.dart';
import 'widgets/home_identity_title.dart';
import '../suppliers/widgets/directory_person_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final user = ref.watch(authControllerProvider).user;
    final remoteMoney = ref.watch(remoteClientsEnabledProvider);
    final moneyScale = remoteMoney ? RemoteMoneyUnits.minorPerMajor : 100;
    final displayName = user?.name?.trim();
    final showIdentityHeader = remoteMoney && displayName != null && displayName.isNotEmpty;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final text = context.text;
          final totals = ref.watch(homeTotalsProvider);
          final clients = ref.watch(homeClientBalancesProvider);
          final suppliers = ref.watch(homeSupplierSpendsProvider);
          final craftsmen = ref.watch(homeCraftsmenProvider);
          final remoteSuppliers = ref.watch(homeSuppliersProvider);
          final sectionCounts = ref.watch(homeSectionCountsProvider);

          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(
              automaticallyImplyLeading: false,
              titleWidget: showIdentityHeader ? HomeIdentityTitle(displayName: displayName) : null,
              title: showIdentityHeader ? null : l10n.homeAppName,
              actions: [
                CustomAppBarAction(
                  tooltip: l10n.menuTitle,
                  onPressed: () => context.push(AuthPaths.settings),
                  child: ShellNavIcon(
                    asset: Assets.icons.menuTwoLineOutline,
                    size: AppSize.icon,
                    color: colors.onSurface,
                    semanticsLabel: l10n.menuTitle,
                  ),
                ),
              ],
            ),
            body: RefreshIndicator.adaptive(
              onRefresh: () => refreshHomeDashboard(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppSize.screenPadding,
                  AppSize.spaceMD,
                  AppSize.screenPadding,
                  bottomInset + AppSize.spaceMD,
                ),
                children: [
                  Text(l10n.homeTotalsCaption, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
                  AppSize.spaceMD.gap,
                  AsyncValueBody(
                    value: totals,
                    loadingPlaceholder: const HomeStatGridSkeleton(),
                    error: (e, _) => AppFallback(
                      isError: true,
                      icon: Icons.error_outline,
                      title: l10n.homeLoadErrorTitle,
                      description: e.toString(),
                      actionLabel: l10n.retry,
                      onAction: () => ref.read(homeTotalsProvider.notifier).refreshSilently(),
                    ),
                    data: (t) => HomeStatGrid(totals: t, localeCode: localeCode, minorPerMajor: moneyScale),
                  ),
                  AppSize.spaceXL.gap,
                  HomeSectionHeader(
                    title: l10n.activeClients,
                    seeAllLabel: seeAllLabelWithCount(
                      l10n,
                      sectionSeeAllCount(
                        total: sectionCounts.clientsCount,
                        visibleLength: clients.valueOrNull?.length ?? 0,
                      ),
                    ),
                    onSeeAll: () {
                      if (remoteMoney) {
                        ref.read(clientsListFilterProvider.notifier).state = ClientListArchiveFilter.active;
                      }
                      context.go('/clients');
                    },
                  ),
                  AppSize.spaceSM.gap,
                  AsyncValueBody(
                    value: clients,
                    loadingPlaceholder: const HomePersonListSkeleton(),
                    error: (e, _) => AppFallback(
                      isError: true,
                      icon: Icons.error_outline,
                      title: l10n.homeLoadErrorTitle,
                      description: e.toString(),
                      actionLabel: l10n.retry,
                      onAction: () => ref.read(homeClientBalancesProvider.notifier).refreshSilently(),
                    ),
                    data: (rows) {
                      if (rows.isEmpty) {
                        return AppCard(
                          child: AppFallback.section(
                            icon: Icons.people_outline,
                            title: l10n.homeNoActiveClientsTitle,
                            description: l10n.homeNoActiveClientsDescription,
                            actions: [
                              AppFallbackAction(
                                label: l10n.seeAll,
                                onPressed: () => context.go('/clients'),
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
                            HomePersonCard(
                              name: rows[i].client.name,
                              receivedPiastres: rows[i].receivedPiastres,
                              spentPiastres: rows[i].spentPiastres,
                              amountPiastres: rows[i].remainingPiastres,
                              accentKey: homeAccentKeyFor(rows[i].client.id),
                              localeCode: localeCode,
                              minorPerMajor: moneyScale,
                              onTap: () => context.push('/clients/${rows[i].client.id}'),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  AppSize.spaceXL.gap,
                  HomeSectionHeader(
                    title: l10n.homeCraftsmenSection,
                    seeAllLabel: seeAllLabelWithCount(
                      l10n,
                      sectionSeeAllCount(
                        total: sectionCounts.craftsmenCount,
                        visibleLength: craftsmanSnapshotRows(craftsmen.valueOrNull ?? const []).length,
                      ),
                    ),
                    onSeeAll: () {
                      if (remoteMoney) {
                        ref.read(providersListTypeFilterProvider.notifier).state = ProvidersListTypeFilter.craftsman;
                        context.go('/directory');
                      } else {
                        context.go('/directory?tab=craftsmen');
                      }
                    },
                  ),
                  AppSize.spaceSM.gap,
                  AsyncValueBody(
                    value: craftsmen,
                    loadingPlaceholder: const HomePersonListSkeleton(count: 1),
                    error: (e, _) => AppFallback(
                      isError: true,
                      icon: Icons.error_outline,
                      title: l10n.homeLoadErrorTitle,
                      description: e.toString(),
                      actionLabel: l10n.retry,
                      onAction: () => ref.read(homeCraftsmenProvider.notifier).refreshSilently(),
                    ),
                    data: (rows) {
                      final visible = craftsmanSnapshotRows(rows);
                      if (rows.isEmpty) {
                        return AppCard(
                          child: AppFallback.section(
                            leading: ShellNavIcon(
                              asset: Assets.icons.directoryOutline,
                              color: context.colors.muted,
                              size: AppSize.icon,
                            ),
                            title: l10n.homeNoCraftsmenTitle,
                            description: l10n.homeNoCraftsmenDescription,
                            actions: [
                              AppFallbackAction(
                                label: l10n.seeAll,
                                onPressed: () {
                                  if (remoteMoney) {
                                    ref.read(providersListTypeFilterProvider.notifier).state =
                                        ProvidersListTypeFilter.craftsman;
                                    context.go('/directory');
                                  } else {
                                    context.go('/directory?tab=craftsmen');
                                  }
                                },
                                role: AppFallbackActionRole.tertiary,
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (var i = 0; i < visible.length; i++) ...[
                            if (i > 0) AppSize.spaceMD.gap,
                            remoteMoney
                                ? RemoteCraftsmanSummaryCard(
                                    name: visible[i].craftsman.name,
                                    accentKey: homeAccentKeyFor(visible[i].craftsman.id),
                                    localeCode: localeCode,
                                    clientsCount: visible[i].clientsCount ?? 0,
                                    paidPiastres: visible[i].paidPiastres,
                                    remainingPiastres: visible[i].remainingPiastres,
                                    minorPerMajor: moneyScale,
                                    onTap: () => context.push('/providers/${visible[i].craftsman.id}'),
                                  )
                                : DirectoryPersonCard(
                                    name: visible[i].craftsman.name,
                                    trade: visible[i].craftsman.trade,
                                    paidPiastres: visible[i].paidPiastres,
                                    remainingPiastres: visible[i].remainingPiastres,
                                    paidInTrailing: true,
                                    accentKey: homeAccentKeyFor(visible[i].craftsman.id),
                                    localeCode: localeCode,
                                    showOverflowMenu: false,
                                    onOpenDetail: () => context.push('/craftsmen/${visible[i].craftsman.id}'),
                                  ),
                          ],
                        ],
                      );
                    },
                  ),
                  if (remoteMoney) ...[
                    AppSize.spaceXL.gap,
                    HomeSectionHeader(
                      title: l10n.homeSuppliersSection,
                      seeAllLabel: seeAllLabelWithCount(
                        l10n,
                        sectionSeeAllCount(
                          total: sectionCounts.suppliersCount,
                          visibleLength: craftsmanSnapshotRows(remoteSuppliers.valueOrNull ?? const []).length,
                        ),
                      ),
                      onSeeAll: () {
                        ref.read(providersListTypeFilterProvider.notifier).state =
                            ProvidersListTypeFilter.supplier;
                        context.go('/directory');
                      },
                    ),
                    AppSize.spaceSM.gap,
                    AsyncValueBody(
                      value: remoteSuppliers,
                      loadingPlaceholder: const HomePersonListSkeleton(count: 1),
                      error: (e, _) => AppFallback(
                        isError: true,
                        icon: Icons.error_outline,
                        title: l10n.homeLoadErrorTitle,
                        description: e.toString(),
                        actionLabel: l10n.retry,
                        onAction: () => ref.read(homeSuppliersProvider.notifier).refreshSilently(),
                      ),
                      data: (rows) {
                        final visible = craftsmanSnapshotRows(rows);
                        if (rows.isEmpty) {
                          return AppCard(
                            child: AppFallback.section(
                              leading: ShellNavIcon(
                                asset: Assets.icons.materialsPackageOutline,
                                color: context.colors.muted,
                                size: AppSize.icon,
                              ),
                              title: l10n.homeNoSuppliersTitle,
                              description: l10n.homeNoSuppliersDescription,
                            ),
                          );
                        }
                        return Column(
                          children: [
                            for (var i = 0; i < visible.length; i++) ...[
                              if (i > 0) AppSize.spaceMD.gap,
                              RemoteCraftsmanSummaryCard(
                                name: visible[i].craftsman.name,
                                accentKey: homeAccentKeyFor(visible[i].craftsman.id),
                                localeCode: localeCode,
                                clientsCount: visible[i].clientsCount ?? 0,
                                paidPiastres: visible[i].paidPiastres,
                                remainingPiastres: visible[i].remainingPiastres,
                                minorPerMajor: moneyScale,
                                onTap: () => context.push('/providers/${visible[i].craftsman.id}'),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                  if (!remoteMoney) ...[
                    AppSize.spaceXL.gap,
                    HomeSectionHeader(
                      title: l10n.homeSupplierSpendSection,
                      seeAllLabel: l10n.seeAll,
                      onSeeAll: () => context.go('/directory'),
                    ),
                    AppSize.spaceSM.gap,
                    AsyncValueBody(
                      value: suppliers,
                      loadingPlaceholder: const HomePersonListSkeleton(count: 1),
                      error: (e, _) => AppFallback(
                        isError: true,
                        icon: Icons.error_outline,
                        title: l10n.homeLoadErrorTitle,
                        actionLabel: l10n.retry,
                        onAction: () => ref.read(homeSupplierSpendsProvider.notifier).refreshSilently(),
                      ),
                      data: (rows) {
                        if (rows.isEmpty) {
                          final colors = context.colors;
                          return AppCard(
                            child: AppFallback.section(
                              leading: ShellNavIcon(
                                asset: Assets.icons.materialsPackageOutline,
                                color: colors.muted,
                                size: AppSize.icon,
                              ),
                              title: l10n.homeNoSupplierSpendTitle,
                              description: l10n.homeNoSupplierSpendDescription,
                            ),
                          );
                        }
                        return Column(
                          children: [
                            for (var i = 0; i < rows.length; i++) ...[
                              if (i > 0) AppSize.spaceMD.gap,
                              HomePersonCard(
                                name: rows[i].supplier.name,
                                amountPiastres: rows[i].spentPiastres,
                                amountRole: AppAmountRole.spend,
                                showAmountCaption: false,
                                accentKey: homeAccentKeyFor(rows[i].supplier.id),
                                localeCode: localeCode,
                                onTap: () => context.push('/suppliers/${rows[i].supplier.id}'),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
