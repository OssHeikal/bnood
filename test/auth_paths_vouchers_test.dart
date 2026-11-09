import 'package:bnood/features/auth/auth_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('remote voucher session follows remote clients gate', () {
    expect(isRemoteVouchersSessionEnabled(remoteClientsEnabled: true), isTrue);
    expect(isRemoteVouchersSessionEnabled(remoteClientsEnabled: false), isFalse);
  });
}
