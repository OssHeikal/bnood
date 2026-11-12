import 'package:bnood/core/config/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('baseUrl uses BNOOD_API_BASE_URL dart-define with local dev default', () {
    // Without --dart-define / --dart-define-from-file, matches .env.dev.
    expect(ApiConfig.baseUrl, 'http://bnood.test/api');
  });
}
