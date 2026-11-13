import '../repositories/bnood_repository.dart';
import '../utils/arabic_search_normalizer.dart';

List<HomeClientBalanceRow> filterHomeClientRowsBySearch(
  List<HomeClientBalanceRow> rows,
  String query,
) {
  final q = query.trim();
  if (q.isEmpty) return rows;
  return rows
      .where(
        (row) => ArabicSearchNormalizer.matchesAny(
          query: q,
          haystacks: [row.client.name, row.client.phone ?? ''],
        ),
      )
      .toList();
}
