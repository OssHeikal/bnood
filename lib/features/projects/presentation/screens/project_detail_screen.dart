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

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    super.key,
    required this.clientId,
    required this.projectId,
  });

  final String clientId;
  final String projectId;

  ProjectDetailParams get _params =>
      (clientId: clientId, projectId: projectId);

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
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(
              title: project?.name ?? l10n.navProjects,
              subtitle: client?.name,
            ),
            body: BnoodMaxWidth(
              maxWidth: AppLayout.pageMaxWidth,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  0,
                  AppSize.spaceSM,
                  0,
                  AppSize.spaceMD + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  if (isArchived)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSize.spaceMD),
                      child: _ArchivedBadge(label: l10n.clientArchivedBadge),
                    ),
                  AsyncValueBody(
                    value: detail,
                    loadingPlaceholder: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ClientDetailStatSkeleton(),
                        AppSize.spaceLG.gap,
                        const ClientDetailLoadingSkeleton(),
                      ],
                    ),
                    error: (e, _) => AppCard(
                      child: AppFallback.section(
                        icon: Icons.error_outline,
                        title: l10n.clientDetailLoadErrorTitle,
                        description: screenErrorDescription(l10n, e),
                        actions: [
                          AppFallbackAction(
                            label: l10n.retry,
                            onPressed: () => ref
                                .read(projectDetailProvider(_params).notifier)
                                .refreshSilently(),
                            role: AppFallbackActionRole.tertiary,
                          ),
                        ],
                      ),
                    ),
                    data: (data) => _ProjectDetailBody(
                      clientId: clientId,
                      projectId: projectId,
                      detailParams: _params,
                      data: data,
                      localeCode: localeCode,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
    final mutationsEnabled = !isArchived;

    Future<void> openAssignments() async {
      if (!mutationsEnabled) return;
      await showCraftsmanAssignmentsSheet(
        context: context,
        projectId: data.project.id,
        clientId: clientId,
      );
      if (context.mounted) {
        ref.read(projectDetailProvider(detailParams).notifier).refreshSilently();
      }
    }

    Future<void> openSupplierAssignments() async {
      if (!mutationsEnabled) return;
      await showSupplierAssignmentsSheet(
        context: context,
        projectId: data.project.id,
        clientId: clientId,
      );
      if (context.mounted) {
        ref.read(projectDetailProvider(detailParams).notifier).refreshSilently();
      }
    }

    void openVoucher(String kind) {
      if (!mutationsEnabled) return;
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

    if (data.onlineIdentityOnly) {
      final summary = <Widget>[
        ClientDetailStatGrid(
          receivedPiastres: data.receivedPiastres,
          spentPiastres: data.spentPiastres,
          remainingPiastres: data.remainingPiastres,
          localeCode: localeCode,
          minorPerMajor: data.usesRemoteMoney
              ? RemoteMoneyUnits.minorPerMajor
              : 100,
        ),
        AppSize.spaceLG.gap,
        ClientDetailActionGrid(
          isArchived: isArchived,
          mutationsEnabled: mutationsEnabled,
          onlineIdentityOnly: true,
          onReceive: () {},
          onSpend: () {},
          onStatement: () {},
          onArchive: () {},
          onDelete: () {},
        ),
        ...[
          AppSize.spaceXL.gap,
          ClientDetailLinkedProvidersSection(
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
          ),
          ...[
            AppSize.spaceXL.gap,
            ClientDetailLinkedProvidersSection(
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
            ),
          ],
        ],
      ];
      final ledger = <Widget>[
        AppCard(
          child: AppFallback.section(
            icon: Icons.cloud_off_outlined,
            title: l10n.clientLedgerNotOnlineTitle,
            description: l10n.clientLedgerNotOnlineDescription,
          ),
        ),
      ];
      return _clientDetailColumns(context, summary: summary, ledger: ledger);
    }

    final summary = <Widget>[
      ClientDetailStatGrid(
        receivedPiastres: data.receivedPiastres,
        spentPiastres: data.spentPiastres,
        remainingPiastres: data.remainingPiastres,
        localeCode: localeCode,
        minorPerMajor: data.usesRemoteMoney
            ? RemoteMoneyUnits.minorPerMajor
            : 100,
      ),
      AppSize.spaceLG.gap,
      ClientDetailActionGrid(
        isArchived: isArchived,
        mutationsEnabled: mutationsEnabled,
        onReceive: () => openVoucher('receive'),
        onSpend: () => openVoucher('spend'),
        onStatement: () {
          if (!mutationsEnabled) return;
          context.push('/clients/$clientId/statement');
        },
        onArchive: () {},
      ),
      AppSize.spaceXL.gap,
      ClientDetailEngineerCard(
        engineerBasisPoints: data.project.engineerBasisPoints,
        estimatedProfitPiastres: data.estimatedProfitPiastres,
        localeCode: localeCode,
        minorPerMajor: data.usesRemoteMoney
            ? RemoteMoneyUnits.minorPerMajor
            : 100,
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
      AppSize.spaceXL.gap,
      ClientDetailLinkedProvidersSection(
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
      ),
      ...[
        AppSize.spaceXL.gap,
        ClientDetailLinkedProvidersSection(
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
        ),
      ],
    ];
    final ledger = <Widget>[
      HomeSectionHeader(
        title: l10n.navItems,
        seeAllLabel: seeAllLabelWithCount(
          l10n,
          data.itemsCount ?? data.topItems.length,
        ),
        seeAllEnabled: mutationsEnabled,
        onSeeAll: () => context.push('/clients/$clientId/items'),
      ),
      AppSize.spaceSM.gap,
      if (data.topItems.isEmpty)
        AppCard(
          child: AppFallback.section(
            icon: Icons.inventory_2_outlined,
            title: l10n.clientDetailNoItemSpend,
          ),
        )
      else
        for (var i = 0; i < data.topItems.length; i++) ...[
          if (i > 0) AppSize.spaceMD.gap,
          ClientDetailItemRow(
            itemName: data.topItems[i].name,
            colorKey: data.topItems[i].colorKey,
            iconName: data.topItems[i].iconName,
            breakdown: data.topItems[i].breakdown,
            localeCode: localeCode,
            minorPerMajor: data.usesRemoteMoney
                ? RemoteMoneyUnits.minorPerMajor
                : 100,
            onTap: data.topItems[i].itemId == null
                ? null
                : () => pushClientMovements(
                    context,
                    clientId: clientId,
                    itemId: data.topItems[i].itemId,
                  ),
          ),
        ],
      AppSize.spaceXL.gap,
      HomeSectionHeader(
        title: l10n.movements,
        seeAllLabel: seeAllLabelWithCount(
          l10n,
          data.movementsCount ?? data.latestMovements.length,
        ),
        seeAllEnabled: mutationsEnabled,
        onSeeAll: () => context.push('/clients/$clientId/movements'),
      ),
      AppSize.spaceSM.gap,
      if (data.latestMovements.isEmpty)
        AppCard(
          child: AppFallback.section(
            icon: Icons.receipt_long_outlined,
            title: l10n.clientDetailNoMovements,
          ),
        )
      else
        Column(
          children: [
            for (var i = 0; i < data.latestMovements.length; i++) ...[
              if (i > 0) AppSize.spaceMD.gap,
              InteractiveMovementCard(
                line: data.latestMovements[i],
                localeCode: localeCode,
                mutationsEnabled: mutationsEnabled,
                ledgerClientId: clientId,
              ),
            ],
          ],
        ),
    ];
    return _clientDetailColumns(context, summary: summary, ledger: ledger);
  }
}

Widget _clientDetailColumns(
  BuildContext context, {
  required List<Widget> summary,
  required List<Widget> ledger,
}) {
  if (context.isMobileLayout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [...summary, ...ledger],
    );
  }
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
    end: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: ledger,
    ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSize.spaceMD,
            vertical: AppSize.spaceXS,
          ),
          child: Text(
            label,
            style: context.text.caption.copyWith(
              color: colors.onSurfaceMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
