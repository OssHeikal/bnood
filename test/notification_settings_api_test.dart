import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/features/settings/data/notification_settings_api.dart';
import 'package:bnood/core/push/notification_settings_record.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

NotificationSettingsApi _api(Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return NotificationSettingsApi(dio: dio);
}

void main() {
  test('getSettings parses low balance fields', () async {
    final api = _api((_) async => jsonResponse('''
{
  "success": true,
  "data": {
    "low_balance_enabled": true,
    "low_balance_amount": 1500000
  }
}
'''));
    final record = await api.getSettings();
    expect(record.lowBalanceEnabled, isTrue);
    expect(record.lowBalanceAmountMinor, 1_500_000);
  });

  test('getSettings uses default amount when missing', () async {
    final api = _api((_) async => jsonResponse('''
{
  "success": true,
  "data": {
    "low_balance_enabled": false
  }
}
'''));
    final record = await api.getSettings();
    expect(record.lowBalanceAmountMinor, kDefaultLowBalanceAmountMinor);
  });

  test('patchSettings sends only provided fields', () async {
    Map<String, dynamic>? body;
    final api = _api((options) async {
      body = options.data as Map<String, dynamic>?;
      return jsonResponse('''
{
  "success": true,
  "data": {
    "low_balance_enabled": false,
    "low_balance_amount": 2000000
  }
}
''');
    });
    final updated = await api.patchSettings(lowBalanceEnabled: false);
    expect(body, {'low_balance_enabled': false});
    expect(updated.lowBalanceEnabled, isFalse);
    expect(updated.lowBalanceAmountMinor, 2_000_000);
  });
}