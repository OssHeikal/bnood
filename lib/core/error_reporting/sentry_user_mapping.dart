import 'package:sentry_flutter/sentry_flutter.dart';

import 'error_reporting_user.dart';
import 'reporting_user_identity.dart';

/// Sentry user: login phone only (not statement contact phone).
SentryUser? sentryUserForReporting(ErrorReportingUser? user) {
  final identity = reportingUserIdentity(user);
  if (identity == null) return null;
  return SentryUser(id: identity.id, username: identity.loginPhone);
}
