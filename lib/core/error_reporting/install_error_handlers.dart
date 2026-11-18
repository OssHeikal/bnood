import 'package:flutter/foundation.dart';

import 'error_reporter.dart';

/// Routes Flutter framework and isolate errors to [reporter], keeping default debug output.
void installErrorHandlers(ErrorReporter reporter) {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
    reporter.captureException(
      details.exception,
      details.stack,
      context: _flutterDetailsContext(details),
      fatal: true,
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('Uncaught platform error: $error');
      debugPrintStack(stackTrace: stack);
    }
    reporter.captureException(error, stack, fatal: true);
    return true;
  };
}

Map<String, Object?>? _flutterDetailsContext(FlutterErrorDetails details) {
  final library = details.library;
  final contextDescription = details.context?.toDescription();
  if (library == null && contextDescription == null) return null;
  return {
    'library': ?library,
    'context': ?contextDescription,
  };
}