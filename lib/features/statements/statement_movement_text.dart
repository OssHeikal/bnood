import 'package:bnood/l10n/app_localizations.dart';

import '../../core/database/database.dart';
import '../../core/formatting/display_digits.dart';

abstract final class StatementMovementText {
  static String formatMovementDate(DateTime date) {
    return '${DisplayDigits.formatInteger(date.day)}/'
        '${DisplayDigits.formatInteger(date.month)}/'
        '${DisplayDigits.formatInteger(date.year)}';
  }

  static String primaryLine(Transaction t, AppLocalizations l10n) {
    final d = t.description?.trim();
    if (d != null && d.isNotEmpty) return d;
    return l10n.clientDetailNoDescription;
  }

  static String subtitle({
    required Transaction t,
    required AppLocalizations l10n,
    String? partyName,
    String? clientName,
  }) {
    if (t.kind == 'receive') {
      final method = t.method == 'cash' ? l10n.cash : l10n.transfer;
      return '${l10n.receive} · $method';
    }
    final type = t.expenseType == 'labor' ? l10n.labor : l10n.materials;
    final parts = <String>[type];
    if (partyName != null && partyName.isNotEmpty) parts.add(partyName);
    if (clientName != null && clientName.isNotEmpty) parts.add(clientName);
    return parts.join(' · ');
  }
}
