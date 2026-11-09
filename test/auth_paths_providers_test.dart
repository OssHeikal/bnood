import 'package:bnood/features/auth/auth_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('/directory is not treated as local-only ledger root', () {
    expect(isRemoteDirectoryLocation('/directory'), isTrue);
    expect(isLocalLedgerLocation('/directory'), isFalse);
  });
}
