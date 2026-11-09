import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/widgets/app_amount.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../home/home_foundation_scope.dart';
import '../home/widgets/home_section_header.dart';
import 'provider_detail_agreement_totals.dart';
import 'provider_detail_provider.dart';
import 'provider_detail_snapshot.dart';
import 'provider_edit_sheet.dart';
import 'provider_mutation_actions.dart';
import '../clients/widgets/client_movement_card.dart';
import '../clients/widgets/interactive_movement_card.dart';
import '../../core/vouchers/vouchers_riverpod.dart';
import 'provider_detail_voucher_line.dart';
import 'widgets/provider_detail_linked_client_block.dart';
import 'widgets/provider_detail_loading_skeleton.dart';
import 'widgets/provider_detail_metric_stack.dart';
import 'widgets/provider_detail_totals_cards.dart';

class ProviderDetailScreen extends ConsumerStatefulWidget {
  const ProviderDetailScreen({super.key, required this.providerId});

  final String providerId;

  @override
  ConsumerState<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends ConsumerState<ProviderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(providerDetailProvider(widget.providerId).notifier).refetchOnOpen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final detail = ref.watch(providerDetailProvider(widget.providerId));
    final provider = detail.valueOrNull?.provider;
    final phone = provider?.phone?.trim();
    final hasPhone = phone != null && phone.isNotEmpty;

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(
              title: provider?.name ?? l10n.directoryTitle,
              subtitle: hasPhone ? phone : null,
              subtitleLtr: true,
              actions: [
                if (provider != null) ...[
                  CustomAppBarAction(
                    key: const Key('provider_detail_edit'),
                    tooltip: l10n.edit,
                    onPressed: () => showProviderEditSheet(context, provider: provider),
                    child: ShellNavIcon(
                      asset: Assets.icons.documentEditOutline,
                      color: colors.onSurface,
                      size: AppSize.icon,
                      semanticsLabel: l10n.edit,
                    ),
                  ),
                  CustomAppBarAction(
                    key: const Key('provider_detail_delete'),
                    tooltip: l10n.delete,
                    onPressed: () async {
                      final deleted = await confirmDeleteProvider(
                        context,
                        ref,
                        providerId: provider.id,
                        name: provider.name,
                      );
                      if (deleted && context.mounted) {
                        Navigator.of(context).maybePop();
                      }
                    },
                    child: ShellNavIcon(
                      asset: Assets.icons.deleteSquareOutline,
                      color: colors.onSurface,
                      size: AppSize.icon,
                      semanticsLabel: l10n.delete,
                    ),
                  ),
                ],
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () =>
                  ref.read(providerDetailProvider(widget.providerId).notifier).refetchOnOpen(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppSize.screenPadding,
                  AppSize.spaceSM,
                  AppSize.screenPadding,
                  AppSize.spaceMD + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  AsyncValueBody(
                    value: detail,
                    loadingPlaceholder: ProviderDetailLoadingSkeleton(
                      showClients: detail.valueOrNull?.provider.type == AppProviderType.craftsman,
                    ),
                    error: (error, _) {
                      if (error is ProviderDetailNotFound) {
                        return AppCard(
                          child: AppFallback.section(
                            icon: Icons.person_off_outlined,
                            title: l10n.providerDetailNotFoundTitle,
                          ),
                        );
                      }
                      return AppCard(
                        child: AppFallback.section(
                          icon: Icons.error_outline,
                          title: l10n.homeLoadErrorTitle,
                          description: error.toString(),
                          actions: [
                            AppFallbackAction(
                              label: l10n.retry,
                              onPressed: () => ref
                                  .read(providerDetailProvider(widget.providerId).notifier)
                                  .refetchOnOpen(),
                              role: AppFallbackActionRole.tertiary,
                            ),
                          ],
                        ),
                      );
                    },
                    data: (data) => _ProviderDetailBody(
                      providerId: widget.providerId,
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

class _ProviderDetailBody extends ConsumerWidget {
  const _ProviderDetailBody({
    required this.providerId,
    required this.data,
    required this.localeCode,
  });

  final String providerId;
  final ProviderDetailSnapshot data;
  final String localeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = data.provider;
    final isCraftsman = provider.type == AppProviderType.craftsman;

    Future<void> afterAgreementChanged() async {
      await ref.read(providerDetailProvider(providerId).notifier).refreshSilently();
    }

    final agreementTotals = isCraftsman && data.clientAgreements.isNotEmpty
        ? aggregateProviderAgreements(data.clientAgreements)
        : null;
    final mutationsEnabled = ref.watch(remoteVouchersEnabledProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isCraftsman && agreementTotals != null) ...[
          ProviderDetailTotalsCards(
            key: const Key('provider_detail_agreement_totals_header'),
            totals: agreementTotals,
            agreedLabel: l10n.craftsmanAgreedAmount,
            paidLabel: l10n.paid,
            remainingLabel: l10n.remaining,
            localeCode: localeCode,
          ),
          AppSize.spaceXL.gap,
        ],
        if (!isCraftsman) ...[
          AppCard(
            key: const Key('provider_detail_supplier_paid_header'),
            padding: const EdgeInsets.all(AppSize.spaceMD),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: ProviderDetailMetricStack(
                label: l10n.supplierTotalPaidLabel,
                piastres: data.totalVoucherMinor,
                role: AppAmountRole.spend,
                localeCode: localeCode,
              ),
            ),
          ),
          AppSize.spaceXL.gap,
        ],
        if (isCraftsman) ...[
          HomeSectionHeader(title: l10n.providerDetailLinkedClientsTitle),
          AppSize.spaceSM.gap,
          if (data.clientAgreements.isEmpty)
            AppCard(
              child: AppFallback.section(
                icon: Icons.people_outline,
                title: l10n.providerDetailNoLinkedClients,
              ),
            )
          else
            for (var i = 0; i < data.clientAgreements.length; i++) ...[
              if (i > 0) AppSize.spaceMD.gap,
              ProviderDetailLinkedClientBlock(
                row: data.clientAgreements[i],
                providerId: providerId,
                providerName: provider.name,
                localeCode: localeCode,
                onChanged: afterAgreementChanged,
              ),
            ],
          AppSize.spaceXL.gap,
        ],
        if (data.voucherHistory.isNotEmpty) ...[
          HomeSectionHeader(title: l10n.movements),
          if (isCraftsman) AppSize.spaceSM.gap,
          if (!isCraftsman) AppSize.spaceSM.gap,
          for (var i = 0; i < data.voucherHistory.length; i++) ...[
            if (i > 0) AppSize.spaceMD.gap,
            InteractiveMovementCard(
              key: Key('provider_detail_movement_${data.voucherHistory[i].voucher.id}'),
              line: providerVoucherMovementLine(data.voucherHistory[i]),
              localeCode: localeCode,
              mutationsEnabled: mutationsEnabled,
              contextMode: ClientMovementCardContext.partyDetail,
              partyClientId: data.voucherHistory[i].voucher.clientId,
              partyClientName: data.voucherHistory[i].clientName,
              ledgerClientId: data.voucherHistory[i].voucher.clientId,
            ),
          ],
        ],
      ],
    );
  }
}
