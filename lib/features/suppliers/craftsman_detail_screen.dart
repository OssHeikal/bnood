import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../home/home_foundation_scope.dart';
import 'craftsman_detail_provider.dart';
import 'craftsman_detail_snapshot.dart';
import 'widgets/craftsman_detail_history_section.dart';
import 'widgets/craftsman_detail_jobs_section.dart';
import 'widgets/craftsman_detail_loading_skeleton.dart';
import 'widgets/craftsman_detail_labor_stat.dart';
import 'widgets/craftsman_detail_profile.dart';

class CraftsmanDetailScreen extends ConsumerWidget {
  const CraftsmanDetailScreen({super.key, required this.craftsmanId});

  final String craftsmanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final detail = ref.watch(craftsmanDetailProvider(craftsmanId));
    final craftsman = detail.valueOrNull?.craftsman;
    final craftsmanName = craftsman?.name;
    final phone = craftsman?.phone.trim();
    final hasPhone = phone != null && phone.isNotEmpty;

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(
              title: craftsmanName ?? l10n.craftsman,
              subtitle: hasPhone ? phone : null,
              subtitleLtr: true,
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
                  loadingPlaceholder: const CraftsmanDetailLoadingSkeleton(),
                  error: (error, _) {
                    if (error is CraftsmanDetailNotFound) {
                      return AppCard(
                        child: AppFallback.section(
                          icon: Icons.person_off_outlined,
                          title: l10n.craftsmanDetailNotFoundTitle,
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
                                ref.read(craftsmanDetailProvider(craftsmanId).notifier).refreshSilently(),
                            role: AppFallbackActionRole.tertiary,
                          ),
                        ],
                      ),
                    );
                  },
                  data: (data) => _CraftsmanDetailBody(
                    craftsmanId: craftsmanId,
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

class _CraftsmanDetailBody extends ConsumerWidget {
  const _CraftsmanDetailBody({
    required this.craftsmanId,
    required this.data,
    required this.localeCode,
  });

  final String craftsmanId;
  final CraftsmanDetailSnapshot data;
  final String localeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = CraftsmanDetailProfile(craftsman: data.craftsman);
    final hasProfile = data.craftsman.trade?.trim().isNotEmpty == true ||
        data.craftsman.notes?.trim().isNotEmpty == true;

    Future<void> afterAgreementSaved() async {
      await ref.read(craftsmanDetailProvider(craftsmanId).notifier).refreshSilently();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasProfile) ...[
          profile,
          AppSize.spaceLG.gap,
        ],
        CraftsmanDetailLaborStat(
          totalLaborPaidPiastres: data.totalLaborPaidPiastres,
          linkedProjectCount: data.linkedProjectCount,
          localeCode: localeCode,
        ),
        AppSize.spaceXL.gap,
        CraftsmanDetailJobsSection(
          jobs: data.jobs,
          craftsmanId: data.craftsman.id,
          craftsmanName: data.craftsman.name,
          localeCode: localeCode,
          onAgreementSaved: afterAgreementSaved,
        ),
        AppSize.spaceXL.gap,
        CraftsmanDetailHistorySection(
          history: data.history,
          localeCode: localeCode,
        ),
      ],
    );
  }
}
