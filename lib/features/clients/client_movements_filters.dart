enum ClientMovementsSort {
  dateDesc,
  dateAsc,
}

extension ClientMovementsSortApi on ClientMovementsSort {
  String get apiValue => this == ClientMovementsSort.dateAsc ? 'date_asc' : 'date_desc';
}

class ClientMovementsFilters {
  const ClientMovementsFilters({
    this.searchQuery = '',
    this.itemId,
    this.itemName,
    this.sort = ClientMovementsSort.dateDesc,
    this.from,
    this.to,
  });

  final String searchQuery;
  final String? itemId;
  final String? itemName;
  final ClientMovementsSort sort;
  final DateTime? from;
  final DateTime? to;

  bool get hasSearch => searchQuery.trim().isNotEmpty;

  bool get hasItemFilter => itemId != null && itemId!.isNotEmpty;

  bool get hasNonDefaultSort => sort != ClientMovementsSort.dateDesc;

  bool get hasDateFilter => from != null || to != null;

  bool get hasAnyFilter =>
      hasSearch || hasItemFilter || hasNonDefaultSort || hasDateFilter;

  static String? formatApiDate(DateTime? date) {
    if (date == null) return null;
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
