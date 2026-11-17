import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'composite_error_reporter.dart';
import 'error_reporter.dart';
import 'error_reporter_registrar.dart';

/// Backends registered for error reporting (Sentry when `SENTRY_DSN` is set).
final errorReportersProvider = Provider<List<ErrorReporter>>((ref) => buildErrorReporters());

final errorReporterProvider = Provider<ErrorReporter>((ref) {
  return CompositeErrorReporter(ref.watch(errorReportersProvider));
});