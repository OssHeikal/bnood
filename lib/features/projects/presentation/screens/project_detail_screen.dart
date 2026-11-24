import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/domain/money/remote_money_units.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/layout/app_layout.dart';
import '../../../../core/ui/layout/bnood_max_width.dart';
import '../../../../core/ui/layout/bnood_two_column.dart';
import '../../../../core/network/api/api_error_user_message.dart';
import '../../../../core/domain/formatting/see_all_label.dart';
import '../../../../core/ui/widgets/app_card.dart';
import '../../../../core/ui/widgets/app_fallback.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import 'package:bnood/features/projects/domain/project_detail_params.dart';
import 'package:bnood/features/projects/presentation/providers/project_detail_provider.dart';
import '../../../../core/ui/widgets/skeleton/async_value_body.dart';
import '../../../../core/account/account_office_providers.dart';
import '../../../../core/account/office_permission_keys.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/home/presentation/widgets/home_section_header.dart';
import 'package:bnood/features/vouchers/presentation/actions/voucher_launcher.dart';
import 'package:bnood/features/clients/presentation/actions/client_movements_navigation.dart';
import 'package:bnood/features/clients/presentation/models/client_detail_snapshot.dart';
import 'package:bnood/features/clients/presentation/sheets/craftsman_assignments_sheet.dart';
import 'package:bnood/features/clients/presentation/sheets/engineer_edit_sheet.dart';
import 'package:bnood/features/clients/presentation/widgets/client_detail_action_grid.dart';
import 'package:bnood/features/clients/presentation/widgets/client_detail_linked_providers_section.dart';
import 'package:bnood/features/clients/presentation/widgets/client_detail_engineer_card.dart';
import 'package:bnood/features/clients/presentation/widgets/client_detail_item_row.dart';
import 'package:bnood/features/clients/presentation/widgets/client_detail_loading_skeleton.dart';
import 'package:bnood/features/clients/presentation/widgets/interactive_movement_card.dart';
import 'package:bnood/features/clients/presentation/widgets/client_detail_stat_grid.dart';
import 'project_detail_phone_layout.dart';
import 'project_detail_tab_footer.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.clientId, required this.projectId});

  final String clientId;
  final String projectId;

  ProjectDetailParams get _params => (clientId: clientId, projectId: projectId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final detail = ref.watch(projectDetailProvider(_params));
    final snapshot = detail.valueOrNull;

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final client = snapshot?.client;
          final project = snapshot?.project;
          final isArchived = client?.archivedAt != null;
          final bottomPad = AppSize.spaceMD + MediaQuery.paddingOf(context).bottom;

          Widget archivedBanner() {
            if (!isArchived) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSize.spaceMD),
              child: _ArchivedBadge(label: l10n.clientArchivedBadge),
            );
          }

          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(title: project?.name ?? l10n.navProjects, subtitle: client?.name),
            body: AsyncValueBody(
              value: detail,
              loadingPlaceholder: _paddedScrollBody(
                context,
                bottomPad,
                children: [
                  archivedBanner(),
                  const ClientDetailStatSkeleton(),
                  AppSize.spaceLG.gap,
                  const ClientDetailLoadingSkeleton(),
                ],
              ),
              error: (e, _) => _paddedScrollBody(
                context,
                bottomPad,
                children: [
                  archivedBanner(),
                  AppCard(
                    child: AppFallback.section(
                      icon: Icons.error_outline,
                      title: l10n.clientDetailLoadErrorTitle,
                      description: screenErrorDescription(l10n, e),
                      actions: [
                        AppFallbackAction(
                          label: l10n.retry,
                          onPressed: () => ref.read(projectDetailProvider(_params).notifier).refreshSilently(),
                          role: AppFallbackActionRole.tertiary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              data: (data) {
                final body = _ProjectDetailBody(
                  clientId: clientId,
                  projectId: projectId,
                  detailParams: _params,
                  data: data,
                  localeCode: localeCode,
                );
                if (context.isMobileLayout) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isArchived)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            context.pageGutter,
                            AppSize.spaceSM,
                            context.pageGutter,
                            AppSize.spaceMD,
                          ),
                          child: _ArchivedBadge(label: l10n.clientArchivedBadge),
                        )
                      else
                        SizedBox(height: AppSize.spaceSM),
                      Expanded(child: body),
                    ],
                  );
                }
                return BnoodMaxWidth(
                  maxWidth: AppLayout.pageMaxWidth,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(0, AppSize.spaceSM, 0, bottomPad),
                    children: [archivedBanner(), body],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

Widget _paddedScrollBody(BuildContext context, double bottomPad, {required List<Widget> children}) {
  if (context.isMobileLayout) {
    final gutter = context.pageGutter;
    return ListView(padding: EdgeInsets.fromLTRB(gutter, AppSize.spaceSM, gutter, bottomPad), children: children);
  }
  return BnoodMaxWidth(
    maxWidth: AppLayout.pageMaxWidth,
    child: ListView(padding: EdgeInsets.fromLTRB(0, AppSize.spaceSM, 0, bottomPad), children: children),
  );
}

class _ProjectDetailBody extends ConsumerWidget {
  const _ProjectDetailBody({
    required this.clientId,
    required this.projectId,
    required this.detailParams,
    required this.data,
    required this.localeCode,
  });

  final String clientId;
  final String projectId;
  final ProjectDetailParams detailParams;
  final ClientDetailSnapshot data;
  final String localeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isArchived = data.client.archivedAt != null;
    final perms = ref.watch(officeAccountPermissionsProvider);
    final showMoney = perms.canViewClientMoney;
    final canCreateVoucher = perms.canCreateVoucher && !isArchived;
    final canEditVoucher = perms.canEditVoucher && !isArchived;
    final canManageProject =
        perms.canManage(OfficePermissionArea.projects) && !isArchived;
    final mutationsEnabled = canManageProject;

    Future<void> openAssignments() async {
      if (!mutationsEnabled) return;
      await showCraftsmanAssignmentsSheet(context: context, projectId: data.project.id, clientId: clientId);
      if (context.mounted) {
        ref.read(projectDetailProvider(detailParams).notifier).refreshSilently();
      }
    }

    Future<void> openSupplierAssignments() async {
      if (!mutationsEnabled) return;
      await showSupplierAssignmentsSheet(context: context, projectId: data.project.id, clientId: clientId);
      if (context.mounted) {
        ref.read(projectDetailProvider(detailParams).notifier).refreshSilently();
      }
    }

    void openVoucher(String kind) {
      if (!canCreateVoucher) return;
      VoucherLauncher.openForClient(
        context,
        clientId: clientId,
        projectId: data.project.id,
        clientLabel: data.client.name,
        kind: kind,
      ).then((_) {
        if (context.mounted) {
          ref.read(projectDetailProvider(detailParams).notifier).refreshSilently();
        }
      });
    }

    final minorPerMajor = data.usesRemoteMoney ? RemoteMoneyUnits.minorPerMajor : 100;

    final scrollHeader = <Widget>[
      ClientDetailStatGrid(
        receivedPiastres: data.receivedPiastres,
        spentPiastres: data.spentPiastres,
        remainingPiastres: data.remainingPiastres,
        localeCode: localeCode,
        minorPerMajor: minorPerMajor,
        hideMoney: !showMoney,
      ),
      AppSize.spaceLG.gap,
      ClientDetailActionGrid(
        isArchived: isArchived,
        mutationsEnabled: canCreateVoucher && !data.onlineIdentityOnly,
        statementEnabled: showMoney && !data.onlineIdentityOnly,
        onlineIdentityOnly: data.onlineIdentityOnly,
        onReceive: data.onlineIdentityOnly ? () {} : () => openVoucher('receive'),
        onSpend: data.onlineIdentityOnly ? () {} : () => openVoucher('spend'),
        onStatement: () {
          if (!showMoney || data.onlineIdentityOnly) return;
          context.push('/clients/$clientId/statement');
        },
        onArchive: () {},
        onDelete: data.onlineIdentityOnly ? () {} : null,
      ),
      if (!data.onlineIdentityOnly) ...[
        AppSize.spaceXL.gap,
        ClientDetailEngineerCard(
          engineerBasisPoints: data.project.engineerBasisPoints,
          estimatedProfitPiastres: data.estimatedProfitPiastres,
          localeCode: localeCode,
          minorPerMajor: minorPerMajor,
          mutationsEnabled: mutationsEnabled,
          onEdit: () {
            if (!mutationsEnabled) return;
            showEngineerFeeSheet(
              context: context,
              clientId: clientId,
              projectId: data.project.id,
              clientName: data.client.name,
              engineerBasisPoints: data.project.engineerBasisPoints,
            );
          },
        ),
      ],
    ];

    final craftsmenSeeAll = seeAllLabelWithCount(
      l10n,
      sectionSeeAllCount(total: data.craftsmenCount, visibleLength: data.craftsmanPreviews.length),
    );
    final suppliersSeeAll = seeAllLabelWithCount(
      l10n,
      sectionSeeAllCount(total: data.suppliersCount, visibleLength: data.supplierPreviews.length),
    );

    final craftsmenSection = ClientDetailLinkedProvidersSection(
      title: l10n.craftsmen,
      assignLabel: l10n.assignCraftsmen,
      emptyTitle: l10n.clientDetailNoCraftsmen,
      emptyDescription: l10n.clientDetailCraftsmenEmptyDescription,
      seeAllRoute: '/clients/$clientId/craftsmen',
      previews: data.craftsmanPreviews,
      localeCode: localeCode,
      mutationsEnabled: mutationsEnabled,
      onAssign: openAssignments,
      totalCount: data.craftsmenCount,
    );

    final suppliersSection = ClientDetailLinkedProvidersSection(
      title: l10n.suppliers,
      assignLabel: l10n.assignSuppliers,
      emptyTitle: l10n.clientDetailNoSuppliers,
      emptyDescription: l10n.clientDetailSuppliersEmptyDescription,
      seeAllRoute: '/clients/$clientId/suppliers',
      previews: data.supplierPreviews,
      localeCode: localeCode,
      mutationsEnabled: mutationsEnabled,
      onAssign: openSupplierAssignments,
      totalCount: data.suppliersCount,
    );

    final craftsmenPhoneTab = ClientDetailLinkedProvidersSection(
      title: l10n.craftsmen,
      assignLabel: l10n.assignCraftsmen,
      emptyTitle: l10n.clientDetailNoCraftsmen,
      emptyDescription: l10n.clientDetailCraftsmenEmptyDescription,
      seeAllRoute: '/clients/$clientId/craftsmen',
      previews: data.craftsmanPreviews,
      localeCode: localeCode,
      mutationsEnabled: mutationsEnabled,
      onAssign: openAssignments,
      totalCount: data.craftsmenCount,
      tabBodyMode: true,
      footer: ProjectDetailTabFooter(
        filledActionLabel: mutationsEnabled ? l10n.assignCraftsmen : null,
        onFilledAction: openAssignments,
        filledEnabled: mutationsEnabled,
        seeAllLabel: craftsmenSeeAll,
        onSeeAll: () => context.push('/clients/$clientId/craftsmen'),
        seeAllEnabled: mutationsEnabled,
        seeAllKey: const Key('project_detail_tab_see_all_craftsmen'),
      ),
    );

    final suppliersPhoneTab = ClientDetailLinkedProvidersSection(
      title: l10n.suppliers,
      assignLabel: l10n.assignSuppliers,
      emptyTitle: l10n.clientDetailNoSuppliers,
      emptyDescription: l10n.clientDetailSuppliersEmptyDescription,
      seeAllRoute: '/clients/$clientId/suppliers',
      previews: data.supplierPreviews,
      localeCode: localeCode,
      mutationsEnabled: mutationsEnabled,
      onAssign: openSupplierAssignments,
      totalCount: data.suppliersCount,
      tabBodyMode: true,
      footer: ProjectDetailTabFooter(
        filledActionLabel: mutationsEnabled ? l10n.assignSuppliers : null,
        onFilledAction: openSupplierAssignments,
        filledEnabled: mutationsEnabled,
        seeAllLabel: suppliersSeeAll,
        onSeeAll: () => context.push('/clients/$clientId/suppliers'),
        seeAllEnabled: mutationsEnabled,
        seeAllKey: const Key('project_detail_tab_see_all_suppliers'),
      ),
    );

    final itemsTab = _ProjectDetailItemsSection(
      clientId: clientId,
      data: data,
      localeCode: localeCode,
      minorPerMajor: minorPerMajor,
      mutationsEnabled: mutationsEnabled,
      l10n: l10n,
    );

    final movementsSection = _ProjectDetailMovementsSection(
      clientId: clientId,
      data: data,
      localeCode: localeCode,
      mutationsEnabled: canEditVoucher,
      l10n: l10n,
    );
    final onlineLedgerFallback = data.onlineIdentityOnly
        ? AppCard(
            child: AppFallback.section(
              icon: Icons.cloud_off_outlined,
              title: l10n.clientLedgerNotOnlineTitle,
              description: l10n.clientLedgerNotOnlineDescription,
            ),
          )
        : null;

    if (context.isMobileLayout) {
      final phoneHeader = [...scrollHeader, AppSize.spaceLG.gap];
      return ProjectDetailPhoneLayout(
        headerChildren: phoneHeader,
        tabLabels: [l10n.navItems, l10n.craftsmen, l10n.suppliers, l10n.movements],
        itemsTab: itemsTab.buildPhoneTab(context),
        craftsmenTab: craftsmenPhoneTab,
        suppliersTab: suppliersPhoneTab,
        movementsTab: onlineLedgerFallback ?? movementsSection.buildPhoneTab(context),
      );
    }

    final summary = <Widget>[
      ...scrollHeader,
      AppSize.spaceXL.gap,
      craftsmenSection,
      AppSize.spaceXL.gap,
      suppliersSection,
    ];

    final ledger = <Widget>[
      if (data.onlineIdentityOnly)
        AppCard(
          child: AppFallback.section(
            icon: Icons.cloud_off_outlined,
            title: l10n.clientLedgerNotOnlineTitle,
            description: l10n.clientLedgerNotOnlineDescription,
          ),
        )
      else ...[
        ...itemsTab.tabletLedgerSection(context),
        AppSize.spaceXL.gap,
        ...movementsSection.tabletLedgerSection(context),
      ],
    ];

    return _clientDetailColumns(context, summary: summary, ledger: ledger);
  }
}

class _ProjectDetailItemsSection {
  const _ProjectDetailItemsSection({
    required this.clientId,
    required this.data,
    required this.localeCode,
    required this.minorPerMajor,
    required this.mutationsEnabled,
    required this.l10n,
  });

  final String clientId;
  final ClientDetailSnapshot data;
  final String localeCode;
  final int minorPerMajor;
  final bool mutationsEnabled;
  final AppLocalizations l10n;

  List<Widget> tabletLedgerSection(BuildContext context) {
    return [
      HomeSectionHeader(
        title: l10n.navItems,
        seeAllLabel: seeAllLabelWithCount(l10n, data.itemsCount ?? data.topItems.length),
        seeAllEnabled: mutationsEnabled,
        onSeeAll: () => context.push('/clients/$clientId/items'),
      ),
      AppSize.spaceSM.gap,
      ..._itemRows(context),
    ];
  }

  Widget buildPhoneTab(BuildContext context) {
    final seeAll = seeAllLabelWithCount(l10n, data.itemsCount ?? data.topItems.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._itemRows(context),
        AppSize.spaceXL.gap,
        ProjectDetailTabFooter(
          seeAllLabel: seeAll,
          onSeeAll: () => context.push('/clients/$clientId/items'),
          seeAllEnabled: mutationsEnabled,
          seeAllKey: const Key('project_detail_tab_see_all_items'),
        ),
      ],
    );
  }

  List<Widget> _itemRows(BuildContext context) {
    if (data.topItems.isEmpty) {
      return [
        AppCard(
          child: AppFallback.section(icon: Icons.inventory_2_outlined, title: l10n.clientDetailNoItemSpend),
        ),
      ];
    }
    return [
      for (var i = 0; i < data.topItems.length; i++) ...[
        if (i > 0) AppSize.spaceMD.gap,
        ClientDetailItemRow(
          itemName: data.topItems[i].name,
          colorKey: data.topItems[i].colorKey,
          iconName: data.topItems[i].iconName,
          breakdown: data.topItems[i].breakdown,
          localeCode: localeCode,
          minorPerMajor: minorPerMajor,
          onTap: data.topItems[i].itemId == null
              ? null
              : () => pushClientMovements(context, clientId: clientId, itemId: data.topItems[i].itemId),
        ),
      ],
    ];
  }
}

class _ProjectDetailMovementsSection {
  const _ProjectDetailMovementsSection({
    required this.clientId,
    required this.data,
    required this.localeCode,
    required this.mutationsEnabled,
    required this.l10n,
  });

  final String clientId;
  final ClientDetailSnapshot data;
  final String localeCode;
  final bool mutationsEnabled;
  final AppLocalizations l10n;

  List<Widget> tabletLedgerSection(BuildContext context) {
    return [
      HomeSectionHeader(
        title: l10n.movements,
        seeAllLabel: seeAllLabelWithCount(l10n, data.movementsCount ?? data.latestMovements.length),
        seeAllEnabled: true,
        onSeeAll: () => context.push('/clients/$clientId/movements'),
      ),
      AppSize.spaceSM.gap,
      ..._movementCards(),
    ];
  }

  List<Widget> _movementCards() {
    if (data.latestMovements.isEmpty) {
      return [
        AppCard(
          child: AppFallback.section(icon: Icons.receipt_long_outlined, title: l10n.clientDetailNoMovements),
        ),
      ];
    }
    return [
      for (var i = 0; i < data.latestMovements.length; i++) ...[
        if (i > 0) AppSize.spaceMD.gap,
        InteractiveMovementCard(
          line: data.latestMovements[i],
          localeCode: localeCode,
          mutationsEnabled: mutationsEnabled,
          ledgerClientId: clientId,
        ),
      ],
    ];
  }

  Widget buildPhoneTab(BuildContext context) {
    final seeAll = seeAllLabelWithCount(l10n, data.movementsCount ?? data.latestMovements.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._movementCards(),
        AppSize.spaceXL.gap,
        ProjectDetailTabFooter(
          seeAllLabel: seeAll,
          onSeeAll: () => context.push('/clients/$clientId/movements'),
          seeAllEnabled: true,
          seeAllKey: const Key('project_detail_tab_see_all_movements'),
        ),
      ],
    );
  }
}

Widget _clientDetailColumns(BuildContext context, {required List<Widget> summary, required List<Widget> ledger}) {
  final lead = HomeSectionHeader.columnLeadBeforeContent(context);
  return BnoodTwoColumn(
    spacing: AppSize.spaceLG,
    crossAxisAlignment: CrossAxisAlignment.start,
    start: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: lead),
        ...summary,
      ],
    ),
    end: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: ledger),
  );
}

class _ArchivedBadge extends StatelessWidget {
  const _ArchivedBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(AppSize.radiusSM),
          border: Border.all(color: colors.outlineSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceMD, vertical: AppSize.spaceXS),
          child: Text(
            label,
            style: context.text.caption.copyWith(color: colors.onSurfaceMuted, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
