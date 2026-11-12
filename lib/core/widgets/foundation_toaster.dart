import 'app_toaster.dart';
import 'bnood_failure.dart';

export 'app_toaster.dart' show ToastAction, AppToaster, ToastKind, AppToastLayoutHint;

/// Preview / legacy entrypoints — delegate to [AppToaster].
class FoundationToaster {
  const FoundationToaster._();

  static void success(
    String message, {
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    AppToaster.success(message, duration: duration, action: action, persistent: persistent);
  }

  static void fromFailure(
    BnoodFailure failure, {
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    AppToaster.failure(
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
    AppToaster.failure(
      message,
      title: title,
      duration: duration,
      action: action,
      persistent: persistent,
    );
  }

  static void warning(
    String message, {
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    AppToaster.warning(message, duration: duration, action: action, persistent: persistent);
  }

  static void info(
    String message, {
    Duration? duration,
    ToastAction? action,
    bool persistent = false,
  }) {
    AppToaster.info(message, duration: duration, action: action, persistent: persistent);
  }

  static void loading(String message, {Duration? duration}) {
    AppToaster.loading(message, duration: duration);
  }

  static void clear() => AppToaster.clear();
}
