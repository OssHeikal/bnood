import 'package:bnood/app/widgets/floating_shell_dock.dart';
import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/l10n/app_localizations_ar.dart';
import 'package:bnood/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('satellite diameter token equals pill height', () {
    expect(FloatingShellDock.voucherSatelliteSize, AppSize.shellDockHeight);
    expect(FloatingShellDock.voucherSatelliteSize, 64.0);
  });

  test('en nav tab labels are one word', () {
    final l10n = AppLocalizationsEn();
    for (final label in [l10n.navHome, l10n.navClients, l10n.navDirectory, l10n.navItems]) {
      expect(label.trim().contains(RegExp(r'\s')), isFalse, reason: label);
    }
  });

  test('ar nav tab labels are one word', () {
    final l10n = AppLocalizationsAr();
    expect(l10n.navDirectory, 'الدليل');
    for (final label in [l10n.navHome, l10n.navClients, l10n.navDirectory, l10n.navItems]) {
      expect(label.trim().contains(RegExp(r'\s')), isFalse, reason: label);
    }
  });

  test('directory screen title stays long in Arabic', () {
    expect(AppLocalizationsAr().directoryTitle, 'الموردين والصنايعية');
  });
}
