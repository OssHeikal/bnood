import 'package:flutter/material.dart';
import '../config/extensions/num_extensions.dart';
import '../config/extensions/text_style_extensions.dart';
import '../config/theme/app_size.dart';
import '../config/theme/app_colors.dart';
import '../resources/gen/assets.gen.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../../features/home/home_foundation_scope.dart';
import 'bnood_failure.dart';
import 'foundation_icon.dart';
import 'sheet_drag_handle.dart';
import 'buttons/app_button.dart';
import 'custom_text_field.dart';
import 'bnood_modal_sheet.dart';
import 'toast/app_tone.dart';

/// Safe (cancel) action on decision surfaces: neutral outline, not brand secondary.
AppButton _neutralCancelButton({
  required BuildContext context,
  required String text,
  required VoidCallback? onPressed,
  bool autofocus = false,
  bool isExpanded = true,
}) {
  final colors = context.colors;
  return AppButton.outlined(
    text: text,
    foregroundColor: colors.onSurface,
    borderColor: colors.outline,
    borderWidth: AppSize.borderWidthHairline,
    focusRingColor: colors.outline,
    isExpanded: isExpanded,
    autofocus: autofocus,
    onPressed: onPressed,
  );
}

enum OverlayAnswer { confirmed, declined, dismissed }

String _closeSemanticLabel(BuildContext context) {
  return MaterialLocalizations.of(context).closeButtonLabel;
}

String _retryLabel(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return code == 'ar' ? 'إعادة المحاولة' : 'Try again';
}

abstract final class AppDecision {
  /// Archive confirmations: owner SVG tinted for [AppTone.danger] dialogs.
  static Widget archiveDangerIcon(BuildContext context) {
    final colors = context.colors;
    return ShellNavIcon(
      asset: Assets.icons.archiveRestoreOutline,
      color: AppTone.danger.glyph(colors),
      size: AppSize.icon,
      semanticsLabel: 'Archive',
    );
  }

  static Future<OverlayAnswer> show(
    BuildContext context, {
    required String title,
    String? description,
    required String confirmLabel,
    String? cancelLabel,
    String? confirmProgressLabel,
    AppTone tone = AppTone.brand,
    IconData? icon,
    Widget? iconWidget,
    bool? dismissible,
    Future<void> Function()? onConfirm,
    String? typedConfirmation,
  }) {
    final useSheet = typedConfirmation != null && typedConfirmation.isNotEmpty;
    if (useSheet) {
      return BnoodModalSheet.show<OverlayAnswer>(
        context: context,
        backgroundColor: context.colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.cardRadius)),
        ),
        builder: (sheetContext) => _AppDecisionSheet(
          title: title,
          description: description,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          confirmProgressLabel: confirmProgressLabel,
          tone: tone,
          icon: icon,
          iconWidget: iconWidget,
          dismissible: dismissible,
          onConfirm: onConfirm,
          typedConfirmation: typedConfirmation,
        ),
      ).then((value) => value ?? OverlayAnswer.dismissed);
    }

    final barrierDismiss = dismissible ?? (tone != AppTone.danger && onConfirm == null);

    return showDialog<OverlayAnswer>(
      context: context,
      barrierDismissible: barrierDismiss,
      builder: (dialogContext) => _AppDecisionDialog(
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmProgressLabel: confirmProgressLabel,
        tone: tone,
        icon: icon,
        iconWidget: iconWidget,
        dismissible: dismissible,
        onConfirm: onConfirm,
      ),
    ).then((value) => value ?? OverlayAnswer.dismissed);
  }
}

enum _DecisionPhase { idle, loading, failure }

class _AppDecisionDialog extends StatefulWidget {
  const _AppDecisionDialog({
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.confirmProgressLabel,
    required this.tone,
    required this.icon,
    required this.iconWidget,
    required this.dismissible,
    required this.onConfirm,
  });

  final String title;
  final String? description;
  final String confirmLabel;
  final String? cancelLabel;
  final String? confirmProgressLabel;
  final AppTone tone;
  final IconData? icon;
  final Widget? iconWidget;
  final bool? dismissible;
  final Future<void> Function()? onConfirm;

  @override
  State<_AppDecisionDialog> createState() => _AppDecisionDialogState();
}

class _AppDecisionDialogState extends State<_AppDecisionDialog> {
  _DecisionPhase _phase = _DecisionPhase.idle;
  String? _failureMessage;
  bool _retryMode = false;

  bool get _locked => _phase == _DecisionPhase.loading;

  bool get _forced => widget.dismissible == false;

  bool get _canPopRoute {
    if (_locked) {
      return false;
    }
    if (_forced) {
      return false;
    }
    return true;
  }

  bool get _showCloseControl {
    final barrierAllowed = widget.dismissible ?? (widget.tone != AppTone.danger && widget.onConfirm == null);
    return widget.cancelLabel == null && barrierAllowed && !_locked;
  }

  Future<void> _onConfirmPressed() async {
    if (_locked) {
      return;
    }
    final work = widget.onConfirm;
    if (work == null) {
      Navigator.of(context).pop(OverlayAnswer.confirmed);
      return;
    }
    setState(() {
      _phase = _DecisionPhase.loading;
      _failureMessage = null;
    });
    try {
      await work();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(OverlayAnswer.confirmed);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _phase = _DecisionPhase.failure;
        _retryMode = true;
        _failureMessage = _messageFromError(error);
      });
    }
  }

  void _onCancelPressed() {
    if (_locked) {
      return;
    }
    Navigator.of(context).pop(OverlayAnswer.declined);
  }

  void _onDismissed() {
    Navigator.of(context).pop(OverlayAnswer.dismissed);
  }

  String _confirmText() {
    if (_phase == _DecisionPhase.loading) {
      return widget.confirmProgressLabel ?? 'Loading…';
    }
    if (_retryMode) {
      return _retryLabel(context);
    }
    return widget.confirmLabel;
  }

  @override
  Widget build(BuildContext context) {
    final body = _DecisionBody(
      title: widget.title,
      description: widget.description,
      failureMessage: _failureMessage,
      showHandle: false,
      showCloseControl: _showCloseControl,
      onClose: _onDismissed,
      cancelLabel: widget.cancelLabel,
      confirmText: _confirmText(),
      tone: widget.tone,
      icon: widget.icon,
      iconWidget: widget.iconWidget,
      locked: _locked,
      autofocusCancel: widget.tone == AppTone.danger && !_locked,
      onCancel: widget.cancelLabel == null ? null : _onCancelPressed,
      onConfirm: _onConfirmPressed,
    );

    return HomeFoundationScope(
      child: PopScope(
        canPop: _canPopRoute,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          if (_canPopRoute) {
            _onDismissed();
          }
        },
        child: Builder(
          builder: (ctx) {
            final colors = ctx.colors;
            return Dialog(
              backgroundColor: colors.surface,
              insetPadding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG, vertical: AppSize.spaceXL),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.cardRadius)),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400, maxHeight: MediaQuery.sizeOf(context).height * 0.85),
                child: SingleChildScrollView(
                  child: Padding(padding: const EdgeInsets.all(AppSize.screenPadding), child: body),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppDecisionSheet extends StatefulWidget {
  const _AppDecisionSheet({
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.confirmProgressLabel,
    required this.tone,
    required this.icon,
    required this.iconWidget,
    required this.dismissible,
    required this.onConfirm,
    required this.typedConfirmation,
  });

  final String title;
  final String? description;
  final String confirmLabel;
  final String? cancelLabel;
  final String? confirmProgressLabel;
  final AppTone tone;
  final IconData? icon;
  final Widget? iconWidget;
  final bool? dismissible;
  final Future<void> Function()? onConfirm;
  final String typedConfirmation;

  @override
  State<_AppDecisionSheet> createState() => _AppDecisionSheetState();
}

class _AppDecisionSheetState extends State<_AppDecisionSheet> {
  _DecisionPhase _phase = _DecisionPhase.idle;
  String? _failureMessage;
  bool _retryMode = false;
  late final TextEditingController _typedController;
  bool _typedMatches = false;

  @override
  void initState() {
    super.initState();
    _typedController = TextEditingController();
    _typedController.addListener(_onTypedChanged);
  }

  @override
  void dispose() {
    _typedController
      ..removeListener(_onTypedChanged)
      ..dispose();
    super.dispose();
  }

  void _onTypedChanged() {
    final matches = _typedController.text == widget.typedConfirmation;
    if (matches != _typedMatches) {
      setState(() => _typedMatches = matches);
    }
  }

  bool get _locked => _phase == _DecisionPhase.loading;

  bool get _forced => widget.dismissible == false;

  bool get _canPopRoute {
    if (_locked) {
      return false;
    }
    if (_forced) {
      return false;
    }
    if (widget.tone == AppTone.danger) {
      return true;
    }
    return true;
  }

  Future<void> _onConfirmPressed() async {
    if (_locked || !_typedMatches) {
      return;
    }
    final work = widget.onConfirm;
    if (work == null) {
      Navigator.of(context).pop(OverlayAnswer.confirmed);
      return;
    }
    setState(() {
      _phase = _DecisionPhase.loading;
      _failureMessage = null;
    });
    try {
      await work();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(OverlayAnswer.confirmed);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _phase = _DecisionPhase.failure;
        _retryMode = true;
        _failureMessage = _messageFromError(error);
      });
    }
  }

  void _onCancelPressed() {
    if (_locked) {
      return;
    }
    Navigator.of(context).pop(OverlayAnswer.declined);
  }

  String _confirmText() {
    if (_phase == _DecisionPhase.loading) {
      return widget.confirmProgressLabel ?? 'Loading…';
    }
    if (_retryMode) {
      return _retryLabel(context);
    }
    return widget.confirmLabel;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return HomeFoundationScope(
      child: PopScope(
        canPop: _canPopRoute,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSize.screenPadding,
            AppSize.spaceMD,
            AppSize.screenPadding,
            AppSize.screenPadding + bottom + keyboard,
          ),
          child: _DecisionBody(
            title: widget.title,
            description: widget.description,
            failureMessage: _failureMessage,
            showHandle: true,
            showCloseControl: false,
            typedField: CustomTextField(
              label: '',
              placeholder: widget.typedConfirmation,
              controller: _typedController,
              disabled: _locked,
              clearable: !_locked,
            ),
            cancelLabel: widget.cancelLabel,
            confirmText: _confirmText(),
            tone: widget.tone,
            icon: widget.icon,
            iconWidget: widget.iconWidget,
            locked: _locked,
            confirmEnabled: _typedMatches,
            autofocusCancel: widget.tone == AppTone.danger && !_locked,
            onCancel: widget.cancelLabel == null ? null : _onCancelPressed,
            onConfirm: _onConfirmPressed,
          ),
        ),
      ),
    );
  }
}

class _DecisionBody extends StatelessWidget {
  const _DecisionBody({
    required this.title,
    required this.description,
    required this.failureMessage,
    required this.showHandle,
    required this.showCloseControl,
    required this.cancelLabel,
    required this.confirmText,
    required this.tone,
    required this.icon,
    this.iconWidget,
    required this.locked,
    required this.autofocusCancel,
    required this.onConfirm,
    this.onClose,
    this.onCancel,
    this.typedField,
    this.confirmEnabled = true,
  });

  final String title;
  final String? description;
  final String? failureMessage;
  final bool showHandle;
  final bool showCloseControl;
  final VoidCallback? onClose;
  final String? cancelLabel;
  final String confirmText;
  final AppTone tone;
  final IconData? icon;
  final Widget? iconWidget;
  final bool locked;
  final bool autofocusCancel;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;
  final Widget? typedField;
  final bool confirmEnabled;

  @override
  Widget build(BuildContext context) {
    final isDanger = tone == AppTone.danger;

    return Semantics(
      namesRoute: true,
      label: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHandle) const SheetDragHandle(),
          if (showHandle) AppSize.spaceLG.gap,
          if (showCloseControl)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(title, style: context.text.title)),
                AppButton(
                  text: '',
                  semanticLabel: _closeSemanticLabel(context),
                  isIconButton: true,
                  iconWidget: FoundationIcon(Icons.close),
                  style: AppButtonStyle.text,
                  foregroundColor: context.colors.onSurface,
                  onPressed: locked ? null : onClose,
                ),
              ],
            )
          else if (!showHandle && cancelLabel != null) ...[
            _DecisionDialogHeader(tone: tone, icon: icon, iconWidget: iconWidget, onDismiss: locked ? null : onCancel),
            AppSize.gap.gap,
            Text(title, style: context.text.title),
          ] else ...[
            if (!showHandle && tone != AppTone.brand) ...[
              _DecisionToneIcon(tone: tone, icon: icon, iconWidget: iconWidget),
              AppSize.gap.gap,
            ],
            Text(title, style: context.text.title),
          ],
          if (description != null && description!.isNotEmpty) ...[
            AppSize.gap.gap,
            Text(description!, style: context.text.body.setColor(context.colors.muted)),
          ],
          if (typedField != null) ...[AppSize.spaceLG.gap, typedField!],
          if (failureMessage != null) ...[
            AppSize.gap.gap,
            Text(failureMessage!, style: context.text.supporting.setColor(context.colors.error)),
          ],
          AppSize.spaceLG.gap,
          _DecisionActions(
            showHandle: showHandle,
            cancelLabel: cancelLabel,
            confirmText: confirmText,
            isDanger: isDanger,
            locked: locked,
            confirmEnabled: confirmEnabled,
            autofocusCancel: autofocusCancel,
            onCancel: onCancel,
            onConfirm: onConfirm,
          ),
        ],
      ),
    );
  }
}

class _DecisionDialogHeader extends StatelessWidget {
  const _DecisionDialogHeader({required this.tone, required this.icon, this.iconWidget, required this.onDismiss});

  final AppTone tone;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tone != AppTone.brand)
          _DecisionToneIcon(tone: tone, icon: icon, iconWidget: iconWidget)
        else
          const SizedBox.shrink(),
        const Spacer(),
        AppButton(
          text: '',
          semanticLabel: _closeSemanticLabel(context),
          isIconButton: true,
          iconWidget: FoundationIcon(Icons.close),
          style: AppButtonStyle.text,
          foregroundColor: context.colors.onSurface,
          onPressed: onDismiss,
        ),
      ],
    );
  }
}

class _DecisionToneIcon extends StatelessWidget {
  const _DecisionToneIcon({required this.tone, this.icon, this.iconWidget});

  final AppTone tone;
  final IconData? icon;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final glyphColor = tone.glyph(colors);
    final Widget child;
    if (iconWidget != null) {
      child = iconWidget!;
    } else if (icon != null) {
      child = FoundationIcon(icon!, size: AppSize.icon, color: glyphColor);
    } else if (tone == AppTone.danger) {
      child = FoundationIcon(Icons.logout, size: AppSize.icon, color: glyphColor);
    } else {
      child = tone.glyphWidget(size: AppSize.icon, color: glyphColor);
    }
    return DecoratedBox(
      decoration: BoxDecoration(color: tone.tint(colors), borderRadius: BorderRadius.circular(AppSize.radius)),
      child: Padding(padding: const EdgeInsets.all(AppSize.spaceSM), child: child),
    );
  }
}

class _DecisionActions extends StatelessWidget {
  const _DecisionActions({
    required this.showHandle,
    required this.cancelLabel,
    required this.confirmText,
    required this.isDanger,
    required this.locked,
    required this.confirmEnabled,
    required this.autofocusCancel,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool showHandle;
  final String? cancelLabel;
  final String confirmText;
  final bool isDanger;
  final bool locked;
  final bool confirmEnabled;
  final bool autofocusCancel;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final confirm = isDanger
        ? AppButton.destructive(
            text: confirmText,
            isExpanded: showHandle,
            onPressed: locked || !confirmEnabled ? null : onConfirm,
          )
        : AppButton.primary(
            text: confirmText,
            isExpanded: showHandle,
            onPressed: locked || !confirmEnabled ? null : onConfirm,
          );

    if (cancelLabel == null) {
      return confirm;
    }

    final cancel = _neutralCancelButton(
      context: context,
      text: cancelLabel!,
      isExpanded: showHandle,
      autofocus: autofocusCancel,
      onPressed: locked ? null : onCancel,
    );

    if (showHandle) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [cancel, AppSize.gap.gap, confirm]);
    }

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Wrap(
        spacing: AppSize.gap,
        runSpacing: AppSize.gap,
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [cancel, confirm],
      ),
    );
  }
}

String _messageFromError(Object error) {
  if (error is BnoodFailure) {
    return error.message;
  }
  return error.toString();
}
