import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../clients/client_api_record.dart';
import '../clients/client_statement_pdf.dart';
import '../clients/client_statement_record.dart';
import '../repositories/bnood_repository.dart';
import 'api_response_parser.dart';
import 'app_dio.dart';
import 'auth_api_exception.dart';
import 'auth_interceptor.dart';
import '../storage/session_store.dart';

class ClientsApi {
  ClientsApi({
    Dio? dio,
    SessionStore? sessionStore,
  })  : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
        _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _prefix = '/v1/clients';

  Map<String, dynamic> get _authenticatedExtra => {
        AuthInterceptor.authenticatedExtraKey: true,
      };

  void close({bool force = false}) {
    if (_ownsDio) {
      _dio.close(force: force);
    }
  }

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on AuthApiException {
      rethrow;
    } on DioException catch (e) {
      if (e.error is AuthApiException) {
        throw e.error as AuthApiException;
      }
      throw ApiResponseParser.fromDio(e);
    } catch (e) {
      throw ApiResponseParser.transport(e);
    }
  }

  String _statusParam(ClientListArchiveFilter filter) => switch (filter) {
        ClientListArchiveFilter.all => 'all',
        ClientListArchiveFilter.active => 'active',
        ClientListArchiveFilter.archived => 'archived',
      };

  Future<ClientsListPage> listClients({
    required ClientListArchiveFilter status,
    String? q,
    int page = 1,
    int perPage = 50,
  }) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        _prefix,
        queryParameters: {
          'status': _statusParam(status),
          if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
          'page': page,
          'per_page': perPage,
        },
        options: Options(extra: _authenticatedExtra),
      );
      final json = ApiResponseParser.decodeJson(response);
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300 || json['success'] != true) {
        throw ApiResponseParser.fromFailure(response, json);
      }
      final data = json['data'];
      if (data is! List) {
        throw AuthApiException(statusCode: statusCode, message: 'Unexpected response shape');
      }
      final meta = json['meta'] as Map<String, dynamic>? ?? const {};
      final items = data
          .map((e) => ClientApiRecord.fromDataJson(e as Map<String, dynamic>))
          .toList();
      return ClientsListPage(
        items: items,
        page: (meta['page'] as num?)?.toInt() ?? page,
        perPage: (meta['per_page'] as num?)?.toInt() ?? perPage,
        total: (meta['total'] as num?)?.toInt() ?? items.length,
      );
    });
  }

  Future<ClientApiRecord> getClient(String id) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/$id',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => ClientApiRecord.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<ClientApiRecord> createClient({
    required String name,
    String? phone,
    bool confirmDuplicateName = false,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        _prefix,
        data: {
          'name': name,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (confirmDuplicateName) 'confirm_duplicate_name': true,
        },
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => ClientApiRecord.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<ClientApiRecord> updateClient({
    required String id,
    String? name,
    String? phone,
    bool confirmDuplicateName = false,
    bool clearPhone = false,
  }) {
    return _guard(() async {
      final body = <String, dynamic>{
        if (name != null) 'name': name,
        if (confirmDuplicateName) 'confirm_duplicate_name': true,
      };
      if (clearPhone) {
        body['phone'] = '';
      } else if (phone != null) {
        body['phone'] = phone;
      }
      final response = await _dio.patch<Map<String, dynamic>>(
        '$_prefix/$id',
        data: body,
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => ClientApiRecord.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<ClientApiRecord> archiveClient(String id) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/$id/archive',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => ClientApiRecord.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<void> deleteClient(String id) {
    return _guard(() async {
      final response = await _dio.delete<Map<String, dynamic>>(
        '$_prefix/$id',
        options: Options(extra: _authenticatedExtra),
      );
      ApiResponseParser.expectSuccess(response);
    });
  }

  Future<AppClientStatement> getClientStatement({
    required String clientId,
    required String from,
    required String to,
  }) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/$clientId/statement',
        queryParameters: {'from': from, 'to': to},
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppClientStatement.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<AppClientItemSpend> getClientItemSpend(String clientId) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/$clientId/item-spend',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppClientItemSpend.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<ClientStatementPdf> downloadClientStatementPdf({
    required String clientId,
    required String from,
    required String to,
  }) {
    return _guard(() async {
      final response = await _dio.get<List<int>>(
        '$_prefix/$clientId/statement.pdf',
        queryParameters: {'from': from, 'to': to},
        options: Options(
          extra: _authenticatedExtra,
          responseType: ResponseType.bytes,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final statusCode = response.statusCode ?? 0;
      final contentType = response.headers.value(Headers.contentTypeHeader) ?? '';
      if (statusCode >= 200 &&
          statusCode < 300 &&
          contentType.toLowerCase().contains('application/pdf')) {
        final bytes = Uint8List.fromList(response.data ?? const []);
        final fileName = clientStatementPdfFileNameFromHeader(
              response.headers.value('content-disposition'),
            ) ??
            'statement.pdf';
        return ClientStatementPdf(bytes: bytes, fileName: fileName);
      }
      try {
        final json = ApiResponseParser.decodeJson(response);
        throw ApiResponseParser.fromFailure(response, json);
      } catch (e) {
        if (e is AuthApiException) rethrow;
        throw AuthApiException(
          statusCode: statusCode,
          message: 'Statement PDF download failed',
        );
      }
    });
  }
}
