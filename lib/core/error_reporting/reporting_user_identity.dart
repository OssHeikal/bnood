import 'error_reporting_user.dart';

/// Login identity fields shared by Crashlytics, Sentry, and other reporters.
final class ReportingUserIdentity {
  const ReportingUserIdentity({required this.id, required this.loginPhone});

  final String id;
  final String loginPhone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportingUserIdentity && id == other.id && loginPhone == other.loginPhone;

  @override
  int get hashCode => Object.hash(id, loginPhone);
}

ReportingUserIdentity? reportingUserIdentity(ErrorReportingUser? user) {
  if (user == null) return null;
  return ReportingUserIdentity(id: user.id, loginPhone: user.phone);
}