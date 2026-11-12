import 'package:bnood/core/api/api_accept_language.dart';
import 'package:bnood/core/api/app_dio.dart';
import 'package:flutter/material.dart';
import 'package:bnood/core/api/subscription_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

SubscriptionApi _api(Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return SubscriptionApi(dio: dio);
}

void main() {
  test('getSubscription maps paywall payload and sends Accept-Language', () async {
    ApiAcceptLanguage.syncLocale(const Locale('ar'));
    late String? acceptLanguage;
    final api = _api((options) async {
      acceptLanguage = options.headers['Accept-Language'] as String?;
      return jsonResponse('''
{
  "success": true,
  "data": {
    "paywall_enabled": true,
    "entitlements": {
      "package_slug": "free",
      "package_name": "Free",
      "show_paywall_surfaces": true,
      "can_create_active_project": false
    },
    "paywall": {
      "title": "Title",
      "subtitle": "Sub",
      "benefits": ["a"],
      "plans": [
        {"id": "yearly", "label": "Yearly", "total_minor": 299000, "savings_badge": "Save"}
      ]
    }
  }
}
''');
    });
    final snap = await api.getSubscription(languageCode: 'ar');
    expect(acceptLanguage, acceptLanguageHeaderForLocale('ar'));
    expect(snap.paywallEnabled, isTrue);
    expect(snap.entitlements.canCreateActiveProject, isFalse);
    expect(snap.paywall?.title, 'Title');
    expect(snap.paywall?.planById('yearly')?.monthlyEquivalentMinor, 299000 ~/ 12);
  });
}
