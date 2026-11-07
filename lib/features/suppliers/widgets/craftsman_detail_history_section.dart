import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_fallback.dart';
import '../../../l10n/app_localizations.dart';
import '../../clients/widgets/client_movement_card.dart';
import '../../clients/widgets/interactive_movement_card.dart';
import '../../home/widgets/home_section_header.dart';
import '../craftsman_detail_snapshot.dart';

class CraftsmanDetailHistorySection extends StatelessWidget {
  const CraftsmanDetailHistorySection({
    super.key,
    required this.history,
    required this.localeCode,
  });

  final List<CraftsmanDetailHistoryEntry> history;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(title: l10n.craftsmanDetailLaborHistorySection),
        AppSize.spaceSM.gap,
        if (history.isEmpty)
          AppCard(
            child: AppFallback.section(
              icon: Icons.receipt_long_outlined,
              title: l10n.craftsmanDetailNoLaborHistory,
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < history.length; i++) ...[
                if (i > 0) AppSize.spaceMD.gap,
                _HistoryBlock(entry: history[i], localeCode: localeCode),
              ],
            ],
          ),
      ],
    );
  }
}

class _HistoryBlock extends ConsumerWidget {
  const _HistoryBlock({
    required this.entry,
    required this.localeCode,
  });

  final CraftsmanDetailHistoryEntry entry;
  final String localeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InteractiveMovementCard(
      line: entry.line,
      localeCode: localeCode,
      mutationsEnabled: true,
      contextMode: ClientMovementCardContext.partyDetail,
      partyClientId: entry.clientId,
      partyClientName: entry.clientName,
    );
  }
}
