import 'package:dio/dio.dart';

import 'package:bnood/core/network/api/api_response_parser.dart';
import 'package:bnood/core/network/api/app_dio.dart';
import 'package:bnood/core/network/api/auth_api_exception.dart';
import 'package:bnood/core/network/api/auth_interceptor.dart';
import 'package:bnood/core/data/storage/session_store.dart';

import '../../clients/data/client_list_archive_filter.dart';
import 'office_project_record.dart';

class OfficeProjectsApi {
  OfficeProjectsApi({Dio? dio, SessionStore? sessionStore})
    : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
      _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _prefix = '/v1/projects';

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
    } catch (e, stackTrace) {
      throw ApiResponseParser.fromUnexpected(e, stackTrace);
    }
  }

  String _statusParam(ClientListArchiveFilter filter) => switch (filter) {
    ClientListArchiveFilter.all => 'all',
    ClientListArchiveFilter.active => 'active',
    ClientListArchiveFilter.archived => 'archived',
  };

  Future<Map<String, dynamic>> getProject(String projectId) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/$projectId',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData<Map<String, dynamic>>(
        response,
        (json) => json ?? const {},
      );
    });
  }

  Future<ProjectsListPage> listProjects({
    required ClientListArchiveFilter status,
    String? q,
    int page = 1,
    int perPage = 50,
    String sort = 'name',
    String order = 'asc',
  }) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        _prefix,
        queryParameters: {
          'status': _statusParam(status),
          if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
          'page': page,
          'per_page': perPage,
          'sort': sort,
          'order': order,
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
        throw AuthApiException(
          statusCode: statusCode,
          message: 'Unexpected response shape',
        );
      }
      final meta = json['meta'] as Map<String, dynamic>? ?? const {};
      final items = data
          .map(
            (e) => OfficeProjectRecord.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      final currentPage =
          (meta['current_page'] as num?)?.toInt() ??
          (meta['page'] as num?)?.toInt() ??
          page;
      final resolvedPerPage =
          (meta['per_page'] as num?)?.toInt() ?? perPage;
      final total = (meta['total'] as num?)?.toInt() ?? items.length;
      return ProjectsListPage(
        items: items,
        page: currentPage,
        perPage: resolvedPerPage,
        total: total,
      );
    });
  }
}