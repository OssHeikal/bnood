/// Online ledger amounts: integer minor units with 100 minor per 1 EGP major (piastres).
abstract final class RemoteMoneyUnits {
  RemoteMoneyUnits._();

  static const minorPerMajor = 100;

  static int majorToMinor(double major) => (major * minorPerMajor).round();

  static double minorToMajor(int minor) => minor / minorPerMajor;
}
