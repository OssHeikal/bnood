import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/money/remote_money_units.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/clients/clients_error_handler.dart';
import '../subscription/subscription_error_handler.dart';
import '../subscription/subscription_gates.dart';
import '../../core/agreements/agreements_riverpod.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/utils/whatsapp_phone.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../../core/widgets/toast/app_tone.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../home/home_foundation_scope.dart';
import '../home/widgets/home_section_header.dart';
import '../vouchers/voucher_launcher.dart';
import 'client_movements_navigation.dart';
import 'client_detail_provider.dart';
import 'client_detail_snapshot.dart';
import 'client_edit_sheet.dart';
import 'craftsman_assignments_sheet.dart';
import 'engineer_edit_sheet.dart';
import 'widgets/client_detail_action_grid.dart';
import 'widgets/client_detail_craftsman_row.dart';
import 'widgets/client_detail_engineer_card.dart';
import 'widgets/client_detail_item_row.dart';
import 'widgets/client_detail_loading_skeleton.dart';
import 'widgets/interactive_movement_card.dart';
import 'widgets/client_detail_stat_grid.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final detail = ref.watch(clientDetailProvider(clientId));
    final snapshot = detail.valueOrNull;

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final client = snapshot?.client;
          final isArchived = client?.archivedAt != null;
          final mutationsEnabled = client != null && !isArchived;
          final phone = client?.phone?.trim();
          final hasPhone = phone != null && phone.isNotEmpty;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(
              title: client?.name ?? l10n.navClients,
              subtitle: hasPhone ? phone : null,
              subtitleLtr: true,
              actions: client != null
                  ? [
                      CustomAppBarAction(
                        key: const Key('client_detail_edit'),
                        tooltip: l10n.edit,
                        enabled: mutationsEnabled,
                        onPressed: mutationsEnabled
                            ? () => showClientEditSheet(
                                  context: context,
                                  clientId: clientId,
                                  clientName: client.name,
                                  phone: client.phone,
                                )
                            : null,
                        child: ShellNavIcon(
                          asset: Assets.icons.documentEditOutline,
                          color: colors.onSurface,
                          size: AppSize.icon,
                          semanticsLabel: l10n.edit,
                        ),
                      ),
                      if (hasPhone)
                        Builder(
                          builder: (context) {
                            final waDigits = WhatsAppPhone.waMeDigits(phone);
                            final waEnabled = mutationsEnabled && waDigits != null;
                            return CustomAppBarAction(
                              key: const Key('client_detail_whatsapp'),
                              tooltip: l10n.whatsapp,
                              enabled: waEnabled,
                              onPressed: waEnabled
                                  ? () => _openWhatsApp(context, l10n, waDigits)
                                  : mutationsEnabled
                                      ? () => AppToaster.show(l10n.whatsappInvalidPhone, kind: ToastKind.failure)
                                      : null,
                              child: Opacity(
                                opacity: waEnabled ? 1 : 0.38,
                                child: Assets.icons.whatsappColor.svg(
                                  width: AppSize.icon,
                                  height: AppSize.icon,
                                  semanticsLabel: l10n.whatsapp,
                                ),
                              ),
                            );
                          },
                        ),
                    ]
                  : null,
            ),
            body: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                AppSize.spaceSM,
                AppSize.screenPadding,
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
                      title: l10n.homeLoadErrorTitle,
                      description: e.toString(),
                      actions: [
                        AppFallbackAction(
                          label: l10n.retry,
                          onPressed: () => ref.read(clientDetailProvider(clientId).notifier).refreshSilently(),
                          role: AppFallbackActionRole.tertiary,
                        ),
                      ],
                    ),
                  ),
                  data: (data) => _ClientDetailBody(
                    clientId: clientId,
                    data: data,
                    localeCode: localeCode,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Future<void> _openWhatsApp(BuildContext context, AppLocalizations l10n, String waDigits) async {
    final uri = Uri.parse('https://wa.me/$waDigits');
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        AppToaster.show(l10n.whatsappLaunchFailed, kind: ToastKind.failure);
      }
    } catch (_) {
      if (context.mounted) {
        AppToaster.show(l10n.whatsappLaunchFailed, kind: ToastKind.failure);
      }
    }
  }
}

class _ClientDetailBody extends ConsumerWidget {
  const _ClientDetailBody({
    required this.clientId,
    required this.data,
    required this.localeCode,
  });

  final String clientId;
  final ClientDetailSnapshot data;
  final String localeCode;

  Future<void> _confirmArchive(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final answer = await AppDecision.show(
      context,
      title: l10n.archiveClientTitle,
      description: l10n.archiveClientDescription(data.client.name),
      confirmLabel: l10n.archive,
      cancelLabel: l10n.cancel,
      tone: AppTone.danger,
      iconWidget: AppDecision.archiveDangerIcon(context),
    );
    if (answer != OverlayAnswer.confirmed || !context.mounted) return;
    if (ref.read(remoteClientsEnabledProvider)) {
      if (!await guardArchiveClient(context, ref)) return;
    }
    try {
      if (ref.read(remoteClientsEnabledProvider)) {
        await ref.read(clientsRepositoryProvider).archiveClient(clientId);
      } else {
        await ref.read(repositoryProvider).archiveClient(clientId);
      }
      refreshAfterClientMutation(ref, clientId: clientId);
      if (context.mounted) context.pop();
    } on AuthApiException catch (e) {
      if (!context.mounted) return;
      if (await handleClientsApiAuthError(context: context, ref: ref, error: e)) return;
      if (await handleClientsApiSubscriptionError(context: context, ref: ref, error: e)) return;
      AppToaster.show(e.message, kind: ToastKind.failure);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final answer = await AppDecision.show(
      context,
      title: l10n.clientDeleteTitle,
      description: l10n.clientDeleteDescription(data.client.name),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      tone: AppTone.danger,
    );
    if (answer != OverlayAnswer.confirmed || !context.mounted) return;
    try {
      await ref.read(clientsRepositoryProvider).deleteClient(clientId);
      refreshAfterClientMutation(ref, clientId: clientId);
      if (context.mounted) context.pop();
    } on AuthApiException catch (e) {
      if (!context.mounted) return;
      if (await handleClientsApiAuthError(context: context, ref: ref, error: e)) return;
      if (e.isClientHasActivity) {
        final archiveInstead = await AppDecision.show(
          context,
          title: l10n.clientDeleteHasActivityTitle,
          description: l10n.clientDeleteHasActivityDescription,
          confirmLabel: l10n.clientDeleteArchiveInstead,
          cancelLabel: l10n.cancel,
          tone: AppTone.danger,
        );
        if (archiveInstead == OverlayAnswer.confirmed && context.mounted) {
          await _confirmArchive(context, ref);
        }
        return;
      }
      AppToaster.show(e.message, kind: ToastKind.failure);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
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
        ref.read(clientDetailProvider(clientId).notifier).refreshSilently();
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
          ref.read(clientDetailProvider(clientId).notifier).refreshSilently();
        }
      });
    }

    if (data.onlineIdentityOnly) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClientDetailStatGrid(
            receivedPiastres: data.receivedPiastres,
            spentPiastres: data.spentPiastres,
            remainingPiastres: data.remainingPiastres,
            localeCode: localeCode,
            minorPerMajor: data.usesRemoteMoney ? RemoteMoneyUnits.minorPerMajor : 100,
          ),
          AppSize.spaceLG.gap,
          ClientDetailActionGrid(
            isArchived: isArchived,
            mutationsEnabled: mutationsEnabled,
            onlineIdentityOnly: true,
            onReceive: () {},
            onSpend: () {},
            onStatement: () {},
            onArchive: () => _confirmArchive(context, ref),
            onDelete: () => _confirmDelete(context, ref),
          ),
          if (ref.read(remoteAgreementsEnabledProvider)) ...[
            AppSize.spaceXL.gap,
            Row(
              children: [
                Expanded(child: Text(l10n.craftsmen, style: text.sectionTitle)),
                AppPressable(
                  enabled: mutationsEnabled,
                  onPressed: openAssignments,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Text(
                      l10n.assignCraftsmen,
                      style: text.caption.copyWith(
                        color: mutationsEnabled ? colors.primaryDark : colors.onSurfaceMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                AppSize.spaceSM.gap,
                AppPressable(
                  enabled: mutationsEnabled,
                  onPressed: mutationsEnabled ? () => context.push('/clients/$clientId/craftsmen') : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Text(
                      l10n.seeAll,
                      style: text.caption.copyWith(
                        color: mutationsEnabled ? colors.primaryDark : colors.onSurfaceMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppSize.spaceSM.gap,
            if (data.craftsmanPreviews.isEmpty)
              AppCard(
                child: AppFallback.section(
                  icon: Icons.handyman_outlined,
                  title: l10n.clientDetailNoCraftsmen,
                  description: l10n.clientDetailCraftsmenEmptyDescription,
                  actions: [
                    if (mutationsEnabled)
                      AppFallbackAction(
                        label: l10n.assignCraftsmen,
                        onPressed: openAssignments,
                        role: AppFallbackActionRole.tertiary,
                      ),
                  ],
                ),
              )
            else
              for (var i = 0; i < data.craftsmanPreviews.length; i++) ...[
                if (i > 0) AppSize.spaceMD.gap,
                ClientDetailCraftsmanRow(
                  preview: data.craftsmanPreviews[i],
                  localeCode: localeCode,
                ),
              ],
          ],
          AppSize.spaceXL.gap,
          AppCard(
            child: AppFallback.section(
              icon: Icons.cloud_off_outlined,
              title: l10n.clientLedgerNotOnlineTitle,
              description: l10n.clientLedgerNotOnlineDescription,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClientDetailStatGrid(
          receivedPiastres: data.receivedPiastres,
          spentPiastres: data.spentPiastres,
          remainingPiastres: data.remainingPiastres,
          localeCode: localeCode,
          minorPerMajor: data.usesRemoteMoney ? RemoteMoneyUnits.minorPerMajor : 100,
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
          onArchive: () => _confirmArchive(context, ref),
        ),
        AppSize.spaceXL.gap,
        ClientDetailEngineerCard(
          engineerBasisPoints: data.project.engineerBasisPoints,
          estimatedProfitPiastres: data.estimatedProfitPiastres,
          localeCode: localeCode,
          minorPerMajor: data.usesRemoteMoney ? RemoteMoneyUnits.minorPerMajor : 100,
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
        Row(
          children: [
            Expanded(child: Text(l10n.craftsmen, style: text.sectionTitle)),
            AppPressable(
              enabled: mutationsEnabled,
              onPressed: openAssignments,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Text(
                  l10n.assignCraftsmen,
                  style: text.caption.copyWith(
                    color: mutationsEnabled ? colors.primaryDark : colors.onSurfaceMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            AppSize.spaceSM.gap,
            AppPressable(
              enabled: mutationsEnabled,
              onPressed: mutationsEnabled ? () => context.push('/clients/$clientId/craftsmen') : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Text(
                  l10n.seeAll,
                  style: text.caption.copyWith(
                    color: mutationsEnabled ? colors.primaryDark : colors.onSurfaceMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        AppSize.spaceSM.gap,
        if (data.craftsmanPreviews.isEmpty)
          AppCard(
            child: AppFallback.section(
              icon: Icons.handyman_outlined,
              title: l10n.clientDetailNoCraftsmen,
              description: l10n.clientDetailCraftsmenEmptyDescription,
              actions: [
                if (mutationsEnabled)
                  AppFallbackAction(
                    label: l10n.assignCraftsmen,
                    onPressed: openAssignments,
                    role: AppFallbackActionRole.tertiary,
                  ),
              ],
            ),
          )
        else
          for (var i = 0; i < data.craftsmanPreviews.length; i++) ...[
            if (i > 0) AppSize.spaceMD.gap,
            ClientDetailCraftsmanRow(preview: data.craftsmanPreviews[i], localeCode: localeCode),
          ],
        AppSize.spaceXL.gap,
        HomeSectionHeader(
          title: l10n.navItems,
          seeAllLabel: l10n.seeAll,
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
              minorPerMajor: data.usesRemoteMoney ? RemoteMoneyUnits.minorPerMajor : 100,
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
          seeAllLabel: l10n.seeAll,
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
      ],
    );
  }
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
