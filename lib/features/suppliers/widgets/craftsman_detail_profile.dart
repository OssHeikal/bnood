import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/database/database.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';

class CraftsmanDetailProfile extends StatelessWidget {
  const CraftsmanDetailProfile({super.key, required this.craftsman});

  final CraftsmenData craftsman;

  @override
  Widget build(BuildContext context) {
    final trade = craftsman.trade?.trim();
    final notes = craftsman.notes?.trim();
    final hasTrade = trade != null && trade.isNotEmpty;
    final hasNotes = notes != null && notes.isNotEmpty;
    if (!hasTrade && !hasNotes) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasTrade) ...[
            _ProfileField(label: l10n.craftsmanProfileTradeLabel, value: trade),
            if (hasNotes) Divider(height: 1, color: colors.outlineSubtle),
          ],
          if (hasNotes) _ProfileField(label: l10n.craftsmanProfileNotesLabel, value: notes),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSize.spaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
          AppSize.spaceXS.gap,
          Text(value, style: text.body),
        ],
      ),
    );
  }
}
