import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/database/database.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';

class SupplierDetailProfile extends StatelessWidget {
  const SupplierDetailProfile({
    super.key,
    required this.supplier,
  });

  final Supplier supplier;

  @override
  Widget build(BuildContext context) {
    final notes = supplier.notes?.trim();
    final hasNotes = notes != null && notes.isNotEmpty;
    if (!hasNotes) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasNotes)
            _ProfileField(
              label: l10n.supplierProfileNotesLabel,
              value: notes,
            ),
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
