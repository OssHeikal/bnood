import '../../core/ui/resources/gen/assets.gen.dart';

/// Owner SVG mapping for shell navigation (see [docs/assets/nav-icon-mapping.md]).
abstract final class ShellNavIcons {
  static SvgGenImage get home => Assets.icons.homeOutline;
  static SvgGenImage get projects => Assets.icons.projectFolderOutline;
  static SvgGenImage get providers => Assets.icons.directoryOutline;
  static SvgGenImage get voucherAdd => Assets.icons.addOutline;
}