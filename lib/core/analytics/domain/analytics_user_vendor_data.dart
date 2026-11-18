import '../firebase/ga_user_properties.dart';
import 'analytics_user.dart';

/// Shared name/phone payload for vendor user properties (GA + AppsFlyer).
Map<String, String> vendorUserDataPayload(AnalyticsUser user) {
  final map = <String, String>{};
  final name = truncateGaUserProperty(user.name);
  final phone = truncateGaUserProperty(user.phone);
  if (name != null) map[GaUserProperties.accountName] = name;
  if (phone != null) map[GaUserProperties.accountPhone] = phone;
  return map;
}