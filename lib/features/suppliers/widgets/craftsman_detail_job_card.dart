import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../l10n/app_localizations.dart';
import '../../clients/craftsman_agreement_amount_sheet.dart';
import '../craftsman_detail_snapshot.dart';

class CraftsmanDetailJobCard extends ConsumerWidget {
  const CraftsmanDetailJobCard({
    super.key,
    required this.job,
    required this.craftsmanId,
    required this.craftsmanName,
    required this.localeCode,
    required this.onAgreementSaved,
  });

  final CraftsmanDetailJobRow job;
  final String craftsmanId;
  final String craftsmanName;
  final String localeCode;
  final Future<void> Function() onAgreementSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final hasAgreed = job.agreedPiastres != null;

    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: job.clientId.isNotEmpty
                    ? AppPressable(
                        onPressed: () => context.push('/clients/${job.clientId}'),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            job.clientName,
                            style: text.bodyEmphasis.copyWith(color: colors.primaryDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      )
                    : Text(
                        job.clientName,
                        style: text.bodyEmphasis,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              const SizedBox(width: AppSize.spaceSM),
              AppPressable(
                key: Key('craftsman_detail_edit_agreement_${job.projectId}'),
                onPressed: () async {
                  await showCraftsmanProjectAgreementEditSheet(
                    context: context,
                    ref: ref,
                    projectId: job.projectId,
                    craftsmanId: craftsmanId,
                    craftsmanName: craftsmanName,
                    clientName: job.clientName,
                    clientId: job.clientId,
                    initialAmountPiastres: job.agreedPiastres,
                  );
                  if (context.mounted) await onAgreementSaved();
                },
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSize.spaceSM,
                    AppSize.spaceXS,
                    AppSize.spaceSM,
                    AppSize.spaceXS,
                  ),
                  child: Text(
                    l10n.craftsmanDetailEditAgreement,
                    style: text.caption.copyWith(
                      color: colors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
          if (!hasAgreed) ...[
            AppSize.spaceSM.gap,
            Text(
              l10n.craftsmanDetailNoAgreedAmount,
              style: text.caption.copyWith(color: colors.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ],
          AppSize.spaceMD.gap,
          if (hasAgreed)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Metric(
                      key: const Key('craftsman_job_metric_agreed'),
                      label: l10n.craftsmanAgreedAmount,
                      piastres: job.agreedPiastres!,
                      role: AppAmountRole.neutral,
                      localeCode: localeCode,
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      key: const Key('craftsman_job_metric_paid'),
                      label: l10n.paid,
                      piastres: job.paidPiastres,
                      role: AppAmountRole.spend,
                      localeCode: localeCode,
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      key: const Key('craftsman_job_metric_remaining'),
                      label: l10n.remaining,
                      piastres: job.remainingPiastres!,
                      role: AppAmountRole.remaining,
                      localeCode: localeCode,
                    ),
                  ),
                ],
              ),
            )
          else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IntrinsicWidth(
                child: _Metric(
                  key: const Key('craftsman_job_metric_paid'),
                  label: l10n.paid,
                  piastres: job.paidPiastres,
                  role: AppAmountRole.spend,
                  localeCode: localeCode,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    super.key,
    required this.label,
    required this.piastres,
    required this.role,
    required this.localeCode,
  });

  final String label;
  final int piastres;
  final AppAmountRole role;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSize.spaceXS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: text.caption.copyWith(color: colors.onSurfaceMuted),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSize.spaceXS.gap,
          AppAmount(
            piastres: piastres,
            role: role,
            size: AppAmountSize.small,
            localeCode: localeCode,
          ),
        ],
      ),
    );
  }
}
