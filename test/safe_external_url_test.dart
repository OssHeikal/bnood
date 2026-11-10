import 'package:bnood/core/utils/safe_external_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allows http https mailto tel only', () {
    expect(isAllowedExternalUrlString('https://example.com'), isTrue);
    expect(isAllowedExternalUrlString('http://example.com'), isTrue);
    expect(isAllowedExternalUrlString('mailto:support@example.com'), isTrue);
    expect(isAllowedExternalUrlString('tel:+96812345678'), isTrue);
    expect(isAllowedExternalUrlString('javascript:alert(1)'), isFalse);
    expect(isAllowedExternalUrlString('file:///etc/passwd'), isFalse);
    expect(isAllowedExternalUrlString('not a url'), isFalse);
  });
}
