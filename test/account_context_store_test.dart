import 'package:bnood/core/account/account_context_store.dart';
import 'package:bnood/core/account/account_scope.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleOfficeId = '01J9Z8XQ8K9M2N3P4R5S6T7V8W';

  test('round-trips personal selection', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await AccountContextStore.writeScope(prefs, const AccountScope.personal());
    final scope = await AccountContextStore.readScope(prefs);
    expect(scope.isPersonal, isTrue);
  });

  test('round-trips office selection', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await AccountContextStore.writeScope(
      prefs,
      AccountScope.office(sampleOfficeId),
    );
    final scope = await AccountContextStore.readScope(prefs);
    expect(scope.officeId, sampleOfficeId);
  });

  test('invalid stored id falls back to personal', () async {
    SharedPreferences.setMockInitialValues({
      'bnood.account.selection': 'bad-id',
    });
    final prefs = await SharedPreferences.getInstance();
    final scope = await AccountContextStore.readScope(prefs);
    expect(scope.isPersonal, isTrue);
  });
}