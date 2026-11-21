import 'package:bnood/core/services/error_reporting/sentry_release_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sentryReleaseName matches PackageInfo version+build', () {
    expect(sentryReleaseName(version: '1.2.3', buildNumber: '42'), '1.2.3+42');
  });
}
