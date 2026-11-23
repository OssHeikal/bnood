import 'package:bnood/core/account/account_context_store.dart';
import 'package:bnood/core/account/account_scope.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleOfficeId = '01J9Z8XQ8K9M2N3P4R5S6T7V8W';

  test('previous scope round-trip', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await AccountContextStore.writePreviousScope(
      prefs,
      const AccountScope.personal(),
    );
    final read = await AccountContextStore.readPreviousScope(prefs);
    expect(read?.isPersonal, isTrue);
  });

  test('invalid previous office id ignored', () async {
    SharedPreferences.setMockInitialValues({
      'bnood.account.previous': 'not-an-office-id',
    });
    final prefs = await SharedPreferences.getInstance();
    final read = await AccountContextStore.readPreviousScope(prefs);
    expect(read, isNull);
  });

  test('valid previous office id restored', () async {
    SharedPreferences.setMockInitialValues({
      'bnood.account.previous': sampleOfficeId,
    });
    final prefs = await SharedPreferences.getInstance();
    final read = await AccountContextStore.readPreviousScope(prefs);
    expect(read?.officeId, sampleOfficeId);
  });
}