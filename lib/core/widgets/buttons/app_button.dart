import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/extensions/text_style_extensions.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_size.dart';
import '../text_field/app_input_direction.dart';
import 'app_button_content.dart';
import 'app_button_frame.dart';
import 'app_button_style.dart';
import 'app_button_type.dart';
import 'pressable_scale.dart';

export 'app_button_style.dart';
export 'app_button_type.dart';

/// The app's action button. Press scales the surface; color does not change.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.iconWidget,
    this.trailingIcon,
    this.trailingIconWidget,
    this.badge,
    this.size = AppButtonSize.medium,
    this.style = AppButtonStyle.primary,
    this.width,
    this.height,
    this.iconSize,
    this.isExpanded = false,
    this.contentAlign = AppButtonContentAlign.spaceBetween,
    this.minWidth = 0,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.focusRingColor,
    this.padding,
    this.textStyle,
    this.boxShadow,
    this.child,
    this.enableHaptics = false,
    this.isIconButton = false,
    this.followDirectionality = false,
    this.semanticLabel,
    this.autofocus = false,
  }) : assert(text != '' || (semanticLabel != null && semanticLabel != ''), 'Icon-only buttons need a semanticLabel');

  factory AppButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    Widget? iconWidget,
    IconData? trailingIcon,
    Widget? trailingIconWidget,
    Widget? badge,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
    bool isExpanded = true,
    AppButtonContentAlign contentAlign = AppButtonContentAlign.spaceBetween,
    double minWidth = 0,
    bool isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    BoxShadow? boxShadow,
    Widget? child,
    bool enableHaptics = false,
    bool isIconButton = false,
    bool followDirectionality = false,
    String? semanticLabel,
    bool autofocus = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      iconWidget: iconWidget,
      trailingIcon: trailingIcon,
      trailingIconWidget: trailingIconWidget,
      badge: badge,
      size: size,
      style: AppButtonStyle.primary,
      width: width,
      isExpanded: isExpanded,
      contentAlign: contentAlign,
      minWidth: minWidth,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      textStyle: textStyle,
      boxShadow: boxShadow,
      enableHaptics: enableHaptics,
      isIconButton: isIconButton,
      followDirectionality: followDirectionality,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      child: child,
    );
  }

  factory AppButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    Widget? iconWidget,
    IconData? trailingIcon,
    Widget? badge,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
    bool isExpanded = false,
    AppButtonContentAlign contentAlign = AppButtonContentAlign.spaceBetween,
    double minWidth = 0,
    bool isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    BoxShadow? boxShadow,
    Widget? child,
    bool enableHaptics = false,
    bool isIconButton = false,
    bool followDirectionality = false,
    String? semanticLabel,
    bool autofocus = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      iconWidget: iconWidget,
      trailingIcon: trailingIcon,
      badge: badge,
      size: size,
      style: AppButtonStyle.secondary,
      width: width,
      isExpanded: isExpanded,
      contentAlign: contentAlign,
      minWidth: minWidth,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      textStyle: textStyle,
      boxShadow: boxShadow,
      enableHaptics: enableHaptics,
      isIconButton: isIconButton,
      followDirectionality: followDirectionality,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      child: child,
    );
  }

  factory AppButton.destructive({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    Widget? iconWidget,
    IconData? trailingIcon,
    Widget? badge,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
    bool isExpanded = false,
    AppButtonContentAlign contentAlign = AppButtonContentAlign.spaceBetween,
    double minWidth = 0,
    bool isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    BoxShadow? boxShadow,
    Widget? child,
    bool enableHaptics = false,
    bool isIconButton = false,
    bool followDirectionality = false,
    String? semanticLabel,
    bool autofocus = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      iconWidget: iconWidget,
      trailingIcon: trailingIcon,
      badge: badge,
      size: size,
      style: AppButtonStyle.destructive,
      width: width,
      isExpanded: isExpanded,
      contentAlign: contentAlign,
      minWidth: minWidth,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      textStyle: textStyle,
      boxShadow: boxShadow,
      enableHaptics: enableHaptics,
      isIconButton: isIconButton,
      followDirectionality: followDirectionality,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      child: child,
    );
  }

  factory AppButton.outlined({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    Widget? iconWidget,
    IconData? trailingIcon,
    Widget? badge,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
    bool isExpanded = false,
    AppButtonContentAlign contentAlign = AppButtonContentAlign.spaceBetween,
    double minWidth = 0,
    bool isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    double? borderWidth,
    Color? focusRingColor,
    EdgeInsets? padding,
    TextStyle? textStyle,
    BoxShadow? boxShadow,
    Widget? child,
    bool enableHaptics = false,
    bool isIconButton = false,
    bool followDirectionality = false,
    String? semanticLabel,
    bool autofocus = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      iconWidget: iconWidget,
      trailingIcon: trailingIcon,
      badge: badge,
      size: size,
      style: AppButtonStyle.outlined,
      width: width,
      isExpanded: isExpanded,
      contentAlign: contentAlign,
      minWidth: minWidth,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      focusRingColor: focusRingColor,
      padding: padding,
      textStyle: textStyle,
      boxShadow: boxShadow,
      enableHaptics: enableHaptics,
      isIconButton: isIconButton,
      followDirectionality: followDirectionality,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      child: child,
    );
  }

  factory AppButton.text({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    Widget? iconWidget,
    IconData? trailingIcon,
    Widget? badge,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
    bool isExpanded = false,
    AppButtonContentAlign contentAlign = AppButtonContentAlign.spaceBetween,
    double minWidth = 0,
    bool isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    BoxShadow? boxShadow,
    Widget? child,
    bool enableHaptics = false,
    bool isIconButton = false,
    bool followDirectionality = false,
    String? semanticLabel,
    bool autofocus = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      iconWidget: iconWidget,
      trailingIcon: trailingIcon,
      badge: badge,
      size: size,
      style: AppButtonStyle.text,
      width: width,
      isExpanded: isExpanded,
      contentAlign: contentAlign,
      minWidth: minWidth,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      textStyle: textStyle,
      boxShadow: boxShadow,
      enableHaptics: enableHaptics,
      isIconButton: isIconButton,
      followDirectionality: followDirectionality,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      child: child,
    );
  }

  factory AppButton.success({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    Widget? iconWidget,
    IconData? trailingIcon,
    Widget? badge,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
    bool isExpanded = false,
    AppButtonContentAlign contentAlign = AppButtonContentAlign.spaceBetween,
    double minWidth = 0,
    bool isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    BoxShadow? boxShadow,
    Widget? child,
    bool enableHaptics = false,
    bool isIconButton = false,
    bool followDirectionality = false,
    String? semanticLabel,
    bool autofocus = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      iconWidget: iconWidget,
      trailingIcon: trailingIcon,
      badge: badge,
      size: size,
      style: AppButtonStyle.success,
      width: width,
      isExpanded: isExpanded,
      contentAlign: contentAlign,
      minWidth: minWidth,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      textStyle: textStyle,
      boxShadow: boxShadow,
      enableHaptics: enableHaptics,
      isIconButton: isIconButton,
      followDirectionality: followDirectionality,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      child: child,
    );
  }

  factory AppButton.warning({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    Widget? iconWidget,
    IconData? trailingIcon,
    Widget? badge,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
    bool isExpanded = false,
    AppButtonContentAlign contentAlign = AppButtonContentAlign.spaceBetween,
    double minWidth = 0,
    bool isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    BoxShadow? boxShadow,
    Widget? child,
    bool enableHaptics = false,
    bool isIconButton = false,
    bool followDirectionality = false,
    String? semanticLabel,
    bool autofocus = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      iconWidget: iconWidget,
      trailingIcon: trailingIcon,
      badge: badge,
      size: size,
      style: AppButtonStyle.warning,
      width: width,
      isExpanded: isExpanded,
      contentAlign: contentAlign,
      minWidth: minWidth,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      textStyle: textStyle,
      boxShadow: boxShadow,
      enableHaptics: enableHaptics,
      isIconButton: isIconButton,
      followDirectionality: followDirectionality,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      child: child,
    );
  }

  factory AppButton.icon({
    Key? key,
    IconData? icon,
    Widget? iconWidget,
    String? text,
    VoidCallback? onPressed,
    IconData? trailingIcon,
    Widget? badge,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
    double? height,
    double? iconSize,
    bool isExpanded = false,
    AppButtonContentAlign? contentAlign,
    double minWidth = 0,
    bool isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    BoxShadow? boxShadow,
    Widget? child,
    bool enableHaptics = true,
    bool followDirectionality = false,
    String? semanticLabel,
    bool autofocus = false,
  }) {
    assert(icon != null || iconWidget != null, 'AppButton.icon needs icon or iconWidget');
    final label = text ?? '';
    final iconOnly = label.isEmpty;
    return AppButton(
      key: key,
      text: label,
      onPressed: onPressed,
      icon: icon,
      iconWidget: iconWidget,
      trailingIcon: trailingIcon,
      badge: badge,
      size: size,
      style: AppButtonStyle.icon,
      width: width,
      height: height,
      iconSize: iconSize,
      isExpanded: isExpanded,
      contentAlign: contentAlign ??
          (iconOnly ? AppButtonContentAlign.spaceBetween : AppButtonContentAlign.center),
      minWidth: minWidth,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      textStyle: textStyle,
      boxShadow: boxShadow,
      enableHaptics: enableHaptics,
      isIconButton: iconOnly,
      followDirectionality: followDirectionality,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      child: child,
    );
  }

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? iconWidget;
  final IconData? trailingIcon;
  final Widget? trailingIconWidget;
  final Widget? badge;
  final AppButtonSize size;
  final AppButtonStyle style;
  final double? width;
  final double? height;
  final double? iconSize;
  final bool isExpanded;
  final AppButtonContentAlign contentAlign;
  final double minWidth;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final Color? focusRingColor;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final BoxShadow? boxShadow;
  final Widget? child;
  final bool enableHaptics;
  final bool isIconButton;
  final bool followDirectionality;
  final String? semanticLabel;
  final bool autofocus;

  bool get _enabled => onPressed != null;

  bool get _interactive => _enabled && !isLoading;

  bool get _haptic => enableHaptics || (style != AppButtonStyle.text && style != AppButtonStyle.icon);

  bool get _centering => contentAlign == AppButtonContentAlign.center;

  bool get _mixed =>
      child == null &&
      !isIconButton &&
      text.isNotEmpty &&
      (icon != null ||
          iconWidget != null ||
          trailingIcon != null ||
          trailingIconWidget != null ||
          badge != null);

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  final _focusNode = FocusNode();
  var _focused = false;
  var _pressed = false;

  @override
  void didUpdateWidget(AppButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget._interactive) {
      _pressed = false;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onHighlight(bool pressed) {
    if (!mounted || _pressed == pressed) {
      return;
    }
    setState(() => _pressed = pressed);
  }

  void _onFocus(bool focused) {
    if (!mounted || _focused == focused) {
      return;
    }
    setState(() => _focused = focused);
  }

  void _activate() {
    if (!widget._interactive) {
      return;
    }
    if (widget._haptic) {
      HapticFeedback.selectionClick();
    }
    widget.onPressed?.call();
  }

  AppButtonColors _resolved(AppColors colors) {
    var resolved = AppButtonColors.resolve(colors, widget.style, disabled: !widget._enabled);
    if (!widget._enabled) {
      return resolved;
    }
    resolved = resolved.overriding(
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      borderColor: widget.borderColor,
      boxShadow: widget.boxShadow,
      colors: colors,
    );
    if (_phase == AppButtonPhase.pressed) {
      resolved = _pressedColors(resolved, colors, widget.style);
    }
    return resolved;
  }

  static AppButtonColors _pressedColors(AppButtonColors base, AppColors colors, AppButtonStyle style) {
    return switch (style) {
      AppButtonStyle.primary => base.copyWith(surface: colors.primaryPressed),
      AppButtonStyle.destructive => base.copyWith(surface: colors.errorPressed),
      AppButtonStyle.secondary || AppButtonStyle.outlined => base.copyWith(surface: colors.primaryTint),
      AppButtonStyle.text || AppButtonStyle.icon => base.copyWith(surface: colors.surfaceSunken),
      _ => base,
    };
  }

  Color _ink(AppColors colors, AppButtonColors resolved) {
    final caller = widget.textStyle?.color;
    if (!widget._enabled || caller == null) {
      return resolved.foreground;
    }
    final backdrop = AppButtonColors.composite(resolved.surface, colors.canvas);
    if (AppButtonColors.contrast(caller, backdrop) >= AppButtonColors.minContrast) {
      return caller;
    }
    return resolved.foreground;
  }

  EdgeInsets _padding(TextDirection direction) {
    if (widget._enabled && widget.padding != null) {
      return widget.padding!;
    }
    final row = widget.child == null && !widget.isIconButton;
    return opticalButtonPadding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: widget.size.horizontalPadding, vertical: AppSize.spaceXS),
      hasLabel: widget.child == null && widget.text.isNotEmpty,
      hasLeading:
          row &&
          (widget.icon != null ||
              widget.iconWidget != null ||
              widget._centering && (widget.trailingIcon != null || widget.badge != null)),
      hasTrailing:
          row &&
          (widget.trailingIcon != null ||
              widget.badge != null ||
              widget._centering && (widget.icon != null || widget.iconWidget != null)),
      direction: direction,
    );
  }

  AppButtonPhase get _phase => buttonPhase(enabled: widget._enabled, loading: widget.isLoading, pressed: _pressed);

  @override
  Widget build(BuildContext context) {
    assert(() {
      final label = widget.text.isEmpty ? widget.semanticLabel : widget.text;
      if (label == null || label.isEmpty) {
        return true;
      }
      return isActionLabel(label);
    }(), 'Button labels name the action');
    final colors = context.colors;
    final resolved = _resolved(colors);
    final ink = _ink(colors, resolved);
    final TextStyle style;
    if (widget._enabled && widget.textStyle != null) {
      style = widget.textStyle!.copyWith(color: ink);
    } else {
      style = widget.size.textStyle(context.text).setColor(ink).copyWith(height: 1.24);
    }
    final radius = widget._enabled && widget.borderRadius != null
        ? widget.borderRadius!
        : BorderRadius.circular(AppSize.radius);

    final label = widget.text.isEmpty
        ? null
        : Text(
            widget.text,
            textDirection: rtlParagraphIfArabic(widget.text, Directionality.of(context)),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: style,
            strutStyle: StrutStyle.fromTextStyle(style, forceStrutHeight: true),
          );
    final metrics = widget.size.iconSize;
    final glyphSize = widget.iconSize ?? metrics;
    Widget? leading = widget.iconWidget ?? (widget.icon == null ? null : Icon(widget.icon, size: glyphSize));
    if (leading != null && (widget.iconWidget != null || widget.isIconButton)) {
      leading = SizedBox(
        width: glyphSize,
        height: glyphSize,
        child: Center(child: leading),
      );
    }
    Widget? trailing = widget.trailingIconWidget ??
        (widget.trailingIcon == null ? null : Icon(widget.trailingIcon, size: glyphSize));
    if (trailing != null && widget.trailingIconWidget != null) {
      trailing = SizedBox(
        width: glyphSize,
        height: glyphSize,
        child: Center(child: trailing),
      );
    }
    final padding = _padding(TextDirection.ltr);
    final frameMinHeight = widget.height ?? widget.size.minHeight;
    final barHeight = math.max(glyphSize, frameMinHeight - padding.vertical);
    final body = DefaultTextStyle(
      style: style,
      child: IconTheme(
        data: IconThemeData(color: ink, size: glyphSize),
        child:
            widget.child ??
            AppButtonContent(
              label: label,
              leading: leading,
              trailing: trailing,
              badge: widget.badge,
              gap: widget.size.gap,
              iconSize: glyphSize,
              barHeight: barHeight,
              stacked: widget.isIconButton,
              align: widget.contentAlign,
            ),
      ),
    );

    Widget frame = Builder(
      builder: (context) {
        final platformHit = buttonHitTarget(Theme.of(context).platform);
        final hitTarget = switch ((widget.width, widget.height)) {
          (final w?, final h?) => math.max(w, h),
          (final w?, null) => math.max(w, platformHit),
          (null, final h?) => math.max(h, platformHit),
          _ => platformHit,
        };
        return AppButtonFrame(
          colors: resolved,
          radius: radius,
          borderWidth: widget.borderWidth ?? AppSize.borderWidth,
          minHeight: frameMinHeight,
          iconSize: glyphSize,
          padding: _padding(Directionality.of(context)),
          focused: _focused,
          focusColor: widget.focusRingColor ?? colors.primary,
          isLoading: widget.isLoading,
          iconOnly: widget.text.isEmpty,
          minWidth: widget.minWidth,
          hitTarget: hitTarget,
          mixed: widget._mixed,
          centerContent: widget._centering,
          hugWidth:
              widget.style == AppButtonStyle.text ||
              (widget.style == AppButtonStyle.icon && widget.isIconButton),
          child: body,
        );
      },
    );
    if (!widget.followDirectionality) {
      frame = Directionality(textDirection: TextDirection.ltr, child: frame);
    }

    final phase = _phase;
    final loading = phase == AppButtonPhase.loading;
    final semanticsLabel = widget.text.isEmpty
        ? widget.semanticLabel
        : loading
        ? widget.text
        : null;
    final hint = loading ? 'Loading…' : null;

    Widget button = Semantics(
      button: true,
      enabled: phase == AppButtonPhase.idle || phase == AppButtonPhase.pressed,
      label: semanticsLabel,
      hint: hint,
      liveRegion: loading,
      child: PressableScale(
        enabled: widget._interactive,
        onPressed: _activate,
        autofocus: widget.autofocus,
        focusNode: _focusNode,
        onFocusChange: _onFocus,
        onHighlight: _onHighlight,
        child: frame,
      ),
    );
    if (widget.style == AppButtonStyle.text) {
      return Align(alignment: AlignmentDirectional.centerStart, widthFactor: 1, heightFactor: 1, child: button);
    }
    if (widget.width != null) {
      button = SizedBox(width: widget.width, child: button);
    } else if (widget.isExpanded) {
      button = SizedBox(width: double.infinity, child: button);
    }
    if (widget.height != null) {
      button = SizedBox(height: widget.height, child: button);
    }
    return button;
  }
}
