import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

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

  bool get isBnoodMobile {
    final data = _breakpoints;
    if (data == null) return true;
    return data.isMobile;
  }

  bool get isBnoodTablet {
    final data = _breakpoints;
    if (data == null) return false;
    return data.isTablet;
  }

  bool get isBnoodDesktop {
    final data = _breakpoints;
    if (data == null) return false;
    return data.isDesktop;
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
