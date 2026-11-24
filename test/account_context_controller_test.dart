import 'package:bnood/app/app_root_restart.dart';
import 'package:bnood/core/account/account_context_providers.dart';
import 'package:bnood/core/account/auth_office_payload.dart';
import 'package:bnood/core/account/office_membership.dart';
import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/core/data/prefs/app_settings_store.dart';
import 'package:bnood/core/network/api/auth_api_exception.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleOfficeId = '01J9Z8XQ8K9M2N3P4R5S6T7V8W';

  Future<ProviderContainer> newTestContainer({
    Map<String, Object> initialPrefs = const {},
    AuthOfficePayload? officeContext,
  }) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        appSettingsBootstrapProvider.overrideWithValue(
          AppSettingsSnapshot(
            prefs: prefs,
            themeMode: ThemeMode.system,
            locale: const Locale('ar'),
          ),
        ),
        if (officeContext != null)
          authControllerProvider.overrideWith(
            () => _AuthWithOffice(officeContext),
          ),
      ],
    );
  }

  tearDown(() {
    SharedPreferences.setMockInitialValues({});
    AppRootRestart.resetForTest();
    debugAccountScopedResetHook = null;
    ApiOfficeHeader.syncOfficeId(null);
  });

  test('container recreate restores office selection and header', () async {
    const offices = AuthOfficePayload(
      offices: [
        OfficeMembership(
          id: sampleOfficeId,
          name: 'Office',
          readOnly: false,
          isOwner: false,
        ),
      ],
    );
    final container = await newTestContainer(officeContext: offices);
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(sampleOfficeId);
    await pumpEventQueue();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('bnood.account.selection'), sampleOfficeId);
    container.dispose();

    final recreated = await newTestContainer(
      officeContext: offices,
      initialPrefs: {'bnood.account.selection': sampleOfficeId},
    );
    addTearDown(recreated.dispose);
    recreated.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    expect(recreated.read(accountContextProvider).officeId, sampleOfficeId);
    expect(ApiOfficeHeader.headerValue(), sampleOfficeId);
  });

  test('empty office list does not clear stored office scope', () async {
    final container = await newTestContainer(
      initialPrefs: {'bnood.account.selection': sampleOfficeId},
      officeContext: const AuthOfficePayload(offices: []),
    );
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    expect(container.read(accountContextProvider).officeId, sampleOfficeId);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('bnood.account.selection'), sampleOfficeId);
  });

  test('restoreFromDisk applies stored office and syncs header', () async {
    final container = await newTestContainer(
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
    final container = await newTestContainer();
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

  test('account switch requests root restart', () async {
    var restartCount = 0;
    AppRootRestart.bind(() => restartCount++);

    final container = await newTestContainer();
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(sampleOfficeId);
    await pumpEventQueue();
    expect(restartCount, 1);

    await container.read(accountContextProvider.notifier).selectPersonal();
    await pumpEventQueue();
    expect(restartCount, 2);
  });

  test('owner with stored personal migrates to owned office', () async {
    const ownedId = sampleOfficeId;
    final container = await newTestContainer(
      initialPrefs: {'bnood.account.selection': 'personal'},
      officeContext: const AuthOfficePayload(
        offices: [
          OfficeMembership(
            id: ownedId,
            name: 'Owned',
            readOnly: true,
            isOwner: true,
          ),
        ],
      ),
    );
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    final ctx = container.read(accountContextProvider);
    expect(ctx.isPersonal, isFalse);
    expect(ctx.officeId, ownedId);
    expect(ApiOfficeHeader.headerValue(), ownedId);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('bnood.account.selection'), ownedId);
  });

  test('logout clears persisted scope and office header', () async {
    final container = await newTestContainer(
      initialPrefs: {
        'bnood.account.selection': sampleOfficeId,
        'bnood.account.previous': 'personal',
      },
      officeContext: const AuthOfficePayload(
        offices: [
          OfficeMembership(
            id: sampleOfficeId,
            name: 'Office',
            readOnly: false,
            isOwner: false,
          ),
        ],
      ),
    );
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    expect(container.read(accountContextProvider).officeId, sampleOfficeId);

    await container.read(authControllerProvider.notifier).logout();
    await pumpEventQueue();

    expect(container.read(accountContextProvider).isPersonal, isTrue);
    expect(ApiOfficeHeader.headerValue(), isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('bnood.account.selection'), isFalse);
    expect(prefs.containsKey('bnood.account.previous'), isFalse);
  });

  test('selectPersonal clears office header', () async {
    final container = await newTestContainer();
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

class _AuthWithOffice extends AuthController {
  _AuthWithOffice(this.officeContext);

  final AuthOfficePayload officeContext;

  @override
  AuthState build() {
    return AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: const User(id: 'u-owner', phone: '01000000000', name: 'Owner'),
      officeContext: officeContext,
    );
  }

  @override
  Future<AuthApiException?> logout() async {
    state = const AuthState(
      bootstrapStatus: AuthBootstrapStatus.unauthenticated,
    );
    return null;
  }
}