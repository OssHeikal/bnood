import 'package:bnood/features/statements/statement_prefs_access.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns null when shared_preferences platform channel fails', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (call) async => throw PlatformException(code: 'channel-error', message: 'Unavailable'),
    );
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/shared_preferences'), null);
    });

    final prefs = await StatementPrefsAccess.getInstance();
    expect(prefs, isNull);
  });
}
