import 'package:flutter/material.dart';

import '../config/navigation/root_navigator_key.dart';
import '../config/theme/app_size.dart';
import '../../features/home/home_foundation_scope.dart';
import 'toast/app_toast.dart';
import 'toast/app_tone.dart';

export 'toast/app_toast.dart' show ToastAction;

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum ToastKind { success, failure, warning, info }

/// Where to anchor floating toasts above chrome (shell dock vs statement export bar).
enum AppToastLayoutHint { standard, statementExportFooter }

/// Canonical transient notification API — themed [AppToast] via root [ScaffoldMessenger].
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

  static ScaffoldMessengerState? _messenger({BuildContext? layoutContext}) {
    return rootScaffoldMessengerKey.currentState ??
        (layoutContext != null && layoutContext.mounted
            ? ScaffoldMessenger.maybeOf(layoutContext)
            : null);
  }

  static BuildContext? _layoutContext(BuildContext? layoutContext) {
    if (layoutContext != null && layoutContext.mounted) return layoutContext;
    final root = rootNavigatorKey.currentContext;
    if (root != null && root.mounted) return root;
    return rootScaffoldMessengerKey.currentState?.context;
  }

  static EdgeInsetsDirectional _margin(BuildContext? layoutContext, AppToastLayoutHint layout) {
    final ctx = _layoutContext(layoutContext);
    final mq = ctx != null ? MediaQuery.maybeOf(ctx) : null;
    final bottomInset = mq?.viewPadding.bottom ?? 0;
    final keyboard = mq?.viewInsets.bottom ?? 0;
    final base = switch (layout) {
      AppToastLayoutHint.standard => AppSize.spaceMD + bottomInset + AppSize.shellDockClearance,
      AppToastLayoutHint.statementExportFooter =>
        AppSize.buttonHeight + AppSize.spaceMD + AppSize.spaceSM + bottomInset + AppSize.spaceMD,
    };
    return EdgeInsetsDirectional.only(
      start: AppSize.spaceMD,
      end: AppSize.spaceMD,
      bottom: base + keyboard,
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
    final messenger = _messenger(layoutContext: layoutContext);
    if (messenger == null) return;

    final tone = _toneFor(kind, isLoading: isLoading);
    final resolvedDuration = persistent ? _persistentDuration : (duration ?? _defaultDuration(kind, isLoading: isLoading));

    ToastAction? resolvedAction;
    if (action case final action?) {
      resolvedAction = ToastAction(
        label: action.label,
        onPressed: () {
          action.onPressed();
          messenger.hideCurrentSnackBar();
        },
      );
    }

    if (replace) {
      messenger.hideCurrentSnackBar();
    }

    messenger.showSnackBar(
      SnackBar(
        content: HomeFoundationScope(
          child: Builder(
            builder: (ctx) => AppToast(
              tone: tone,
              message: message,
              title: title,
              action: resolvedAction,
              isLoading: isLoading,
            ),
          ),
        ),
        duration: resolvedDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: _margin(layoutContext, layout),
      ),
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
    final messenger = rootScaffoldMessengerKey.currentState;
    messenger?.clearSnackBars();
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      ScaffoldMessenger.maybeOf(ctx)?.clearSnackBars();
    }
  }
}
