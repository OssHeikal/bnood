import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../core/money/period_bounds.dart';

typedef PeriodChanged = void Function(PeriodBounds bounds);

class StatementPeriodControls extends StatelessWidget {
  const StatementPeriodControls({
    super.key,
    required this.bounds,
    required this.onChanged,
  });

  final PeriodBounds bounds;
  final PeriodChanged onChanged;

  Future<void> _pickStart(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: bounds.start,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: AppLocalizations.of(context).period,
    );
    if (picked != null) {
      onChanged(PeriodBounds.normalize(start: picked, end: bounds.end));
    }
  }

  Future<void> _pickEnd(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: bounds.end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: AppLocalizations.of(context).period,
    );
    if (picked != null) {
      onChanged(PeriodBounds.normalize(start: bounds.start, end: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.period, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('من'),
              subtitle: Text(fmt.format(bounds.start)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickStart(context),
            ),
            ListTile(
              title: const Text('إلى'),
              subtitle: Text(fmt.format(bounds.end)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickEnd(context),
            ),
          ],
        ),
      ),
    );
  }
}
