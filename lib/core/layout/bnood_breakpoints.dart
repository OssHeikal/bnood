import 'package:responsive_framework/responsive_framework.dart';

/// Bnood responsive width bands: phone 0–450, tablet 451–1023, desktop 1024+.
abstract final class BnoodBreakpoints {
  static const mobileMax = 450.0;
  static const tabletMax = 1023.0;

  static const mobileName = MOBILE;
  static const tabletName = TABLET;
  static const desktopName = DESKTOP;

  static List<Breakpoint> get all => const [
        Breakpoint(start: 0, end: mobileMax, name: mobileName),
        Breakpoint(start: mobileMax + 1, end: tabletMax, name: tabletName),
        Breakpoint(start: tabletMax + 1, end: double.infinity, name: desktopName),
      ];
}
