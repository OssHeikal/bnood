import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_shape.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/repositories/bnood_repository.dart' show HomeTotals;
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/utils/whatsapp_phone.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/foundation_app_bar_title.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../../core/widgets/toast/app_tone.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../home/home_foundation_scope.dart';
import '../home/widgets/home_section_header.dart';
import '../vouchers/voucher_launcher.dart';
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
import 'widgets/client_detail_movement_row.dart';
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
            appBar: AppBar(
              backgroundColor: colors.canvas,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              centerTitle: false,
              toolbarHeight: hasPhone ? 64 : kToolbarHeight,
              title: client != null
                  ? FoundationAppBarTitle(
                      title: client.name,
                      subtitle: hasPhone ? phone : null,
                      subtitleLtr: true,
                    )
                  : FoundationAppBarTitle(title: l10n.navClients),
              actions: client != null
                  ? [
                      _AppBarIconAction(
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
                            return Padding(
                              padding: const EdgeInsetsDirectional.only(end: AppSize.spaceMD),
                              child: _AppBarIconAction(
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
                              ),
                            );
                          },
                        )
                      else
                        const SizedBox(width: AppSize.spaceMD),
                    ]
                  : const [],
            ),
            body: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                AppSize.spaceSM,
                AppSize.screenPadding,
                AppSize.spaceMD + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
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

class _AppBarIconAction extends StatelessWidget {
  const _AppBarIconAction({
    super.key,
    required this.tooltip,
    required this.onPressed,
    required this.child,
    this.enabled = true,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSize.spaceXS),
      child: Tooltip(
        message: tooltip,
        child: AppPressable(
          enabled: enabled,
          onPressed: onPressed,
          child: Material(
            color: context.colors.surface,
            shape: AppShape.superellipse(radius: AppSize.radiusSM),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: AppSize.buttonHeight,
              height: AppSize.buttonHeight,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
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
    await ref.read(repositoryProvider).archiveClient(clientId);
    refreshAfterClientMutation(ref, clientId: clientId);
    if (context.mounted) context.pop();
  }

  Future<void> _unarchive(BuildContext context, WidgetRef ref) async {
    await ref.read(repositoryProvider).unarchiveClient(clientId);
    refreshAfterClientMutation(ref, clientId: clientId);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClientDetailStatGrid(
          totals: HomeTotals(
            receivedPiastres: data.receivedPiastres,
            spentPiastres: data.spentPiastres,
          ),
          localeCode: localeCode,
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
          onArchive: () {
            if (isArchived) {
              _unarchive(context, ref);
            } else {
              _confirmArchive(context, ref);
            }
          },
        ),
        AppSize.spaceXL.gap,
        ClientDetailEngineerCard(
          engineerBasisPoints: data.project.engineerBasisPoints,
          estimatedProfitPiastres: data.estimatedProfitPiastres,
          localeCode: localeCode,
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
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG, vertical: AppSize.spaceXS),
            child: Column(
              children: [
                for (var i = 0; i < data.latestMovements.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: colors.outlineSubtle),
                  ClientDetailMovementRow(line: data.latestMovements[i], localeCode: localeCode),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
