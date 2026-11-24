import 'package:bnood/app/app_root_restart.dart';
import 'package:bnood/core/account/account_context_providers.dart';
import 'package:bnood/core/account/auth_office_payload.dart';
import 'package:bnood/core/account/office_membership.dart';
import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/core/data/prefs/app_settings_store.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _officeId = '01J9Z8XQ8K9M2N3P4R5S6T7V8W';

class _SequencedHomeTotals extends HomeTotalsNotifier {
  _SequencedHomeTotals(this._values);

  final List<HomeTotals> _values;
  var _index = 0;

  @override
  Future<HomeTotals> fetch() async {
    final value = _values[_index.clamp(0, _values.length - 1)];
    if (_index < _values.length - 1) {
      _index++;
    }
    return value;
  }
}

class _AuthMember extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: User(id: 'u1', phone: '01000000001', name: 'Member'),
      officeContext: AuthOfficePayload(
        offices: [
          OfficeMembership(
            id: _officeId,
            name: 'Office A',
            readOnly: false,
            isOwner: false,
          ),
        ],
      ),
    );
  }
}

Future<ProviderContainer> newContainer() async {
  SharedPreferences.setMockInitialValues({});
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
      authControllerProvider.overrideWith(_AuthMember.new),
      homeTotalsProvider.overrideWith(
        () => _SequencedHomeTotals([
          const HomeTotals(receivedPiastres: 100, spentPiastres: 10),
          const HomeTotals(receivedPiastres: 200, spentPiastres: 20),
        ]),
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AppRootRestart.resetForTest();
    ApiOfficeHeader.syncOfficeId(null);
  });

  test('account switch requests root restart', () async {
    var restarts = 0;
    AppRootRestart.bind(() => restarts++);

    final container = await newContainer();
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(_officeId);
    await pumpEventQueue();

    expect(restarts, 1);
    expect(AppRootRestart.debugRequestCount, 1);
    expect(ApiOfficeHeader.headerValue(), _officeId);
  });

  test('selecting the same account does not restart', () async {
    var restarts = 0;
    AppRootRestart.bind(() => restarts++);

    final container = await newContainer();
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(_officeId);
    await pumpEventQueue();
    restarts = 0;
    final countBefore = AppRootRestart.debugRequestCount;

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(_officeId);
    await pumpEventQueue();

    expect(restarts, 0);
    expect(AppRootRestart.debugRequestCount, countBefore);
  });
}