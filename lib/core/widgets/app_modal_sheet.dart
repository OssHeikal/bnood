import 'package:flutter/material.dart';

import '../layout/app_layout.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_overlay.dart';
import '../config/theme/app_shape.dart';
import '../config/theme/app_size.dart';
import 'bounded_sheet_navigator.dart';

/// Max scroll padding above a pinned footer for focused fields in the sheet body.
class AppModalSheetScope extends InheritedWidget {
  const AppModalSheetScope({
    super.key,
    required this.footerScrollPadding,
    required this.homeIndicatorBottom,
    required super.child,
  });

  final double footerScrollPadding;
  final double homeIndicatorBottom;

  static AppModalSheetScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppModalSheetScope>();
  }

  static double footerPaddingOf(BuildContext context) => maybeOf(context)?.footerScrollPadding ?? 0;

  static double homeIndicatorOf(BuildContext context) => maybeOf(context)?.homeIndicatorBottom ?? 0;

  @override
  bool updateShouldNotify(AppModalSheetScope oldWidget) =>
      oldWidget.footerScrollPadding != footerScrollPadding || oldWidget.homeIndicatorBottom != homeIndicatorBottom;
}

/// Shared modal bottom sheet with header / scrollable body / pinned footer slots.
abstract final class AppModalSheet {
  static const sheetBoundsKey = Key('app_modal_sheet_bounds');
  static const footerChromeKey = Key('app_modal_sheet_footer_chrome');

  static Future<T?> show<T>({
    required BuildContext context,
    Widget? header,
    required Widget body,
    Widget? footer,
    bool scrollable = true,
    bool useRootNavigator = true,
    Color? backgroundColor,
    ShapeBorder? shape,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    final openerViewPadding = MediaQuery.viewPaddingOf(context);
    final openerPaddingInsets = MediaQuery.paddingOf(context);
    final homeIndicatorBottom = openerViewPadding.bottom > 0 ? openerViewPadding.bottom : openerPaddingInsets.bottom;
    final openerKeyboard = MediaQuery.viewInsetsOf(context).bottom;
    return showModalBottomSheet<T>(
      context: context,
      barrierColor: AppOverlay.barrierColor(context),
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: false,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        final viewPad = media.viewPadding.copyWith(
          top: openerViewPadding.top > 0 ? openerViewPadding.top : media.viewPadding.top,
          bottom: homeIndicatorBottom > 0 ? homeIndicatorBottom : media.viewPadding.bottom,
          left: openerViewPadding.left > 0 ? openerViewPadding.left : media.viewPadding.left,
          right: openerViewPadding.right > 0 ? openerViewPadding.right : media.viewPadding.right,
        );
        final keyboard = media.viewInsets.bottom > 0 ? media.viewInsets.bottom : openerKeyboard;
        final maxHeight = SheetContentBounds.viewportCap(media);
        final isMobile = ctx.isMobileLayout;
        final maxWidth = isMobile ? media.size.width : ctx.formMaxWidth;

        final defaultShape = isMobile
            ? AppShape.sheetMobileTop(radius: AppSize.radiusLG)
            : AppShape.superellipse(radius: AppSize.radiusLG);

        Widget sheet = _ModalSheetSlots(
          header: header,
          body: body,
          footer: footer,
          scrollable: scrollable,
          maxHeight: maxHeight,
          keyboardBottom: keyboard,
          homeIndicatorBottom: homeIndicatorBottom,
        );

        sheet = Material(
          color: backgroundColor ?? colors.surface,
          shape: shape ?? defaultShape,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            key: sheetBoundsKey,
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
            child: sheet,
          ),
        );

        sheet = Padding(
          padding: EdgeInsets.only(bottom: keyboard),
          child: MediaQuery.removeViewInsets(context: ctx, removeBottom: true, child: sheet),
        );

        if (isMobile) {
          sheet = Padding(
            padding: EdgeInsets.only(top: viewPad.top, left: viewPad.left, right: viewPad.right),
            child: Align(alignment: Alignment.bottomCenter, widthFactor: 1, child: sheet),
          );
        } else {
          final closedBottom = AppSize.spaceMD + viewPad.bottom;
          sheet = Padding(
            padding: EdgeInsets.fromLTRB(
              viewPad.left,
              viewPad.top,
              viewPad.right,
              keyboard > 0 ? AppSize.spaceMD : closedBottom,
            ),
            child: Align(alignment: Alignment.bottomCenter, child: sheet),
          );
        }
        return sheet;
      },
    );
  }
}

class _ModalSheetSlots extends StatefulWidget {
  const _ModalSheetSlots({
    required this.header,
    required this.body,
    required this.footer,
    required this.scrollable,
    required this.maxHeight,
    required this.keyboardBottom,
    required this.homeIndicatorBottom,
  });

  final Widget? header;
  final Widget body;
  final Widget? footer;
  final bool scrollable;
  final double maxHeight;
  final double keyboardBottom;
  final double homeIndicatorBottom;

  @override
  State<_ModalSheetSlots> createState() => _ModalSheetSlotsState();
}

class _ModalSheetSlotsState extends State<_ModalSheetSlots> {
  final _footerKey = GlobalKey();
  double _footerHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureFooter());
  }

  @override
  void didUpdateWidget(covariant _ModalSheetSlots oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureFooter());
  }

  void _measureFooter() {
    final box = _footerKey.currentContext?.findRenderObject() as RenderBox?;
    final h = box?.hasSize == true ? box!.size.height : 0;
    if ((h - _footerHeight).abs() > 0.5 && mounted) {
      setState(() => _footerHeight = h.toDouble());
    }
  }

  double get _footerChromeBottom {
    final homeIndicator = widget.keyboardBottom > 0 ? 0.0 : widget.homeIndicatorBottom;
    return AppSize.spaceMD + homeIndicator;
  }

  Widget _padFooter(Widget? footer) {
    if (footer == null) return const SizedBox.shrink();
    return KeyedSubtree(
      key: AppModalSheet.footerChromeKey,
      child: Padding(
        key: _footerKey,
        padding: EdgeInsets.fromLTRB(
          AppSize.screenPadding,
          AppSize.spaceMD,
          AppSize.screenPadding,
          _footerChromeBottom,
        ),
        child: footer,
      ),
    );
  }

  Widget _wrapBody(Widget body) {
    final scrollPad = _footerHeight + AppSize.spaceMD;
    body = AppModalSheetScope(
      footerScrollPadding: scrollPad,
      homeIndicatorBottom: widget.homeIndicatorBottom,
      child: body,
    );
    if (!widget.scrollable) return body;
    return SingleChildScrollView(
      primary: false,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: scrollPad),
      child: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null) widget.header!,
          if (widget.scrollable)
            Flexible(fit: FlexFit.loose, child: _wrapBody(widget.body))
          else
            _wrapBody(widget.body),
          _padFooter(widget.footer),
        ],
      ),
    );
  }
}

/// Requests focus after the hosting [ModalRoute] open animation completes.
class AppModalSheetAutofocus extends StatefulWidget {
  const AppModalSheetAutofocus({super.key, required this.focusNode, required this.child});

  final FocusNode focusNode;
  final Widget child;

  @override
  State<AppModalSheetAutofocus> createState() => _AppModalSheetAutofocusState();
}

class _AppModalSheetAutofocusState extends State<AppModalSheetAutofocus> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestWhenReady());
  }

  void _requestWhenReady() {
    if (!mounted) return;
    final route = ModalRoute.of(context);
    final animation = route?.animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      widget.focusNode.requestFocus();
      return;
    }
    void listener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        animation.removeStatusListener(listener);
        if (mounted) widget.focusNode.requestFocus();
      }
    }

    animation.addStatusListener(listener);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
