import 'auth_api_exception.dart';

/// Reads Laravel-style `errors` from [AuthApiException] for inline form fields.
final class ApiFieldErrorLookup {
  const ApiFieldErrorLookup(this.error);

  final AuthApiException error;

  String? textFor(String fieldKey) {
    final messages = error.fieldErrors?[fieldKey];
    if (messages == null || messages.isEmpty) return null;
    final first = messages.first.trim();
    return first.isEmpty ? null : first;
  }

  /// Product copy (e.g. duplicate phone) wins over raw server text for [fieldKey].
  String? resolve(String fieldKey, {String? localizedOverride}) {
    if (localizedOverride != null) return localizedOverride;
    return textFor(fieldKey);
  }
}
