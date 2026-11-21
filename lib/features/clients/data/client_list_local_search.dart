import 'package:bnood/core/utils/arabic_search_normalizer.dart';

import 'package:bnood/features/home/data/home_row_models.dart';

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
