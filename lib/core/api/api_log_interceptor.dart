import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_log_redactor.dart';
import 'auth_api_exception.dart';

typedef ApiLogWriter = void Function(String message, {Object? error, StackTrace? stackTrace});

class ApiLogInterceptor extends Interceptor {
  ApiLogInterceptor({ApiLogWriter? write, bool? verbose})
    : _write = write ?? _defaultWrite,
      _verbose = verbose ?? kDebugMode;

  static const _startedAt = 'startedAt';
  static const _rule = '─';
  static const _dioValidateStatusHint = 'This exception was thrown because the response has a status code';

  final ApiLogWriter _write;
  final bool _verbose;

  static void _defaultWrite(String message, {Object? error, StackTrace? stackTrace}) {
    log(message, name: 'ApiClient');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAt] = DateTime.now().millisecondsSinceEpoch;
    _write(_outgoing(options));
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _write(_incoming(response.requestOptions, statusCode: response.statusCode, responseData: response.data));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _write(
      _incoming(err.requestOptions, statusCode: err.response?.statusCode, responseData: err.response?.data, err: err),
    );
    handler.next(err);
  }

  String _outgoing(RequestOptions options) {
    final method = options.method.toUpperCase();
    final header = 'API ► $method';
    final lines = <String>[_target(options, includeQuery: _verbose), if (_verbose) ..._requestDetailLines(options)];
    return _block(header, lines);
  }

  String _incoming(RequestOptions options, {int? statusCode, Object? responseData, DioException? err}) {
    final method = options.method.toUpperCase();
    final duration = _durationLabel(_durationMs(options));

    if (err == null) {
      final status = _statusPhrase(statusCode);
      final icon = _statusIcon(statusCode);
      final header = 'API $icon $method · $status · $duration';
      final lines = <String>[
        _target(options, includeQuery: _verbose),
        if (_verbose) ..._responseDetailLines(responseData),
      ];
      return _block(header, lines);
    }

    final status = _statusPhrase(statusCode);
    final header = 'API ✕ $method · $status · $duration';
    final effectiveResponse = responseData ?? err.response?.data;
    final lines = <String>[
      _target(options, includeQuery: _verbose),
      ..._errorDetailLines(err, effectiveResponse),
      ..._responseDetailLines(effectiveResponse),
      if (_verbose) ..._requestDetailLines(options, skipUrl: true),
    ];
    return _block(header, lines, widen: true);
  }

  List<String> _requestDetailLines(RequestOptions options, {bool skipUrl = false}) {
    if (!skipUrl && options.queryParameters.isNotEmpty) {
      // URL line already includes query when verbose.
    }
    return [
      'Headers:',
      ..._indentBlock(_formatHeaders(options.headers)),
      'Body:',
      ..._indentBlock(_formatPayload(options.data)),
    ];
  }

  List<String> _responseDetailLines(Object? responseData, {bool skipLabelIfEmpty = false}) {
    if (responseData == null && skipLabelIfEmpty) {
      return const [];
    }
    return ['Response body:', ..._indentBlock(_formatPayload(responseData))];
  }

  String _formatHeaders(Map<String, dynamic> headers) {
    final sanitized = ApiLogRedactor.headers(headers);
    final sortedKeys = sanitized.keys.toList()..sort();
    if (sortedKeys.isEmpty) {
      return '(none)';
    }
    return sortedKeys.map((key) => '$key: ${sanitized[key]}').join('\n');
  }

  String _formatPayload(Object? data) {
    if (data == null) {
      return '(empty)';
    }
    final redacted = ApiLogRedactor.body(data);
    if (redacted is Map || redacted is List) {
      return const JsonEncoder.withIndent('  ').convert(redacted);
    }
    return redacted.toString();
  }

  List<String> _indentBlock(String text) {
    return text.split('\n').map((line) => '  $line').toList(growable: false);
  }

  String _block(String header, List<String> bodyLines, {bool widen = false}) {
    final flatLines = <String>[];
    for (final line in bodyLines) {
      flatLines.addAll(line.split('\n'));
    }
    final width = _contentWidth(header, flatLines, widen: widen);
    final top = '┌─ $header ${_padRule(header, width)}';
    final body = flatLines.map((line) => '│ $line').join('\n');
    final bottom = '└${_rule * (width + 1)}';
    return '$top\n$body\n$bottom';
  }

  int _contentWidth(String header, List<String> bodyLines, {bool widen = false}) {
    if (bodyLines.isEmpty) {
      return 36;
    }
    final longest = [header.length + 4, ...bodyLines.map((line) => line.length + 2)].reduce((a, b) => a > b ? a : b);
    final max = widen ? 120 : 100;
    return longest.clamp(36, max);
  }

  String _padRule(String header, int width) {
    final used = header.length + 4;
    final count = (width - used).clamp(0, 48);
    return _rule * count;
  }

  int _durationMs(RequestOptions options) {
    final started = options.extra[_startedAt];
    if (started is! int) {
      return 0;
    }
    return DateTime.now().millisecondsSinceEpoch - started;
  }

  String _durationLabel(int ms) {
    if (ms <= 0) {
      return '—';
    }
    final slow = ms >= 2000 ? ' (slow)' : '';
    return '${ms}ms$slow';
  }

  String _statusIcon(int? code) {
    if (code == null) {
      return '·';
    }
    if (code >= 200 && code < 300) {
      return '✓';
    }
    if (code >= 400 && code < 500) {
      return '!';
    }
    if (code >= 500) {
      return '✕';
    }
    return '·';
  }

  String _statusPhrase(int? code) {
    if (code == null) {
      return 'no response';
    }
    return switch (code) {
      200 => '200 OK',
      201 => '201 Created',
      204 => '204 No Content',
      400 => '400 Bad Request',
      401 => '401 Unauthorized',
      403 => '403 Forbidden',
      404 => '404 Not Found',
      409 => '409 Conflict',
      422 => '422 Unprocessable',
      >= 500 && < 600 => '$code Server Error',
      >= 400 && < 500 => '$code Client Error',
      >= 200 && < 300 => '$code Success',
      _ => '$code',
    };
  }

  List<String> _errorDetailLines(DioException err, Object? responseData) {
    final lines = <String>['↳ ${err.type.name}'];

    final summary = _apiEnvelopeSummary(responseData);
    if (summary != null) {
      lines.add('↳ $summary');
    }

    final validation = _apiValidationSummary(responseData);
    if (validation != null) {
      lines.addAll(validation.map((line) => '↳ $line'));
    }

    final cause = err.error;
    if (cause is AuthApiException) {
      lines.add('↳ mapped · ${cause.statusCode} · code=${cause.code ?? '—'} · ${cause.message}');
      final mappedFields = cause.fieldErrors;
      if (mappedFields != null && mappedFields.isNotEmpty) {
        lines.add('↳ mapped fields: ${_formatFieldErrors(mappedFields)}');
      }
    } else if (cause != null && summary == null) {
      lines.add('↳ ${cause.runtimeType}: $cause');
    }

    final message = err.message;
    if (message != null &&
        message.isNotEmpty &&
        !message.startsWith(_dioValidateStatusHint) &&
        cause is! AuthApiException) {
      lines.add('↳ $message');
    }

    return lines;
  }

  String? _apiEnvelopeSummary(Object? data) {
    if (data is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(data);
    final success = map['success'];
    final message = map['message']?.toString();
    final code = map['code']?.toString();
    final parts = <String>[];
    if (success is bool) {
      parts.add('success=$success');
    }
    if (code != null && code.isNotEmpty) {
      parts.add('code=$code');
    }
    if (message != null && message.isNotEmpty) {
      parts.add('message=$message');
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' · ');
  }

  List<String>? _apiValidationSummary(Object? data) {
    if (data is! Map) {
      return null;
    }
    final errors = data['errors'];
    if (errors is! Map) {
      return null;
    }
    final redacted = ApiLogRedactor.body(errors);
    if (redacted is! Map) {
      return null;
    }
    final out = <String>[];
    final map = Map<String, dynamic>.from(redacted);
    final keys = map.keys.toList()..sort();
    for (final key in keys) {
      final value = map[key];
      if (value is List) {
        out.add('$key: ${value.map((e) => e.toString()).join('; ')}');
      } else {
        out.add('$key: $value');
      }
    }
    if (out.isEmpty) {
      return null;
    }
    return out;
  }

  String _formatFieldErrors(Map<String, List<String>> fieldErrors) {
    final keys = fieldErrors.keys.toList()..sort();
    return keys.map((key) => '$key: ${fieldErrors[key]!.join('; ')}').join(' · ');
  }

  String _target(RequestOptions options, {bool includeQuery = false}) {
    final uri = options.uri;
    final port = uri.hasPort ? ':${uri.port}' : '';
    final base = '${uri.scheme}://${uri.host}$port${uri.path}';
    if (!includeQuery || uri.query.isEmpty) {
      return base;
    }
    final query = ApiLogRedactor.queryParameters(Map<String, dynamic>.from(options.queryParameters));
    final encoded = query.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent('${e.value}')}')
        .join('&');
    return '$base?$encoded';
  }
}
