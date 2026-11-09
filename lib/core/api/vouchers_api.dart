import 'package:dio/dio.dart';

import '../vouchers/app_voucher_receipt.dart';
import '../vouchers/app_voucher_record.dart';
import 'api_response_parser.dart';
import 'app_dio.dart';
import 'auth_api_exception.dart';
import 'auth_interceptor.dart';
import '../storage/session_store.dart';

class VouchersApi {
  VouchersApi({
    Dio? dio,
    SessionStore? sessionStore,
  })  : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
        _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _prefix = '/v1/vouchers';

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

  Future<VouchersListPage> listVouchers({
    String? q,
    int page = 1,
    int perPage = 50,
  }) =>
      _list(_prefix, q: q, page: page, perPage: perPage);

  Future<VouchersListPage> listClientVouchers({
    required String clientId,
    String? q,
    int page = 1,
    int perPage = 50,
  }) =>
      _list('/v1/clients/$clientId/vouchers', q: q, page: page, perPage: perPage);

  Future<VouchersListPage> listProviderVouchers({
    required String providerId,
    String? q,
    int page = 1,
    int perPage = 50,
  }) =>
      _list('/v1/providers/$providerId/vouchers', q: q, page: page, perPage: perPage);

  Future<VouchersListPage> _list(
    String path, {
    String? q,
    required int page,
    required int perPage,
  }) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {
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
      final items = data.map((e) => AppVoucher.fromDataJson(e as Map<String, dynamic>)).toList();
      return VouchersListPage(
        items: items,
        page: (meta['page'] as num?)?.toInt() ?? page,
        perPage: (meta['per_page'] as num?)?.toInt() ?? perPage,
        total: (meta['total'] as num?)?.toInt() ?? items.length,
      );
    });
  }

  Future<AppVoucher> getVoucher(String id) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/$id',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppVoucher.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<AppVoucher> createVoucher({
    required String clientId,
    required String type,
    required int amountMinor,
    required String voucherDate,
    required String method,
    String? description,
    String? itemId,
    String? providerId,
    String? expenseClassification,
  }) {
    return _guard(() async {
      final body = <String, dynamic>{
        'client_id': clientId,
        'type': type,
        'amount': amountMinor,
        'date': voucherDate,
        'payment_method': method,
        if (description != null && description.isNotEmpty) 'description': description,
        if (type == 'spend') ...{
          'item_id': itemId,
          'expense_classification': expenseClassification,
          if (providerId != null) 'provider_id': providerId,
        },
      };
      final response = await _dio.post<Map<String, dynamic>>(
        _prefix,
        data: body,
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppVoucher.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<AppVoucher> patchVoucher({
    required String id,
    int? amountMinor,
    String? voucherDate,
    String? method,
    String? description,
    bool clearDescription = false,
    String? itemId,
    String? providerId,
    String? expenseClassification,
    bool clearProvider = false,
  }) {
    return _guard(() async {
      final body = <String, dynamic>{
        if (amountMinor != null) 'amount': amountMinor,
        if (voucherDate != null) 'date': voucherDate,
        if (method != null) 'payment_method': method,
        if (clearDescription) 'description': null,
        if (description != null) 'description': description,
        if (itemId != null) 'item_id': itemId,
        if (expenseClassification != null) 'expense_classification': expenseClassification,
      };
      if (clearProvider) {
        body['provider_id'] = null;
      } else if (providerId != null) {
        body['provider_id'] = providerId;
      }
      final response = await _dio.patch<Map<String, dynamic>>(
        '$_prefix/$id',
        data: body,
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppVoucher.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<void> deleteVoucher(String id) {
    return _guard(() async {
      final response = await _dio.delete<Map<String, dynamic>>(
        '$_prefix/$id',
        options: Options(extra: _authenticatedExtra),
      );
      ApiResponseParser.expectSuccess(response);
    });
  }

  Future<List<AppVoucherReceipt>> listVoucherReceipts(String voucherId) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/$voucherId/receipts',
        options: Options(extra: _authenticatedExtra),
      );
      final json = ApiResponseParser.decodeJson(response);
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300 || json['success'] != true) {
        throw ApiResponseParser.fromFailure(response, json);
      }
      final data = json['data'];
      if (data is! List) return const <AppVoucherReceipt>[];
      return data.map((e) => AppVoucherReceipt.fromDataJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<AppVoucherReceipt> uploadVoucherReceipt({
    required String voucherId,
    required String filePath,
    required String filename,
  }) {
    return _guard(() async {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: filename),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/$voucherId/receipts',
        data: formData,
        options: Options(
          extra: _authenticatedExtra,
          contentType: 'multipart/form-data',
        ),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppVoucherReceipt.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<List<int>> downloadReceiptBytes(String receiptId) {
    return _guard(() async {
      final response = await _dio.get<List<int>>(
        '/v1/receipts/$receiptId',
        options: Options(
          extra: _authenticatedExtra,
          responseType: ResponseType.bytes,
        ),
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw AuthApiException(statusCode: statusCode, message: 'Receipt download failed');
      }
      return response.data ?? const [];
    });
  }

  Future<void> deleteReceipt(String receiptId) {
    return _guard(() async {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/v1/receipts/$receiptId',
        options: Options(extra: _authenticatedExtra),
      );
      ApiResponseParser.expectSuccess(response);
    });
  }
}
