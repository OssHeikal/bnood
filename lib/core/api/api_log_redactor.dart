/// Redacts sensitive values before API traffic is logged.
abstract final class ApiLogRedactor {
  static const _sensitiveHeaderKeys = {
    'authorization',
    'cookie',
  };

  static const _sensitiveBodyKeys = {
    'password',
    'password_confirmation',
    'current_password',
    'token',
    'reset_token',
    'code',
  };

  static Map<String, dynamic> headers(Map<String, dynamic> headers) {
    final out = <String, dynamic>{};
    headers.forEach((key, value) {
      if (_sensitiveHeaderKeys.contains(key.toLowerCase())) {
        out[key] = _redacted;
      } else {
        out[key] = value;
      }
    });
    return out;
  }

  static Object? body(Object? data) {
    if (data is List<int>) {
      return data;
    }
    if (data is Map) {
      return _redactMap(Map<String, dynamic>.from(data));
    }
    if (data is List) {
      return data.map(body).toList();
    }
    return data;
  }

  static Map<String, dynamic> queryParameters(Map<String, dynamic> query) {
    return _redactMap(query);
  }

  static Map<String, dynamic> _redactMap(Map<String, dynamic> map) {
    final out = <String, dynamic>{};
    map.forEach((key, value) {
      if (_sensitiveBodyKeys.contains(key.toLowerCase())) {
        out[key] = _redacted;
      } else if (value is Map) {
        out[key] = _redactMap(Map<String, dynamic>.from(value));
      } else if (value is List<int>) {
        out[key] = value;
      } else if (value is List) {
        out[key] = value.map(body).toList();
      } else {
        out[key] = value;
      }
    });
    return out;
  }

  static const _redacted = '***';
}
