import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../app/widgets/shell_nav_icon.dart';
import '../../core/clients/client_statement_record.dart';
import '../../core/clients/statement_item_visual.dart';
import '../../core/items/item_api_record.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_shape.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/money/remote_money_units.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_amount.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../features/items/item_semantic_icon.dart';
import 'statement_issuer_header.dart';
import 'statement_summary_widgets.dart';

class StatementApiClientDocument extends StatelessWidget {
  const StatementApiClientDocument({
    super.key,
    required this.clientName,
    required this.statement,
    required this.localeCode,
    this.catalogById = const {},
  });

  final String clientName;
  final AppClientStatement statement;
  final String localeCode;
  final Map<String, CatalogItem> catalogById;

  static const _minorPerMajor = RemoteMoneyUnits.minorPerMajor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = context.text;

    final issuer = statement.issuer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (issuer != null) ...[
          StatementIssuerHeader(issuer: issuer),
          const SizedBox(height: AppSize.spaceMD),
        ],
        Text(clientName, style: text.pageTitle),
        const SizedBox(height: AppSize.spaceMD),
        _summaryStats(context, l10n),
        const SizedBox(height: AppSize.spaceLG),
        Text(l10n.navItems, style: text.sectionTitle),
        const SizedBox(height: AppSize.spaceSM),
        if (statement.items.isEmpty)
          AppCard(
            child: AppFallback.section(
              leading: ShellNavIcon(
                asset: Assets.icons.itemsLayersOutline,
                color: context.colors.muted,
                size: AppSize.icon,
              ),
              title: l10n.statementEmptyItemsTitle,
              description: l10n.statementEmptyItemsDescription,
            ),
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
    final cards = [
      _StatSpec(
        l10n.openingBalance,
        statement.openingBalanceMinor,
        AppCardPreset.statRemaining,
        AppAmountRole.remaining,
      ),
      _StatSpec(
        l10n.statementPeriodReceived,
        statement.receivedMinor,
        AppCardPreset.statReceive,
        AppAmountRole.receive,
      ),
      _StatSpec(
        l10n.statementPeriodSpent,
        statement.spentMinor,
        AppCardPreset.statSpend,
        AppAmountRole.spend,
      ),
      _StatSpec(
        l10n.statementClosingLabel,
        statement.closingBalanceMinor,
        AppCardPreset.statRemaining,
        AppAmountRole.remaining,
        emphasized: true,
        cardKey: const Key('statement_stat_closing'),
      ),
    ];

    const gap = AppSize.spaceSM;

    Widget statCell(_StatSpec spec) {
      return StatementSummaryStatCard(
        cardKey: spec.cardKey,
        label: spec.label,
        piastres: spec.piastres,
        preset: spec.preset,
        role: spec.role,
        localeCode: localeCode,
        minorPerMajor: _minorPerMajor,
        emphasized: spec.emphasized,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: statCell(cards[0])),
              const SizedBox(width: gap),
              Expanded(child: statCell(cards[1])),
            ],
          ),
        ),
        const SizedBox(height: gap),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: statCell(cards[2])),
              const SizedBox(width: gap),
              Expanded(child: statCell(cards[3])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemRow(BuildContext context, AppClientStatementItemSpend item) {
    final text = context.text;
    final visual = resolveStatementItemVisual(item, catalogById: catalogById);
    final accent = itemSemanticAccentColor(visual.colorKey);

    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            key: Key('statement_item_icon_${visual.iconKey}'),
            color: accent.withValues(alpha: 0.15),
            shape: AppShape.superellipse(radius: AppSize.radiusSM),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: AppSize.statIconBox,
              height: AppSize.statIconBox,
              child: Center(
                child: itemSemanticIconWidget(
                  iconKey: visual.iconKey,
                  color: accent,
                  size: AppSize.iconSmall,
                ),
              ),
            ),
          ),
          AppSize.spaceMD.gap,
          Expanded(
            child: Text(
              item.name,
              style: text.sectionTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppSize.spaceSM.gap,
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
  const _StatSpec(
    this.label,
    this.piastres,
    this.preset,
    this.role, {
    this.emphasized = false,
    this.cardKey,
  });

  final String label;
  final int piastres;
  final AppCardPreset preset;
  final AppAmountRole role;
  final bool emphasized;
  final Key? cardKey;
}
