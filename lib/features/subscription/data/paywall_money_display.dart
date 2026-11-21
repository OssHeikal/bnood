import 'package:bnood/core/domain/formatting/display_digits.dart';
import 'package:bnood/core/domain/money/remote_money_units.dart';

/// Whole-EGP paywall amounts (no fractional piastres in UI); matches backend rounding.
abstract final class PaywallMoneyDisplay {
  static int wholeMajorFromMinor(int minor) =>
      (minor / RemoteMoneyUnits.minorPerMajor).round();

  static int wholeMajorPerMonthFromYearly(int yearlyMinor) =>
      wholeMajorFromMinor((yearlyMinor / 12).round());

  static String formatMajorAmount(int major, {required bool arabic}) {
    final digits = DisplayDigits.formatInteger(major);
    return arabic ? '$digits ج.م' : '$digits EGP';
  }

  static String formatMinorWhole(int minor, {required bool arabic}) =>
      formatMajorAmount(wholeMajorFromMinor(minor), arabic: arabic);

  static String formatPerMonthFromMinor(
    int perMonthMinor, {
    required bool arabic,
  }) => formatMajorAmount(wholeMajorFromMinor(perMonthMinor), arabic: arabic);
}
