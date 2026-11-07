import 'package:flutter/material.dart';

import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/app_amount.dart';
import '../../core/widgets/app_card.dart';

/// Shared stat tile padding for client statement summary cards.
const statementSummaryStatPadding = EdgeInsets.symmetric(horizontal: AppSize.spaceMD, vertical: AppSize.spaceMD);

/// Comfortable inset for full-width opening-balance strip (matches stat cards).
const statementOpeningBalancePadding = EdgeInsets.symmetric(horizontal: AppSize.spaceMD, vertical: AppSize.spaceMD);

/// Fixed gap between stat label and amount (not [MainAxisAlignment.spaceBetween]).
const statementSummaryLabelAmountGap = AppSize.spaceSM;

class StatementSummaryStatCard extends StatelessWidget {
  const StatementSummaryStatCard({
    super.key,
    required this.label,
    required this.piastres,
    required this.preset,
    required this.role,
    required this.localeCode,
    this.cardKey,
  });

  final String label;
  final int piastres;
  final AppCardPreset preset;
  final AppAmountRole role;
  final String localeCode;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;

    return AppCard(
      key: cardKey,
      preset: preset,
      padding: statementSummaryStatPadding,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              textAlign: TextAlign.start,
              style: text.caption.copyWith(color: colors.onSurfaceMuted),
              maxLines: 3,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: statementSummaryLabelAmountGap),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppAmount(piastres: piastres, localeCode: localeCode, size: AppAmountSize.small, role: role),
            ),
          ],
        ),
      ),
    );
  }
}

class StatementOpeningBalanceStrip extends StatelessWidget {
  const StatementOpeningBalanceStrip({
    super.key,
    required this.label,
    required this.piastres,
    required this.localeCode,
  });

  final String label;
  final int piastres;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final text = context.text;

    return AppCard(
      key: const Key('statement_opening_balance'),
      padding: statementOpeningBalancePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(label, textAlign: TextAlign.start, style: text.label),
          ),
          const SizedBox(width: AppSize.spaceMD),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppAmount(
              piastres: piastres,
              localeCode: localeCode,
              size: AppAmountSize.small,
              role: AppAmountRole.remaining,
            ),
          ),
        ],
      ),
    );
  }
}

class StatementLabeledAmountRow extends StatelessWidget {
  const StatementLabeledAmountRow({
    super.key,
    required this.label,
    required this.piastres,
    required this.localeCode,
    this.role = AppAmountRole.neutral,
    this.emphasized = false,
    this.rowKey,
  });

  final String label;
  final int piastres;
  final String localeCode;
  final AppAmountRole role;
  final bool emphasized;
  final Key? rowKey;

  @override
  Widget build(BuildContext context) {
    final text = context.text;

    return Padding(
      key: rowKey,
      padding: const EdgeInsets.symmetric(vertical: AppSize.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(label, textAlign: TextAlign.start, style: emphasized ? text.sectionTitle : text.body),
          ),
          const SizedBox(width: AppSize.spaceMD),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppAmount(
              piastres: piastres,
              localeCode: localeCode,
              size: emphasized ? AppAmountSize.medium : AppAmountSize.small,
              role: role,
            ),
          ),
        ],
      ),
    );
  }
}
