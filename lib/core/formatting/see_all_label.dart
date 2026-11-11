import '../../l10n/app_localizations.dart';

String seeAllLabelWithCount(AppLocalizations l10n, int count) {
  if (count <= 0) return l10n.seeAll;
  return l10n.seeAllWithCount(count);
}

int sectionSeeAllCount({int? total, required int visibleLength}) {
  if (total != null && total >= visibleLength) return total;
  return visibleLength;
}
