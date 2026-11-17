import 'package:sentry_flutter/sentry_flutter.dart';

import 'error_reporting_user.dart';

/// Sentry user: login [ErrorReportingUser.phone] only (not statement contact phone).
SentryUser? sentryUserForReporting(ErrorReportingUser? user) {
  if (user == null) return null;
  return SentryUser(id: user.id, username: user.phone);
}