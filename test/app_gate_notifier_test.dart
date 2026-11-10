import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/app_gate/app_config_record.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/features/app_gate/app_gate_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/stub_app_config_api.dart';

void main() {
  test('fetchConfig fail-open returns ok on error', () async {
    final container = ProviderContainer(
      overrides: [
        appSettingsBootstrapProvider.overrideWithValue(
          const AppSettingsSnapshot(themeMode: ThemeMode.light, locale: Locale('en'), prefs: null),
        ),
        appConfigApiProvider.overrideWith(
          (ref) => StubAppConfigApi(({
            required platform,
            required version,
            required locale,
          }) async {
            throw AuthApiException(statusCode: 500, message: 'error');
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    final data = await container.read(appGateProvider.notifier).fetchConfig(failOpen: true);
    expect(data.status, AppGateStatus.ok);
  });
}
