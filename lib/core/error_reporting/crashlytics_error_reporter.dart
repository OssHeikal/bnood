import 'dart:async';

import 'package:flutter/foundation.dart';

import 'crashlytics_client.dart';
import 'error_reporting_user_keys.dart';
import 'error_reporter.dart';
import 'error_reporting_user.dart';
import 'reporting_user_identity.dart';

typedef CrashlyticsActiveGate = bool Function();

/// Firebase Crashlytics sink; collection is release-only ([kReleaseMode]).
final class CrashlyticsErrorReporter implements ErrorReporter {
  CrashlyticsErrorReporter({
    CrashlyticsClient? client,
    CrashlyticsActiveGate? isActive,
  })  : _clientOverride = client,
        _isActive = isActive ?? (() => kReleaseMode);

  final CrashlyticsClient? _clientOverride;
  CrashlyticsClient? _client;
  final CrashlyticsActiveGate _isActive;

  CrashlyticsClient get _resolvedClient =>
      _client ??= _clientOverride ?? FirebaseCrashlyticsClient();

  bool get _collecting => _isActive();

  @override
  void addBreadcrumb({required String message, String? category, Map<String, Object?>? data}) {
    if (!_collecting) return;
    final categoryPrefix = category == null ? '' : '[$category] ';
    if (data == null || data.isEmpty) {
      unawaited(_resolvedClient.log('$categoryPrefix$message'));
      return;
    }
    unawaited(_resolvedClient.log('$categoryPrefix$message | $data'));
  }

  @override
  void captureException(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? context,
    bool fatal = false,
  }) {
    if (!_collecting) return;
    unawaited(
      _resolvedClient.recordError(
        error,
        stackTrace,
        fatal: fatal,
        reason: _contextReason(context),
      ),
    );
  }

  @override
  void captureMessage(
    String message, {
    Map<String, Object?>? context,
    ErrorReportLevel level = ErrorReportLevel.info,
  }) {
    if (!_collecting) return;
    final reason = _contextReason(context);
    final line = reason == null ? message : '$message | $reason';
    if (level == ErrorReportLevel.error || level == ErrorReportLevel.fatal) {
      unawaited(
        _resolvedClient.recordError(
          Exception(line),
          StackTrace.current,
          fatal: level == ErrorReportLevel.fatal,
        ),
      );
      return;
    }
    unawaited(_resolvedClient.log(line));
  }

  @override
  void clearUser() {
    if (!_collecting) return;
    unawaited(_resolvedClient.setUserIdentifier(''));
    unawaited(_resolvedClient.setCustomKey(errorReportingLoginPhoneKey, ''));
  }

  @override
  void setUser(ErrorReportingUser? user) {
    if (!_collecting) return;
    final identity = reportingUserIdentity(user);
    if (identity == null) {
      clearUser();
      return;
    }
    unawaited(_resolvedClient.setUserIdentifier(identity.id));
    unawaited(_resolvedClient.setCustomKey(errorReportingLoginPhoneKey, identity.loginPhone));
  }

  static String? _contextReason(Map<String, Object?>? context) {
    if (context == null || context.isEmpty) return null;
    return context.entries.map((e) => '${e.key}=${e.value}').join(', ');
  }
}