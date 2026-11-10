/// Max craftsmen shown on Home and Client detail snapshots (full list unchanged).
const int craftsmanSnapshotLimit = 3;

List<T> craftsmanSnapshotRows<T>(List<T> rows) {
  if (rows.length <= craftsmanSnapshotLimit) return rows;
  return rows.sublist(0, craftsmanSnapshotLimit);
}
