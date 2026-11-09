import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/utils/extensions/bidi_isolate.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../home/home_foundation_scope.dart';
import '../home/widgets/home_section_header.dart';
import 'provider_detail_provider.dart';
import 'provider_detail_snapshot.dart';
import 'provider_edit_sheet.dart';
import 'provider_mutation_actions.dart';
import 'widgets/provider_detail_client_agreement_card.dart';
import 'widgets/provider_detail_loading_skeleton.dart';

class ProviderDetailScreen extends ConsumerWidget {
  const ProviderDetailScreen({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final detail = ref.watch(providerDetailProvider(providerId));
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
                            onPressed: () =>
                                ref.read(providerDetailProvider(providerId).notifier).refreshSilently(),
                            role: AppFallbackActionRole.tertiary,
                          ),
                        ],
                      ),
                    );
                  },
                  data: (data) => _ProviderDetailBody(
                    providerId: providerId,
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
    final colors = context.colors;
    final text = context.text;
    final provider = data.provider;
    final kindLabel = provider.type == AppProviderType.supplier
        ? l10n.directorySupplierKindMeta
        : l10n.directoryCraftsmanKindMeta;

    Future<void> afterAgreementChanged() async {
      await ref.read(providerDetailProvider(providerId).notifier).refreshSilently();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.providerTypeLabel,
                style: text.caption.copyWith(color: colors.onSurfaceMuted),
              ),
              AppSize.spaceXS.gap,
              Text(kindLabel, style: text.body),
              AppSize.spaceMD.gap,
              Text(
                l10n.providerNameLabel,
                style: text.caption.copyWith(color: colors.onSurfaceMuted),
              ),
              AppSize.spaceXS.gap,
              Text(provider.name, style: text.bodyEmphasis),
              if (provider.phone != null && provider.phone!.trim().isNotEmpty) ...[
                AppSize.spaceMD.gap,
                Text(
                  l10n.authPhone,
                  style: text.caption.copyWith(color: colors.onSurfaceMuted),
                ),
                AppSize.spaceXS.gap,
                Text(
                  LtrIsolate.isolate(provider.phone!.trim()),
                  style: text.body,
                ),
              ],
            ],
          ),
        ),
        if (provider.type == AppProviderType.craftsman) ...[
          AppSize.spaceXL.gap,
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
              ProviderDetailClientAgreementCard(
                row: data.clientAgreements[i],
                providerId: providerId,
                providerName: provider.name,
                localeCode: localeCode,
                onChanged: afterAgreementChanged,
              ),
            ],
        ],
      ],
    );
  }
}
