import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_fallback.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../l10n/app_localizations.dart';
import '../../clients/widgets/client_detail_movement_row.dart';
import '../../home/widgets/home_section_header.dart';
import '../supplier_detail_snapshot.dart';

class SupplierDetailHistorySection extends StatelessWidget {
  const SupplierDetailHistorySection({
    super.key,
    required this.history,
    required this.localeCode,
  });

  final List<SupplierDetailHistoryEntry> history;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(title: l10n.supplierDetailTransactionsSection),
        AppSize.spaceSM.gap,
        if (history.isEmpty)
          AppCard(
            child: AppFallback.section(
              icon: Icons.receipt_long_outlined,
              title: l10n.supplierDetailNoTransactions,
            ),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG, vertical: AppSize.spaceXS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < history.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: colors.outlineSubtle),
                  _SupplierHistoryBlock(
                    entry: history[i],
                    localeCode: localeCode,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _SupplierHistoryBlock extends StatelessWidget {
  const _SupplierHistoryBlock({
    required this.entry,
    required this.localeCode,
  });

  final SupplierDetailHistoryEntry entry;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final clientId = entry.clientId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSize.spaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (clientId.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppPressable(
                onPressed: () => context.push('/clients/$clientId'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    entry.clientName,
                    style: text.caption.copyWith(
                      color: colors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ClientDetailMovementRow(line: entry.line, localeCode: localeCode),
        ],
      ),
    );
  }
}
