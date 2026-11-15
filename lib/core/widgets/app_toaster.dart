import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import '../config/navigation/root_navigator_key.dart';
import '../config/theme/app_size.dart';
import '../layout/app_layout.dart';
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

  static EdgeInsetsDirectional _margin(BuildContext ctx, AppToastLayoutHint layout) {
    final mq = MediaQuery.maybeOf(ctx);
    final safeBottom = mq?.viewPadding.bottom ?? 0;
    final keyboard = mq?.viewInsets.bottom ?? 0;
    final bottomInset = keyboard > safeBottom ? keyboard : safeBottom;
    final chromeBottom = switch (layout) {
      AppToastLayoutHint.standard => AppSize.spaceMD + bottomInset + AppSize.shellDockClearance,
      AppToastLayoutHint.statementExportFooter =>
        AppSize.buttonHeight + AppSize.spaceMD + AppSize.spaceSM + bottomInset + AppSize.spaceMD,
    };
    final wide = !ctx.isMobileLayout;
    return EdgeInsetsDirectional.only(
      start: wide ? 0 : AppSize.spaceMD,
      end: wide ? 0 : AppSize.spaceMD,
      bottom: chromeBottom,
    );
  }

  static Widget _toastShell({
    required BuildContext layoutCtx,
    required AppTone tone,
    required String message,
    String? title,
    ToastAction? action,
    required bool isLoading,
  }) {
    final toast = AppToast(
      tone: tone,
      message: message,
      title: title,
      action: action,
      isLoading: isLoading,
    );
    if (layoutCtx.isMobileLayout) {
      return toast;
    }
    return Align(
      alignment: Alignment.bottomCenter,
      widthFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.toastMaxWidth),
        child: toast,
      ),
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
        final layoutCtx = _layoutContext(layoutContext);
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

        if (layoutCtx == null) {
          return HomeFoundationScope(
            child: AppToast(
              tone: tone,
              message: message,
              title: title,
              action: resolvedAction,
              isLoading: isLoading,
            ),
          );
        }

        return Padding(
          padding: _margin(layoutCtx, layout),
          child: HomeFoundationScope(
            child: _toastShell(
              layoutCtx: layoutCtx,
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
