import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'bnood_breakpoints.dart';

/// Layout tokens and [BuildContext] helpers. Without a [ResponsiveBreakpoints]
/// ancestor, helpers assume mobile so default test surfaces (e.g. 800px) stay phone.
abstract final class BnoodLayout {
  static const formMaxWidth = 560.0;
  static const listMaxWidth = 720.0;
  static const pageMaxWidth = 1120.0;

  static const gutterMobile = 16.0;
  static const gutterTablet = 40.0;
  static const gutterDesktop = 40.0;
}

extension BnoodLayoutContext on BuildContext {
  ResponsiveBreakpointsData? get _breakpoints {
    final inherited = getInheritedWidgetOfExactType<InheritedResponsiveBreakpoints>();
    return inherited?.data;
  }

  double get _layoutWidth {
    final data = _breakpoints;
    final reported = data?.screenWidth ?? 0;
    if (reported > 0) return reported;
    return MediaQuery.sizeOf(this).width;
  }

  bool get isBnoodMobile {
    if (_breakpoints == null) return true;
    return _layoutWidth <= BnoodBreakpoints.mobileMax;
  }

  bool get isBnoodTablet {
    if (_breakpoints == null) return false;
    final w = _layoutWidth;
    return w > BnoodBreakpoints.mobileMax && w <= BnoodBreakpoints.tabletMax;
  }

  bool get isBnoodDesktop {
    if (_breakpoints == null) return false;
    return _layoutWidth > BnoodBreakpoints.tabletMax;
  }

  /// Shorthand used by layout widgets.
  bool get isTablet => isBnoodTablet;
  bool get isDesktop => isBnoodDesktop;

  double get pageGutter {
    if (isBnoodMobile) return BnoodLayout.gutterMobile;
    return BnoodLayout.gutterTablet;
  }

  EdgeInsetsDirectional get pagePadding => EdgeInsetsDirectional.fromSTEB(pageGutter, 0, pageGutter, 0);

  /// Max content width for modal sheets and full-screen form routes on tablet+.
  double get formMaxWidth => BnoodLayout.formMaxWidth;

  double get listMaxWidth => BnoodLayout.listMaxWidth;

  double get pageMaxWidth => BnoodLayout.pageMaxWidth;
}
