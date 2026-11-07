import 'package:flutter/material.dart';

import '../config/navigation/root_navigator_key.dart';
import '../config/theme/app_size.dart';
import 'bnood_failure.dart';
import 'toast/app_toast.dart';
import 'toast/app_tone.dart';

export 'toast/app_toast.dart' show ToastAction;

class FoundationToaster {
  const FoundationToaster._();

  static const Duration _persistentDuration = Duration(days: 1);

  static BuildContext? get _context => rootNavigatorKey.currentContext;

  static void success(
    String message, {
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    _show(AppTone.success, message, duration ?? const Duration(seconds: 3), action, persistent: persistent);
  }

  static void fromFailure(
    BnoodFailure failure, {
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    FoundationToaster.failure(
      failure.message,
      title: failure.title,
      duration: duration,
      action: action,
      persistent: persistent,
    );
  }

  static void failure(
    String message, {
    String? title,
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    _show(
      AppTone.danger,
      message,
      duration ?? const Duration(seconds: 4),
      action,
      title: title,
      persistent: persistent,
    );
  }

  static void warning(
    String message, {
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    _show(AppTone.warning, message, duration ?? const Duration(seconds: 4), action, persistent: persistent);
  }

  static void info(
    String message, {
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    _show(AppTone.info, message, duration ?? const Duration(seconds: 3), action, persistent: persistent);
  }

  static void loading(String message, {Duration? duration}) {
    _show(AppTone.neutral, message, duration ?? const Duration(seconds: 30), null, isLoading: true);
  }

  static void clear() {
    final context = _context;
    if (context == null || !context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  static void _show(
    AppTone tone,
    String message,
    Duration duration,
    ToastAction? action, {
    bool isLoading = false,
    String? title,
    bool persistent = false,
  }) {
    final context = _context;
    if (context == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context)..clearSnackBars();
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

    final resolvedDuration = persistent ? _persistentDuration : duration;

    messenger.showSnackBar(
      SnackBar(
        content: AppToast(
          tone: tone,
          message: message,
          title: title,
          action: resolvedAction,
          isLoading: isLoading,
        ),
        duration: resolvedDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: EdgeInsetsDirectional.only(
          start: AppSize.spaceMD,
          end: AppSize.spaceMD,
          bottom: AppSize.spaceMD + MediaQuery.viewPaddingOf(context).bottom + AppSize.shellDockClearance,
        ),
      ),
    );
  }
}
