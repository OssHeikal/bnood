/// Office tenant header for authenticated API calls.
///
/// Updated from [accountContextProvider] in [BnoodApp]; read on each Dio
/// request when the call is marked authenticated.
abstract final class ApiOfficeHeader {
  static const headerName = 'X-Office-Id';

  static String? Function() _readOfficeId = () => null;

  static void bindOfficeIdReader(String? Function() readOfficeId) {
    _readOfficeId = readOfficeId;
  }

  static void syncOfficeId(String? officeId) {
    final trimmed = officeId?.trim();
    _readOfficeId = () =>
        trimmed != null && trimmed.isNotEmpty ? trimmed : null;
  }

  static String? headerValue() {
    final id = _readOfficeId();
    if (id == null || id.isEmpty) return null;
    return id;
  }
}