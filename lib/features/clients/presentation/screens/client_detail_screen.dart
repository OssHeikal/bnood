import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/account/account_office_providers.dart';
import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/network/api/api_error_user_message.dart';
import '../../../../core/domain/money/remote_money_units.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/layout/app_layout.dart';
import '../../../../core/ui/layout/bnood_max_width.dart';
import '../../../../core/ui/resources/gen/assets.gen.dart';
import '../../../../core/ui/widgets/app_card.dart';
import '../../../../core/ui/widgets/app_fallback.dart';
import '../../../../core/ui/widgets/app_overflow_menu.dart';
import '../../../../core/ui/widgets/app_toaster.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import '../../../../core/ui/widgets/skeleton/async_value_body.dart';
import '../../../../core/utils/whatsapp_phone.dart';
import 'package:bnood/features/clients/presentation/actions/client_mutation_actions.dart';
import 'package:bnood/features/clients/presentation/providers/client_identity_provider.dart';
import 'package:bnood/features/clients/presentation/sheets/client_edit_sheet.dart';
import 'package:bnood/features/clients/presentation/widgets/client_balance_card.dart';
import 'package:bnood/features/clients/presentation/widgets/client_detail_stat_grid.dart';
import 'package:bnood/features/clients/presentation/models/client_identity_snapshot.dart';
import 'package:bnood/features/clients/presentation/widgets/client_detail_loading_skeleton.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:bnood/features/home/presentation/widgets/home_section_header.dart';
import '../../../../core/ui/widgets/skeleton/skeleton_text.dart';
import '../../../../core/domain/formatting/see_all_label.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final detail = ref.watch(clientIdentityProvider(clientId));
    final snapshot = detail.valueOrNull;

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final client = snapshot?.client;
          final isArchived = client?.archivedAt != null;
          final accountWritable = ref.watch(accountOfficeMutationsEnabledProvider);
          final mutationsEnabled =
              client != null && !isArchived && accountWritable;
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
                      AppOverflowMenu(
                        buttonKey: const Key('client_detail_overflow'),
                        actions: [
                          if (mutationsEnabled)
                            AppOverflowMenuAction(
                              label: l10n.edit,
                              icon: Assets.icons.documentEditOutline,
                              onSelected: () => showClientEditSheet(
                                context: context,
                                clientId: clientId,
                                clientName: client.name,
                                phone: client.phone,
                              ),
                            ),
                          AppOverflowMenuAction(
                            label: l10n.delete,
                            icon: Assets.icons.deleteSquareOutline,
                            destructive: true,
                            onSelected: () => confirmDeleteClient(
                              context: context,
                              ref: ref,
                              clientId: clientId,
                              clientName: client.name,
                            ),
                          ),
                        ],
                      ),
                      if (hasPhone)
                        Builder(
                          builder: (context) {
                            final waDigits = WhatsAppPhone.waMeDigits(phone);
                            final waEnabled =
                                mutationsEnabled && waDigits != null;
                            return CustomAppBarAction(
                              key: const Key('client_detail_whatsapp'),
                              tooltip: l10n.whatsapp,
                              enabled: waEnabled,
                              onPressed: waEnabled
                                  ? () => _openWhatsApp(context, l10n, waDigits)
                                  : mutationsEnabled
                                  ? () => AppToaster.show(
                                      l10n.whatsappInvalidPhone,
                                      kind: ToastKind.failure,
                                    )
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
                        AppSize.spaceXL.gap,
                        const SkeletonText(
                          role: SkeletonTextRole.title,
                          width: 96,
                        ),
                        AppSize.spaceSM.gap,
                        const HomePersonListSkeleton(count: 2),
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
                                .read(clientIdentityProvider(clientId).notifier)
                                .refreshSilently(),
                            role: AppFallbackActionRole.tertiary,
                          ),
                        ],
                      ),
                    ),
                    data: (data) => _ClientIdentityBody(
                      clientId: clientId,
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

  static Future<void> _openWhatsApp(
    BuildContext context,
    AppLocalizations l10n,
    String waDigits,
  ) async {
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

class _ClientIdentityBody extends ConsumerWidget {
  const _ClientIdentityBody({
    required this.clientId,
    required this.data,
    required this.localeCode,
  });

  final String clientId;
  final ClientIdentitySnapshot data;
  final String localeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projects = data.projects;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClientDetailStatGrid(
          receivedPiastres: data.receivedPiastres,
          spentPiastres: data.spentPiastres,
          remainingPiastres: data.remainingPiastres,
          localeCode: localeCode,
          minorPerMajor: data.usesRemoteMoney
              ? RemoteMoneyUnits.minorPerMajor
              : 100,
        ),
        AppSize.spaceXL.gap,
        HomeSectionHeader(
          title: l10n.navProjects,
          seeAllLabel: seeAllLabelWithCount(
            l10n,
            data.projectCount ?? projects.length,
          ),
          seeAllEnabled: false,
        ),
        AppSize.spaceSM.gap,
        if (projects.isEmpty)
          AppCard(
            child: AppFallback.section(
              icon: Icons.folder_open_outlined,
              title: l10n.homeNoActiveClientsTitle,
              description: l10n.homeNoActiveClientsDescription,
            ),
          )
        else
          for (var i = 0; i < projects.length; i++) ...[
            if (i > 0) AppSize.spaceMD.gap,
            ClientBalanceCard(
              name: projects[i].projectName,
              meta: null,
              receivedPiastres: projects[i].receivedPiastres,
              spentPiastres: projects[i].spentPiastres,
              amountPiastres: projects[i].remainingPiastres,
              accentKey: clientAccentKeyFor(clientId),
              localeCode: localeCode,
              minorPerMajor: RemoteMoneyUnits.minorPerMajor,
              onTap: () {
                final projectId = projects[i].projectId;
                context.push(
                  '/projects/$projectId?clientId=$clientId',
                );
              },
            ),
          ],
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