import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/clients/client_statement_record.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/money/remote_money_units.dart';
import '../../core/widgets/app_amount.dart';
import '../../core/widgets/app_card.dart';
import 'statement_summary_widgets.dart';

class StatementApiClientDocument extends StatelessWidget {
  const StatementApiClientDocument({
    super.key,
    required this.clientName,
    required this.statement,
    required this.localeCode,
  });

  final String clientName;
  final AppClientStatement statement;
  final String localeCode;

  static const _minorPerMajor = RemoteMoneyUnits.minorPerMajor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(clientName, style: text.pageTitle),
        const SizedBox(height: AppSize.spaceMD),
        _summaryStats(context, l10n),
        const SizedBox(height: AppSize.spaceLG),
        Text(l10n.navItems, style: text.sectionTitle),
        const SizedBox(height: AppSize.spaceSM),
        if (statement.items.isEmpty)
          Text(
            l10n.clientDetailNoItemSpend,
            style: text.caption.copyWith(color: colors.onSurfaceMuted),
          )
        else
          for (var i = 0; i < statement.items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSize.spaceSM),
            _itemRow(context, statement.items[i]),
          ],
      ],
    );
  }

  Widget _summaryStats(BuildContext context, AppLocalizations l10n) {
    const cardWidth = 124.0;
    final cards = [
      _StatSpec(
        l10n.statementTotalReceived,
        statement.receivedMinor,
        AppCardPreset.statReceive,
        AppAmountRole.receive,
      ),
      _StatSpec(
        l10n.statementTotalSpent,
        statement.spentMinor,
        AppCardPreset.statSpend,
        AppAmountRole.spend,
      ),
      _StatSpec(
        l10n.statementClosingEndOfPeriod,
        statement.remainingMinor,
        AppCardPreset.statRemaining,
        AppAmountRole.remaining,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final fitsRow = constraints.maxWidth >= cardWidth * cards.length + AppSize.spaceSM * (cards.length - 1);
        final children = [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSize.spaceSM),
            Expanded(
              flex: fitsRow ? 1 : 0,
              child: SizedBox(
                width: fitsRow ? null : cardWidth,
                child: StatementSummaryStatCard(
                  label: cards[i].label,
                  piastres: cards[i].piastres,
                  preset: cards[i].preset,
                  role: cards[i].role,
                  localeCode: localeCode,
                  minorPerMajor: _minorPerMajor,
                ),
              ),
            ),
          ],
        ];
        if (fitsRow) {
          return IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          );
        }
        return IntrinsicHeight(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        );
      },
    );
  }

  Widget _itemRow(BuildContext context, AppClientStatementItemSpend item) {
    final text = context.text;
    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(item.name, style: text.sectionTitle)),
          AppAmount(
            piastres: item.spentMinor,
            localeCode: localeCode,
            size: AppAmountSize.small,
            role: AppAmountRole.spend,
            minorPerMajor: _minorPerMajor,
          ),
        ],
      ),
    );
  }
}

class _StatSpec {
  const _StatSpec(this.label, this.piastres, this.preset, this.role);

  final String label;
  final int piastres;
  final AppCardPreset preset;
  final AppAmountRole role;
}
