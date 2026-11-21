/// Sentry `release` string — must match [PackageInfo] `version` + `buildNumber`.
String sentryReleaseName({
  required String version,
  required String buildNumber,
}) {
  return '$version+$buildNumber';
}
