import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'app_breakpoints.dart';

/// Layout tokens and [BuildContext] helpers. Without a [ResponsiveBreakpoints]
/// ancestor, helpers assume mobile so default test surfaces (e.g. 800px) stay phone.
abstract final class AppLayout {
  static const formMaxWidth = 600.0;
  static const toastMaxWidth = 520.0;
  static const listMaxWidth = 720.0;
  static const pageMaxWidth = 1120.0;

  static const gutterMobile = 16.0;
  static const gutterTablet = 40.0;
  static const gutterDesktop = 40.0;
}

extension AppLayoutContext on BuildContext {
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

  bool get isMobileLayout {
    if (_breakpoints == null) return true;
    return _layoutWidth <= AppBreakpoints.mobileMax;
  }

  bool get isTabletLayout {
    if (_breakpoints == null) return false;
    final w = _layoutWidth;
    return w > AppBreakpoints.mobileMax && w <= AppBreakpoints.tabletMax;
  }

  bool get isDesktopLayout {
    if (_breakpoints == null) return false;
    return _layoutWidth > AppBreakpoints.tabletMax;
  }

  bool get isTablet => isTabletLayout;
  bool get isDesktop => isDesktopLayout;

  double get pageGutter {
    if (isMobileLayout) return AppLayout.gutterMobile;
    return AppLayout.gutterTablet;
  }

  EdgeInsetsDirectional get pagePadding => EdgeInsetsDirectional.fromSTEB(pageGutter, 0, pageGutter, 0);

  double get formMaxWidth => AppLayout.formMaxWidth;

  double get listMaxWidth => AppLayout.listMaxWidth;

  double get pageMaxWidth => AppLayout.pageMaxWidth;
}