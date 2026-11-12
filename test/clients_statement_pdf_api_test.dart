import 'dart:typed_data';

import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/api/clients_api.dart';
import 'package:bnood/core/clients/client_statement_pdf.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

ClientsApi _clientsApi(Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return ClientsApi(dio: dio);
}

void main() {
  group('clientStatementPdfFileNameFromHeader', () {
    test('parses quoted filename', () {
      expect(
        clientStatementPdfFileNameFromHeader('inline; filename="statement-ahmed.pdf"'),
        'statement-ahmed.pdf',
      );
    });
  });

  group('ClientsApi statement pdf', () {
    test('download sends from and to and returns pdf bytes', () async {
      late Uri uri;
      final api = _clientsApi((options) async {
        uri = options.uri;
        expect(options.responseType, ResponseType.bytes);
        return pdfResponse(
          const [0x25, 0x50, 0x44, 0x46],
          contentDisposition: 'inline; filename="statement-client.pdf"',
        );
      });
      final pdf = await api.downloadClientStatementPdf(
        clientId: 'c1',
        from: '2026-09-15',
        to: '2026-11-09',
      );
      expect(uri.path, endsWith('/clients/c1/statement.pdf'));
      expect(uri.queryParameters['from'], '2026-09-15');
      expect(uri.queryParameters['to'], '2026-11-09');
      expect(pdf.fileName, 'statement-client.pdf');
      expect(pdf.bytes, Uint8List.fromList([0x25, 0x50, 0x44, 0x46]));
      api.close();
    });

    test('download omits from when null', () async {
      late Uri uri;
      final api = _clientsApi((options) async {
        uri = options.uri;
        return pdfResponse(const [0x25, 0x50, 0x44, 0x46]);
      });
      await api.downloadClientStatementPdf(clientId: 'c1', to: '2026-11-09');
      expect(uri.queryParameters.containsKey('from'), isFalse);
      expect(uri.queryParameters['to'], '2026-11-09');
      api.close();
    });

    test('422 maps to AuthApiException', () async {
      final api = _clientsApi(
        (_) async => jsonResponse(
          '{"success":false,"message":"Invalid period","code":"validation_error"}',
          statusCode: 422,
        ),
      );
      expect(
        () => api.downloadClientStatementPdf(
          clientId: 'c1',
          from: '2026-12-01',
          to: '2026-01-01',
        ),
        throwsA(isA<AuthApiException>().having((e) => e.statusCode, 'status', 422)),
      );
      api.close();
    });

    test('404 maps to not_found', () async {
      final api = _clientsApi(
        (_) async => jsonResponse(
          '{"success":false,"message":"missing","code":"not_found"}',
          statusCode: 404,
        ),
      );
      expect(
        () => api.downloadClientStatementPdf(clientId: 'c1', from: '2026-09-15', to: '2026-11-09'),
        throwsA(isA<AuthApiException>().having((e) => e.isNotFound, 'not_found', isTrue)),
      );
      api.close();
    });
  });
}
