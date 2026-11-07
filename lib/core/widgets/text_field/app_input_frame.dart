import 'package:flutter/material.dart';

import '../../config/extensions/text_style_extensions.dart';
import '../../config/theme/app_motion.dart';
import '../../config/theme/app_size.dart';
import '../../config/theme/app_colors.dart';
import 'app_input_style.dart';
import 'app_input_type.dart';

class AppInputFrame extends StatelessWidget {
  const AppInputFrame({
    super.key,
    required this.style,
    required this.variant,
    required this.multiline,
    required this.height,
    required this.floated,
    required this.label,
    required this.field,
    required this.onSurfaceTap,
    required this.suffixAtStart,
    this.leading,
    this.trailing,
    this.prefix,
    this.suffix,
    this.clear,
    this.passwordToggle,
    this.paste,
  });

  final AppInputStyle style;
  final AppInputVariant variant;
  final bool multiline;
  final double height;
  final bool floated;
  final String? label;
  final Widget field;
  final VoidCallback onSurfaceTap;
  final bool suffixAtStart;
  final Widget? leading;
  final Widget? trailing;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? clear;
  final Widget? passwordToggle;
  final Widget? paste;

  static const _insetDefault = AppSize.spaceLG;
  static const _insetWithIcon = AppSize.spaceXS;

  bool get _compactStartInset => leading != null || (suffixAtStart && suffix != null);

  bool get _compactEndInset =>
      trailing != null ||
      passwordToggle != null ||
      paste != null ||
      clear != null ||
      (!suffixAtStart && suffix != null);

  EdgeInsetsDirectional _contentPadding() {
    return EdgeInsetsDirectional.only(
      start: _compactStartInset ? _insetWithIcon : _insetDefault,
      end: _compactEndInset ? _insetWithIcon : _insetDefault,
      top: multiline ? AppSize.spaceSM : 0,
      bottom: multiline ? AppSize.spaceSM : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final row = _row(context);
    if (variant == AppInputVariant.bare) {
      return row;
    }
    return AnimatedContainer(
      duration: AppMotion.durationOf(context, AppMotion.fast),
      curve: AppMotion.easeOut,
      height: height,
      padding: _contentPadding(),
      decoration: BoxDecoration(color: style.surface, borderRadius: BorderRadius.circular(AppSize.cardRadius)),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.cardRadius),
        border: Border.all(color: style.border, width: style.borderWidth),
      ),
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onSurfaceTap, child: row),
    );
  }

  Widget _row(BuildContext context) {
    final slots = <Widget>[];
    void add(Widget? slot) {
      if (slot == null) {
        return;
      }
      if (slots.isNotEmpty) {
        slots.add(const SizedBox(width: AppSize.spaceXS));
      }
      slots.add(slot);
    }

    if (suffixAtStart) {
      add(_suffix(context));
    }
    add(_icon(leading, style.label, AppSize.iconCompact));
    add(Expanded(child: _editor(context)));
    add(_action(clear));
    if (!suffixAtStart) {
      add(_suffix(context));
    }
    add(_action(paste));
    add(_action(passwordToggle));
    add(_icon(trailing, style.trailing, AppSize.iconSmall));

    return Row(crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: slots);
  }

  Widget _editor(BuildContext context) {
    final showPrefix = floated && prefix != null;
    final editor = Row(
      children: [
        if (showPrefix) ...[
          _colored(context, prefix!, style.prefix, AppSize.iconSmall),
          const SizedBox(width: AppSize.spaceXS),
        ],
        Expanded(child: field),
      ],
    );
    if (variant == AppInputVariant.bare || label == null) {
      return editor;
    }
    final stack = Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: floated ? AppSize.floatedLabelHeight : 0),
            child: editor,
          ),
        ),
        _label(context),
      ],
    );
    if (multiline) {
      return stack;
    }
    return SizedBox(height: AppSize.labelStackHeight, child: stack);
  }

  Widget _label(BuildContext context) {
    final floatedStyle = context.text.supporting;
    final restingStyle = context.text.groupTitle;
    return AnimatedPositionedDirectional(
      duration: AppMotion.durationOf(context, AppMotion.fast),
      curve: AppMotion.easeOut,
      start: 0,
      end: 0,
      top: floated ? 0 : AppSize.spaceSM,
      height: floated ? AppSize.floatedLabelHeight : AppSize.valueRowHeight,
      child: IgnorePointer(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.durationOf(context, AppMotion.fast),
            curve: AppMotion.easeOut,
            style: (floated ? floatedStyle : restingStyle).setColor(style.label).ellipsis,
            child: Text(label!, maxLines: 1),
          ),
        ),
      ),
    );
  }

  Widget? _action(Widget? child) {
    if (child == null) {
      return null;
    }
    return IconTheme(
      data: IconThemeData(color: style.trailing, size: AppSize.iconSmall),
      child: child,
    );
  }

  Widget? _suffix(BuildContext context) {
    final child = suffix;
    if (child == null) {
      return null;
    }
    return _colored(context, child, style.suffix, AppSize.iconSmall);
  }

  Widget? _icon(Widget? child, Color color, double size) {
    if (child == null) {
      return null;
    }
    return ExcludeSemantics(
      child: IconTheme(
        data: IconThemeData(color: color, size: size),
        child: child,
      ),
    );
  }

  Widget _colored(BuildContext context, Widget child, Color color, double size) {
    return DefaultTextStyle(
      style: context.text.body.setColor(color),
      child: IconTheme(
        data: IconThemeData(color: color, size: size),
        child: child,
      ),
    );
  }
}

class AppInputIconAction extends StatelessWidget {
  const AppInputIconAction({super.key, required this.icon, required this.semanticLabel, required this.onPressed});

  final Widget icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: AppSize.hitMin,
        height: AppSize.hitMin,
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          icon: IconTheme.merge(
            data: IconThemeData(size: theme.size ?? AppSize.iconSmall, color: theme.color),
            child: icon,
          ),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(AppSize.hitMin, AppSize.hitMin),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: theme.color,
          ),
        ),
      ),
    );
  }
}
