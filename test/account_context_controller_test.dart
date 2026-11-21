import 'package:bnood/core/account/account_context_providers.dart';
import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/core/data/prefs/app_settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleOfficeId = '01J9Z8XQ8K9M2N3P4R5S6T7V8W';

  ProviderContainer newTestContainer({
    Map<String, Object> initialPrefs = const {},
  }) {
    SharedPreferences.setMockInitialValues(initialPrefs);
    return ProviderContainer(
      overrides: [
        appSettingsBootstrapProvider.overrideWithValue(
          AppSettingsSnapshot(
            prefs: null,
            themeMode: ThemeMode.system,
            locale: const Locale('ar'),
          ),
        ),
      ],
    );
  }

  tearDown(() {
    debugAccountScopedResetHook = null;
    ApiOfficeHeader.syncOfficeId(null);
  });

  test('restoreFromDisk applies stored office and syncs header', () async {
    final container = newTestContainer(
      initialPrefs: {'bnood.account.selection': sampleOfficeId},
    );
    addTearDown(container.dispose);

    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    final ctx = container.read(accountContextProvider);
    expect(ctx.officeId, sampleOfficeId);
    expect(ApiOfficeHeader.headerValue(), sampleOfficeId);
  });

  test('selectOffice persists and updates header', () async {
    final container = newTestContainer();
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(sampleOfficeId);

    expect(container.read(accountContextProvider).officeId, sampleOfficeId);
    expect(ApiOfficeHeader.headerValue(), sampleOfficeId);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('bnood.account.selection'), sampleOfficeId);
  });

  test('account switch invokes cache reset hook', () async {
    var resetCount = 0;
    debugAccountScopedResetHook = () => resetCount++;

    final container = newTestContainer();
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(sampleOfficeId);
    expect(resetCount, 1);

    await container.read(accountContextProvider.notifier).selectPersonal();
    expect(resetCount, 2);
  });

  test('selectPersonal clears office header', () async {
    final container = newTestContainer();
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(sampleOfficeId);
    await container.read(accountContextProvider.notifier).selectPersonal();

    expect(container.read(accountContextProvider).isPersonal, isTrue);
    expect(ApiOfficeHeader.headerValue(), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('bnood.account.selection'), 'personal');
  });
}