/// Online ledger amounts: integer minor units with 1000 minor per 1 EGP major.
abstract final class RemoteMoneyUnits {
  RemoteMoneyUnits._();

  static const minorPerMajor = 1000;

  static int majorToMinor(double major) => (major * minorPerMajor).round();

  static double minorToMajor(int minor) => minor / minorPerMajor;
}
