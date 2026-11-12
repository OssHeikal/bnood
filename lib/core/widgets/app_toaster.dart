import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import '../config/navigation/root_navigator_key.dart';
import '../config/theme/app_size.dart';
import '../../features/home/home_foundation_scope.dart';
import 'toast/app_toast.dart';
import 'toast/app_tone.dart';

export 'toast/app_toast.dart' show ToastAction;

enum ToastKind { success, failure, warning, info }

/// Where to anchor floating toasts above chrome (shell dock vs statement export bar).
enum AppToastLayoutHint { standard, statementExportFooter }

/// Canonical transient notification API — themed [AppToast] via [BotToast].
abstract final class AppToaster {
  static const Duration _persistentDuration = Duration(days: 1);

  static AppTone _toneFor(ToastKind kind, {required bool isLoading}) {
    if (isLoading) return AppTone.neutral;
    return switch (kind) {
      ToastKind.success => AppTone.success,
      ToastKind.failure => AppTone.danger,
      ToastKind.warning => AppTone.warning,
      ToastKind.info => AppTone.info,
    };
  }

  static Duration _defaultDuration(ToastKind kind, {required bool isLoading}) {
    if (isLoading) return const Duration(seconds: 30);
    return switch (kind) {
      ToastKind.success => const Duration(seconds: 3),
      ToastKind.failure => const Duration(seconds: 4),
      ToastKind.warning => const Duration(seconds: 4),
      ToastKind.info => const Duration(seconds: 3),
    };
  }

  static BuildContext? _layoutContext(BuildContext? layoutContext) {
    if (layoutContext != null && layoutContext.mounted) return layoutContext;
    final root = rootNavigatorKey.currentContext;
    if (root != null && root.mounted) return root;
    return null;
  }

  static EdgeInsetsDirectional _margin(BuildContext? layoutContext, AppToastLayoutHint layout) {
    final ctx = _layoutContext(layoutContext);
    final mq = ctx != null ? MediaQuery.maybeOf(ctx) : null;
    final bottomInset = mq?.viewPadding.bottom ?? 0;
    final base = switch (layout) {
      AppToastLayoutHint.standard => AppSize.spaceMD + bottomInset + AppSize.shellDockClearance,
      AppToastLayoutHint.statementExportFooter =>
        AppSize.buttonHeight + AppSize.spaceMD + AppSize.spaceSM + bottomInset + AppSize.spaceMD,
    };
    return EdgeInsetsDirectional.only(
      start: AppSize.spaceMD,
      end: AppSize.spaceMD,
      bottom: base,
    );
  }

  static void show(
    String message, {
    ToastKind kind = ToastKind.info,
    BuildContext? layoutContext,
    AppToastLayoutHint layout = AppToastLayoutHint.standard,
    String? title,
    Duration? duration,
    ToastAction? action,
    bool isLoading = false,
    bool persistent = false,
    bool replace = true,
  }) {
    final tone = _toneFor(kind, isLoading: isLoading);
    final resolvedDuration = persistent ? _persistentDuration : (duration ?? _defaultDuration(kind, isLoading: isLoading));

    BotToast.showCustomText(
      onlyOne: replace,
      duration: persistent ? null : resolvedDuration,
      align: Alignment.bottomCenter,
      backgroundColor: Colors.transparent,
      clickClose: false,
      ignoreContentClick: false,
      crossPage: true,
      useSafeArea: false,
      enableKeyboardSafeArea: true,
      toastBuilder: (cancel) {
        ToastAction? resolvedAction;
        if (action case final action?) {
          resolvedAction = ToastAction(
            label: action.label,
            onPressed: () {
              action.onPressed();
              cancel();
            },
          );
        }

        return Padding(
          padding: _margin(layoutContext, layout),
          child: HomeFoundationScope(
            child: AppToast(
              tone: tone,
              message: message,
              title: title,
              action: resolvedAction,
              isLoading: isLoading,
            ),
          ),
        );
      },
    );
  }

  static void success(
    String message, {
    BuildContext? layoutContext,
    AppToastLayoutHint layout = AppToastLayoutHint.standard,
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    show(
      message,
      kind: ToastKind.success,
      layoutContext: layoutContext,
      layout: layout,
      duration: duration,
      action: action,
      persistent: persistent,
    );
  }

  static void failure(
    String message, {
    BuildContext? layoutContext,
    AppToastLayoutHint layout = AppToastLayoutHint.standard,
    String? title,
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    show(
      message,
      kind: ToastKind.failure,
      layoutContext: layoutContext,
      layout: layout,
      title: title,
      duration: duration,
      action: action,
      persistent: persistent,
    );
  }

  static void warning(
    String message, {
    BuildContext? layoutContext,
    AppToastLayoutHint layout = AppToastLayoutHint.standard,
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    show(
      message,
      kind: ToastKind.warning,
      layoutContext: layoutContext,
      layout: layout,
      duration: duration,
      action: action,
      persistent: persistent,
    );
  }

  static void info(
    String message, {
    BuildContext? layoutContext,
    AppToastLayoutHint layout = AppToastLayoutHint.standard,
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    show(
      message,
      kind: ToastKind.info,
      layoutContext: layoutContext,
      layout: layout,
      duration: duration,
      action: action,
      persistent: persistent,
    );
  }

  static void loading(
    String message, {
    BuildContext? layoutContext,
    AppToastLayoutHint layout = AppToastLayoutHint.standard,
    Duration? duration,
  }) {
    show(
      message,
      layoutContext: layoutContext,
      layout: layout,
      duration: duration,
      isLoading: true,
      replace: true,
    );
  }

  static void clear() {
    BotToast.cleanAll();
  }
}
