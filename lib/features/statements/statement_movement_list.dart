import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/database/database.dart';
import '../../core/widgets/app_amount.dart';
import '../../core/widgets/app_card.dart';
import 'statement_movement_text.dart';

class StatementMovementList extends StatelessWidget {
  const StatementMovementList({
    super.key,
    required this.rows,
    required this.l10n,
    required this.localeCode,
    this.partyNameFor,
  });

  final List<Transaction> rows;
  final AppLocalizations l10n;
  final String localeCode;
  final String? Function(Transaction t)? partyNameFor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.outlineSubtle),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.spaceMD,
                vertical: AppSize.spaceSM + 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StatementMovementText.primaryLine(rows[i], l10n),
                          style: text.bodyEmphasis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          StatementMovementText.subtitle(
                            t: rows[i],
                            l10n: l10n,
                            partyName: partyNameFor?.call(rows[i]),
                            clientName: partyNameFor?.call(rows[i]),
                          ),
                          style: text.caption.copyWith(color: colors.onSurfaceMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSize.spaceSM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppAmount(
                        piastres: rows[i].amountPiastres,
                        localeCode: localeCode,
                        size: AppAmountSize.small,
                        role: rows[i].kind == 'receive' ? AppAmountRole.receive : AppAmountRole.spend,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        StatementMovementText.formatMovementDate(rows[i].date),
                        style: text.caption.copyWith(color: colors.onSurfaceMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
