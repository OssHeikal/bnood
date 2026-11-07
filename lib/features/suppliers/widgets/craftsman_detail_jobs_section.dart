import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_fallback.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/widgets/home_section_header.dart';
import '../craftsman_detail_snapshot.dart';
import 'craftsman_detail_job_card.dart';

class CraftsmanDetailJobsSection extends StatelessWidget {
  const CraftsmanDetailJobsSection({
    super.key,
    required this.jobs,
    required this.craftsmanId,
    required this.craftsmanName,
    required this.localeCode,
    required this.onAgreementSaved,
  });

  final List<CraftsmanDetailJobRow> jobs;
  final String craftsmanId;
  final String craftsmanName;
  final String localeCode;
  final Future<void> Function() onAgreementSaved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(title: l10n.craftsmanDetailJobsSection),
        AppSize.spaceSM.gap,
        if (jobs.isEmpty)
          AppCard(
            child: AppFallback.section(
              icon: Icons.handyman_outlined,
              title: l10n.craftsmanDetailNoJobs,
            ),
          )
        else
          for (var i = 0; i < jobs.length; i++) ...[
            if (i > 0) AppSize.spaceMD.gap,
            CraftsmanDetailJobCard(
              job: jobs[i],
              craftsmanId: craftsmanId,
              craftsmanName: craftsmanName,
              localeCode: localeCode,
              onAgreementSaved: onAgreementSaved,
            ),
          ],
      ],
    );
  }
}
