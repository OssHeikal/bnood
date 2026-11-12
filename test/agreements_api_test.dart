import 'package:bnood/core/agreements/app_agreement_record.dart';
import 'package:bnood/core/api/agreements_api.dart';
import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

AgreementsApi _agreementsApi(Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return AgreementsApi(dio: dio);
}

void main() {
  group('AppAgreement', () {
    test('null amount is distinct from zero', () {
      final unset = AppAgreement.fromDataJson({
        'id': '01J',
        'client_id': 'c1',
        'provider_id': 'p1',
        'amount': null,
      });
      final zero = AppAgreement.fromDataJson({
        'id': '01J',
        'client_id': 'c1',
        'provider_id': 'p1',
        'amount': 0,
      });
      expect(unset.amountPiastres, isNull);
      expect(zero.amountPiastres, 0);
      expect(unset.hasAgreedAmount, isFalse);
      expect(zero.hasAgreedAmount, isTrue);
    });
  });

  group('AgreementsApi', () {
    test('create omits amount when not agreed', () async {
      late Object? body;
      final api = _agreementsApi((options) async {
        body = options.data;
        return jsonResponse(
          '{"success":true,"data":{"id":"01JA","client_id":"c1","provider_id":"p1"}}',
        );
      });
      await api.createAgreement(
        clientId: 'c1',
        providerId: 'p1',
        omitAmount: true,
      );
      expect((body! as Map).containsKey('amount'), isFalse);
      api.close();
    });

    test('patch always sends amount key', () async {
      late Object? body;
      final api = _agreementsApi((options) async {
        body = options.data;
        return jsonResponse(
          '{"success":true,"data":{"id":"01JA","client_id":"c1","provider_id":"p1","amount":null}}',
        );
      });
      await api.patchAgreement(id: '01JA', amountMajor: null);
      expect((body! as Map)['amount'], isNull);
      api.close();
    });

    test('create and patch send major EGP amount not minor integer', () async {
      final bodies = <Object?>[];
      final api = _agreementsApi((options) async {
        bodies.add(options.data);
        return jsonResponse(
          '{"success":true,"data":{"id":"01JA","client_id":"c1","provider_id":"p1","amount":1000000}}',
        );
      });
      await api.createAgreement(
        clientId: 'c1',
        providerId: 'p1',
        amountMajor: 1000000,
      );
      await api.patchAgreement(id: '01JA', amountMajor: 800000);
      expect((bodies[0]! as Map)['amount'], 1000000);
      expect((bodies[1]! as Map)['amount'], 800000);
      api.close();
    });

    test('already_linked maps to exception flag', () async {
      final api = _agreementsApi(
        (_) async => jsonResponse(
          '{"success":false,"message":"linked","code":"already_linked"}',
          statusCode: 422,
        ),
      );
      expect(
        () => api.createAgreement(clientId: 'c1', providerId: 'p1', omitAmount: true),
        throwsA(isA<AuthApiException>().having((e) => e.isAlreadyLinked, 'linked', isTrue)),
      );
      api.close();
    });
  });
}
