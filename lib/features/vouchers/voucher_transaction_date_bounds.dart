/// Domain date limits for voucher transaction entry (not demo 2035 caps).
abstract final class VoucherTransactionDateBounds {
  static DateTime get first => DateTime(2000, 1, 1);

  static DateTime get last {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
