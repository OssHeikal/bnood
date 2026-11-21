/// Firebase Analytics user-property value length limit.
const int gaUserPropertyMaxLength = 36;

abstract final class GaUserProperties {
  static const accountName = 'account_name';
  static const accountPhone = 'account_phone';
}

String? truncateGaUserProperty(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.length <= gaUserPropertyMaxLength) return trimmed;
  return trimmed.substring(0, gaUserPropertyMaxLength);
}
