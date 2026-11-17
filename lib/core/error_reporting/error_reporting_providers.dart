import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'composite_error_reporter.dart';
import 'error_reporter.dart';

/// Backends registered for error reporting (empty until later slices).
final errorReportersProvider = Provider<List<ErrorReporter>>((ref) => const []);

final errorReporterProvider = Provider<ErrorReporter>((ref) {
  return CompositeErrorReporter(ref.watch(errorReportersProvider));
});