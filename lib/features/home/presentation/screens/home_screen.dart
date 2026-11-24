import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import 'package:bnood/features/home/data/craftsman_snapshot_limit.dart';
import 'package:bnood/features/clients/data/client_list_archive_filter.dart';
import 'package:bnood/features/clients/presentation/widgets/client_balance_card.dart';
import 'package:bnood/features/home/presentation/widgets/home_person_card.dart';
import 'package:bnood/features/projects/presentation/providers/projects_list_providers.dart';
import '../../../../core/domain/money/remote_money_units.dart';
import '../../../../core/ui/layout/app_layout.dart';
import '../../../../core/ui/layout/bnood_max_width.dart';
import '../../../../core/ui/layout/bnood_two_column.dart';
import '../../../../core/domain/formatting/cairo_local_time.dart';
import '../../../../core/domain/formatting/see_all_label.dart';
import 'package:bnood/features/home/data/home_section_counts.dart';
import '../../../../core/ui/resources/gen/assets.gen.dart';
import '../../../../core/network/api/api_error_user_message.dart';
import '../../../../core/ui/widgets/app_fallback.dart';
import '../../../../app/shell_tab_scaffold.dart';
import '../../../../app/widgets/shell_nav_icon.dart';
import '../../../../app/widgets/shell_notifications_action.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/providers/presentation/providers/providers_list_paging.dart';
import 'package:bnood/features/providers/presentation/widgets/remote_craftsman_summary_card.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import '../../../../core/ui/widgets/app_card.dart';
import '../../../../core/ui/widgets/skeleton/async_value_body.dart';
import 'package:bnood/features/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:bnood/features/home/presentation/widgets/home_section_header.dart';
import 'package:bnood/features/home/presentation/widgets/home_stat_grid.dart';
import 'package:bnood/features/home/presentation/widgets/home_identity_title.dart';
import 'package:bnood/features/account/presentation/widgets/account_switcher_title.dart';
import 'package:bnood/features/account/presentation/widgets/office_read_only_banner.dart';
import '../../../../core/account/account_office_providers.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const primaryColumnKey = Key('home-column-primary');
  static const providersColumnKey = Key('home-column-providers');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final user = ref.watch(authControllerProvider).user;
    const remoteMoney = true;
    const moneyScale = RemoteMoneyUnits.minorPerMajor;
    final displayName = user?.name?.trim();
    final showIdentityHeader =
        remoteMoney && displayName != null && displayName.isNotEmpty;
    final showAccountSwitcher = ref.watch(accountSwitcherVisibleProvider);
    final showOwnedOfficeHeader =
        ref.watch(accountOwnedOfficeHeaderVisibleProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final cairoNow = cairoLocalNow();
    final homeGreeting = cairoIsMorning(cairoNow)
        ? l10n.homeGreetingMorning
        : l10n.homeGreetingEvening;
    final Widget? homeTitleWidget;
    if (showAccountSwitcher) {
      homeTitleWidget = AccountSwitcherTitle(
        displayName: displayName ?? '',
        greeting: showIdentityHeader ? homeGreeting : null,
        showAvatar: showIdentityHeader,
      );
    } else if (showIdentityHeader) {
      homeTitleWidget = HomeIdentityTitle(displayName: displayName);
    } else if (showOwnedOfficeHeader) {
      homeTitleWidget = AccountSwitcherTitle(
        displayName: displayName ?? '',
        showAvatar: showIdentityHeader,
      );
    } else {
      homeTitleWidget = null;
    }

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final text = context.text;
          final totals = ref.watch(homeTotalsProvider);
          final activeProjects = ref.watch(homeActiveProjectsProvider);
          final craftsmen = ref.watch(homeCraftsmenProvider);
          final remoteSuppliers = ref.watch(homeSuppliersProvider);
          final sectionCounts = ref.watch(homeSectionCountsProvider);
          final summaryChildren = <Widget>[
            Text(
              l10n.homeTotalsCaption,
              style: text.caption.copyWith(color: colors.onSurfaceMuted),
            ),
            AppSize.spaceMD.gap,
            AsyncValueBody(
              value: totals,
              loadingPlaceholder: const HomeStatGridSkeleton(),
              error: (e, _) => AppFallback(
                isError: true,
                icon: Icons.error_outline,
                title: l10n.homeLoadErrorTitle,
                description: screenErrorDescription(l10n, e),
                actionLabel: l10n.retry,
                onAction: () =>
                    ref.read(homeTotalsProvider.notifier).refreshSilently(),
              ),
              data: (t) => HomeStatGrid(
                totals: t,
                localeCode: localeCode,
                minorPerMajor: moneyScale,
              ),
            ),
          ];

          final activeProjectsChildren = <Widget>[
            HomeSectionHeader(
              title: l10n.activeProjects,
              seeAllLabel: seeAllLabelWithCount(
                l10n,
                sectionSeeAllCount(
                  total: sectionCounts.projectsCount,
                  visibleLength: activeProjects.valueOrNull?.length ?? 0,
                ),
              ),
              onSeeAll: () {
                ref.read(projectsListFilterProvider.notifier).state =
                    ClientListArchiveFilter.active;
                context.go('/projects');
              },
            ),
            AppSize.spaceSM.gap,
            AsyncValueBody(
              value: activeProjects,
              loadingPlaceholder: const HomePersonListSkeleton(),
              error: (e, _) => AppFallback(
                isError: true,
                icon: Icons.error_outline,
                title: l10n.projectsLoadErrorTitle,
                description: screenErrorDescription(l10n, e),
                actionLabel: l10n.retry,
                onAction: () => ref
                    .read(homeActiveProjectsProvider.notifier)
                    .refreshSilently(),
              ),
              data: (rows) {
                if (rows.isEmpty) {
                  return AppCard(
                    child: AppFallback.section(
                      icon: Icons.folder_open_outlined,
                      title: l10n.homeNoActiveProjectsTitle,
                      description: l10n.homeNoActiveProjectsDescription,
                      actions: [
                        AppFallbackAction(
                          label: l10n.seeAll,
                          onPressed: () => context.go('/projects'),
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
                        name: rows[i].projectName,
                        meta: rows[i].clientName,
                        receivedPiastres: rows[i].receivedPiastres,
                        spentPiastres: rows[i].spentPiastres,
                        amountPiastres: rows[i].remainingPiastres,
                        accentKey: clientAccentKeyFor(rows[i].clientId),
                        localeCode: localeCode,
                        minorPerMajor: moneyScale,
                        onTap: () => context.push(
                          '/projects/${rows[i].projectId}?clientId=${rows[i].clientId}',
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ];

          final providerSnapshotChildren = <Widget>[
            HomeSectionHeader(
              title: l10n.homeCraftsmenSection,
              seeAllLabel: seeAllLabelWithCount(
                l10n,
                sectionSeeAllCount(
                  total: sectionCounts.craftsmenCount,
                  visibleLength: craftsmanSnapshotRows(
                    craftsmen.valueOrNull ?? const [],
                  ).length,
                ),
              ),
              onSeeAll: () {
                ref.read(providersListTypeFilterProvider.notifier).state =
                    ProvidersListTypeFilter.craftsman;
                context.go('/directory');
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
                description: screenErrorDescription(l10n, e),
                actionLabel: l10n.retry,
                onAction: () =>
                    ref.read(homeCraftsmenProvider.notifier).refreshSilently(),
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
                            ref
                                .read(providersListTypeFilterProvider.notifier)
                                .state = ProvidersListTypeFilter
                                .craftsman;
                            context.go('/directory');
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
                      RemoteCraftsmanSummaryCard(
                        name: visible[i].craftsman.name,
                        accentKey: homeAccentKeyFor(visible[i].craftsman.id),
                        localeCode: localeCode,
                        clientsCount: visible[i].clientsCount ?? 0,
                        paidPiastres: visible[i].paidPiastres,
                        remainingPiastres: visible[i].remainingPiastres,
                        minorPerMajor: moneyScale,
                        onTap: () => context.push(
                          '/providers/${visible[i].craftsman.id}',
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            AppSize.spaceXL.gap,
            HomeSectionHeader(
              title: l10n.homeSuppliersSection,
              seeAllLabel: seeAllLabelWithCount(
                l10n,
                sectionSeeAllCount(
                  total: sectionCounts.suppliersCount,
                  visibleLength: craftsmanSnapshotRows(
                    remoteSuppliers.valueOrNull ?? const [],
                  ).length,
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
                description: screenErrorDescription(l10n, e),
                actionLabel: l10n.retry,
                onAction: () =>
                    ref.read(homeSuppliersProvider.notifier).refreshSilently(),
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
                        onTap: () => context.push(
                          '/providers/${visible[i].craftsman.id}',
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ];

          final snapshotChildren = <Widget>[
            ...activeProjectsChildren,
            AppSize.spaceXL.gap,
            ...providerSnapshotChildren,
          ];

          return ShellTabScaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(
              automaticallyImplyLeading: false,
              titleWidget: homeTitleWidget,
              title: homeTitleWidget != null ? null : l10n.homeAppName,
              actions: const [ShellNotificationsAction()],
            ),
            body: RefreshIndicator.adaptive(
              onRefresh: () => refreshHomeDashboard(ref),
              child: BnoodMaxWidth(
                maxWidth: AppLayout.pageMaxWidth,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    0,
                    AppSize.spaceMD,
                    0,
                    bottomInset + AppSize.spaceMD,
                  ),
                  children: [
                    const OfficeReadOnlyBanner(),
                    if (context.isMobileLayout) ...[
                      ...summaryChildren,
                      AppSize.spaceXL.gap,
                      ...snapshotChildren,
                    ] else
                      BnoodTwoColumn(
                        spacing: AppSize.spaceLG,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        start: Column(
                          key: primaryColumnKey,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...summaryChildren,
                            AppSize.spaceXL.gap,
                            ...activeProjectsChildren,
                          ],
                        ),
                        end: Column(
                          key: providersColumnKey,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: providerSnapshotChildren,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
