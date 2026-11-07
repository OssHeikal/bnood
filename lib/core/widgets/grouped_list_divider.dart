import 'package:flutter/material.dart';

import '../config/theme/app_size.dart';
import '../config/theme/app_colors.dart';

enum GroupedListDividerKind {
  nav,
  insetStart,
  insetBoth,
  leadingIcon,
}

abstract final class GroupedListDivider {
  static const navIndent = AppSize.spaceLG + AppSize.spaceXL * 2 + AppSize.spaceMD;
  static const leadingIconIndent = AppSize.spaceLG + AppSize.icon + AppSize.spaceMD;

  /// [Divider] indents are physical left/right, not logical start/end.
  static Widget build(
    BuildContext context, {
    required GroupedListDividerKind kind,
    Color? color,
  }) {
    final dividerColor = color ?? context.colors.outlineSubtle;
    return switch (kind) {
      GroupedListDividerKind.nav => Divider(
        height: 1,
        thickness: AppSize.borderWidthHairline,
        color: dividerColor,
        indent: navIndent,
      ),
      GroupedListDividerKind.insetStart => Divider(
        height: 1,
        thickness: AppSize.borderWidthHairline,
        color: dividerColor,
        indent: AppSize.spaceLG,
      ),
      GroupedListDividerKind.insetBoth => Divider(
        height: 1,
        thickness: AppSize.borderWidthHairline,
        color: dividerColor,
        indent: AppSize.spaceLG,
        endIndent: AppSize.spaceLG,
      ),
      GroupedListDividerKind.leadingIcon => Divider(
        height: 1,
        thickness: AppSize.borderWidthHairline,
        color: dividerColor,
        indent: leadingIconIndent,
      ),
    };
  }
}
