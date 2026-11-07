import '../../core/resources/gen/assets.gen.dart';

/// Owner SVG mapping for shell navigation (see [docs/assets/nav-icon-mapping.md]).
abstract final class ShellNavIcons {
  static SvgGenImage get home => Assets.icons.homeOutline;
  static SvgGenImage get clients => Assets.icons.clientsOutline;
  static SvgGenImage get directory => Assets.icons.directoryOutline;
  static SvgGenImage get items => Assets.icons.itemsLayersOutline;
  static SvgGenImage get voucherAdd => Assets.icons.addOutline;
}
