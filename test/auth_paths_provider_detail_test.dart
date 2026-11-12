import 'package:bnood/features/auth/auth_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('/providers/:id is remote-safe (not local ledger)', () {
    expect(isRemoteProviderDetailLocation('/providers/01JPROV'), isTrue);
    expect(isLocalLedgerLocation('/providers/01JPROV'), isFalse);
  });
}
