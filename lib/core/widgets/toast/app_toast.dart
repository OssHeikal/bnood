import 'package:flutter/material.dart';

import '../../config/extensions/text_style_extensions.dart';
import '../../config/theme/app_size.dart';
import '../../config/theme/app_colors.dart';
import '../foundation_icon.dart';
import '../buttons/app_button.dart';
import 'app_tone.dart';

class ToastAction {
  const ToastAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

class AppToast extends StatelessWidget {
  const AppToast({
    super.key,
    required this.tone,
    required this.message,
    this.title,
    this.action,
    this.isLoading = false,
    this.onDismiss,
  });

  final AppTone tone;
  final String message;
  final String? title;
  final ToastAction? action;
  final bool isLoading;
  final VoidCallback? onDismiss;

  static const int _messageMaxLines = 4;
  static const int _compactLineThreshold = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final semanticsLabel = _semanticsLabel(context);

    final backgroundColor = isLoading ? colors.surface : tone.tint(colors);
    final borderColor = isLoading ? colors.outline : tone.solid(colors);

    return Semantics(
      liveRegion: true,
      container: true,
      label: semanticsLabel,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSize.spaceMD, vertical: AppSize.gap),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.cardRadius),
            side: BorderSide(color: borderColor, width: AppSize.borderWidth),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textMaxWidth = _textMaxWidth(constraints.maxWidth);
            final titleStyle = text.title.setColor(colors.onSurface);
            final hasTitle = title != null && title!.isNotEmpty;
            final bodyStyle = text.body.setColor(hasTitle ? colors.muted : colors.onSurface);

            final titleLines = hasTitle ? _lineCount(context, title!, titleStyle, textMaxWidth, maxLines: 1) : 0;
            final messageLines = _lineCount(context, message, bodyStyle, textMaxWidth, maxLines: _messageMaxLines);
            final totalLines = titleLines + messageLines;
            final rowAlign = totalLines > _compactLineThreshold ? CrossAxisAlignment.start : CrossAxisAlignment.center;
            final anchorStyle = hasTitle ? titleStyle : bodyStyle;

            return Row(
              crossAxisAlignment: rowAlign,
              children: [
                ExcludeSemantics(
                  child: _ToastLeadingIcon(
                    tone: tone,
                    isLoading: isLoading,
                    rowAlign: rowAlign,
                    anchorStyle: anchorStyle,
                  ),
                ),
                const SizedBox(width: AppSize.spaceMD),
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      spacing: AppSize.spaceXS,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasTitle)
                          Text(
                            title!,
                            style: titleStyle,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                        Text(
                          message,
                          style: bodyStyle,
                          textAlign: TextAlign.start,
                          maxLines: _messageMaxLines,
                          overflow: TextOverflow.ellipsis,
                          strutStyle: StrutStyle.fromTextStyle(bodyStyle, forceStrutHeight: true),
                        ),
                      ],
                    ),
                  ),
                ),
                if (action case final action?) ...[
                  const SizedBox(width: AppSize.spaceSM),
                  _ToastActionButton(action: action, tone: tone),
                ],
                if (onDismiss case final onDismiss?) ...[
                  const SizedBox(width: AppSize.spaceSM),
                  _ToastDismissButton(onPressed: onDismiss, rowAlign: rowAlign, anchorStyle: anchorStyle),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  double _textMaxWidth(double totalWidth) {
    var reserved = AppSize.logoMark + AppSize.spaceMD;
    if (action != null) {
      reserved += AppSize.hitMin + AppSize.spaceSM;
    }
    if (onDismiss != null) {
      reserved += AppSize.hitMin + AppSize.spaceSM;
    }
    return (totalWidth - reserved).clamp(0, double.infinity);
  }

  int _lineCount(BuildContext context, String value, TextStyle style, double maxWidth, {required int maxLines}) {
    if (value.isEmpty || maxWidth <= 0) {
      return 0;
    }
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: Directionality.of(context),
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    return painter.computeLineMetrics().length.clamp(0, maxLines);
  }

  String _semanticsLabel(BuildContext context) {
    final toneWord = _toneWord(context);
    if (title case final title?) {
      return '$toneWord: $title — $message';
    }
    return '$toneWord: $message';
  }

  String _toneWord(BuildContext context) {
    if (isLoading) {
      return 'Loading';
    }
    return switch (tone) {
      AppTone.danger => '',
      AppTone.warning => '',
      AppTone.success => '',
      AppTone.info => '',
      AppTone.neutral || AppTone.brand => '',
    };
  }
}

class _ToastLeadingIcon extends StatelessWidget {
  const _ToastLeadingIcon({
    required this.tone,
    required this.isLoading,
    required this.rowAlign,
    required this.anchorStyle,
  });

  final AppTone tone;
  final bool isLoading;
  final CrossAxisAlignment rowAlign;
  final TextStyle anchorStyle;

  @override
  Widget build(BuildContext context) {
    final chip = _ToastIconChip(tone: tone, isLoading: isLoading);
    if (rowAlign == CrossAxisAlignment.center) {
      return chip;
    }
    final inset = _opticalTopInset(anchorStyle, AppSize.logoMark);
    if (inset <= 0) {
      return chip;
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(top: inset),
      child: chip,
    );
  }
}

double _opticalTopInset(TextStyle style, double markerSize) {
  final fontSize = style.fontSize ?? 14;
  final heightFactor = style.height;
  final lineHeight = heightFactor != null && heightFactor > 0 ? fontSize * heightFactor : fontSize * 1.2;
  return ((lineHeight - markerSize) / 2).clamp(0, double.infinity);
}

class _ToastIconChip extends StatelessWidget {
  const _ToastIconChip({required this.tone, required this.isLoading});

  final AppTone tone;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chipColor = isLoading ? colors.surfaceSunken : tone.solid(colors);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Container(
      width: AppSize.logoMark,
      height: AppSize.logoMark,
      decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(AppSize.radius)),
      alignment: Alignment.center,
      child: isLoading
          ? SizedBox(
              width: AppSize.iconSmall,
              height: AppSize.iconSmall,
              child: CircularProgressIndicator(
                strokeWidth: AppSize.borderWidth * 2,
                color: colors.muted,
                value: disableAnimations ? 0.25 : null,
              ),
            )
          : tone.glyphWidget(size: AppSize.iconSmall, color: colors.onSolid),
    );
  }
}

class _ToastActionButton extends StatelessWidget {
  const _ToastActionButton({required this.action, required this.tone});

  final ToastAction action;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: AppSize.hitMin, minHeight: AppSize.hitMin),
      child: TextButton(
        onPressed: action.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: tone.glyph(colors),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: text.label.setColor(tone.glyph(colors)),
        ),
        child: Text(action.label),
      ),
    );
  }
}

class _ToastDismissButton extends StatelessWidget {
  const _ToastDismissButton({required this.onPressed, required this.rowAlign, required this.anchorStyle});

  final VoidCallback onPressed;
  final CrossAxisAlignment rowAlign;
  final TextStyle anchorStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final button = AppButton.icon(
      iconWidget: FoundationIcon(Icons.close, size: AppSize.icon, color: colors.onSurface),
      iconSize: AppSize.icon,
      height: 32,
      width: 32,
      semanticLabel: '',
      onPressed: onPressed,
      size: AppButtonSize.small,
      foregroundColor: colors.onSurface,
      padding: EdgeInsets.zero,
    );

    if (rowAlign == CrossAxisAlignment.center) {
      return button;
    }
    final inset = _opticalTopInset(anchorStyle, AppSize.icon);
    if (inset <= 0) {
      return button;
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(top: inset),
      child: button,
    );
  }
}
