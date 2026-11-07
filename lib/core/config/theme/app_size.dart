/// Spacing and radii aligned with index.html and UI rules (4/8/12/16/24/32; 8/16/24).
abstract final class AppSize {
  static const screenPadding = 16.0;
  static const gap = 12.0;
  static const radius = gap;
  static const radiusSM = 8.0;
  static const radiusMD = 16.0;
  static const radiusLG = 24.0;
  static const cardRadius = radiusMD;
  static const shellDockRadius = 22.0;
  static const shellDockHeight = 64.0;
  /// Painted outer height of the floating shell navigation pill track.
  static const shellDockPillExtent = shellDockHeight;
  /// Voucher satellite painted disc; aligned to pill track (tap slot stays [shellDockPillExtent]).
  static const shellDockVoucherDiameter = shellDockPillExtent - spaceXS;
  static const shellDockClearance = 112.0;
  static const shellBarHeight = 86.0;
  static const iconExtraLarge = 48.0;
  static const icon = 24.0;
  static const iconCompact = 20.0;
  static const iconSmall = 16.0;
  /// Stat card header glyph container (receive / spend / remaining).
  static const statIconBox = 32.0;
  static const buttonHeight = 48.0;
  static const buttonHeightSmall = 40.0;
  static const buttonHeightLarge = 52.0;
  static const fieldHeight = 48.0;
  /// Opt-in taller single-line fields (forms); scales with content, not a hard text clip.
  static const fieldHeightComfortable = buttonHeightLarge;
  static const searchFieldHeight = hitMin;
  static const borderWidth = 1.0;
  static const spaceXS = 4.0;
  static const spaceSM = 8.0;
  static const spaceMD = gap;
  static const spaceLG = 16.0;
  static const spaceXL = 24.0;
  static const space2XL = 32.0;
  static const hitMin = 44.0;
  static const hitMinAndroid = 48.0;
  static const focusWidth = 2.0;
  static const borderWidthHairline = 0.5;
  static const avatar = 48.0;
  static const logoMark = 32.0;
  static const labelStackHeight = 40.0;
  static const floatedLabelHeight = 16.0;
  static const valueRowHeight = 24.0;
  /// Inline suffix/prefix gutter (e.g. EGP) inside bordered fields.
  static const adornmentSlotWidth = 40.0;
  static const multilineFieldHeight = 128.0;
  static const mobileScaleWidth = 390.0;
}
