import 'package:sentry_flutter/sentry_flutter.dart';

import 'sentry_config.dart';

/// Initializes the native Sentry SDK when [SentryConfig.isEnabled].
///
/// Flutter/platform error handlers are installed separately via
/// [installErrorHandlers] so events are not reported twice.
Future<void> bootstrapSentry({required String release}) async {
  if (!SentryConfig.isEnabled) return;

  await SentryFlutter.init((options) {
    options.dsn = SentryConfig.dsn;
    options.environment = SentryConfig.environment;
    options.release = release;
    options.tracesSampleRate = 0.2;
    options.captureFailedRequests = false;
  });
}
