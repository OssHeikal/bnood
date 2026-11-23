import 'office_membership.dart';

class AuthOfficePayload {
  const AuthOfficePayload({
    this.offices = const [],
    this.openDashboard = false,
    this.dashboardUrl,
  });

  final List<OfficeMembership> offices;
  final bool openDashboard;
  final String? dashboardUrl;

  bool get hasOffices => offices.isNotEmpty;

  factory AuthOfficePayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AuthOfficePayload();
    final rawOffices = json['offices'];
    final offices = rawOffices is List
        ? rawOffices
              .whereType<Map>()
              .map(
                (e) => OfficeMembership.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : const <OfficeMembership>[];
    return AuthOfficePayload(
      offices: offices,
      openDashboard: json['open_dashboard'] == true,
      dashboardUrl: json['dashboard_url']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthOfficePayload &&
          _listEquals(offices, other.offices) &&
          openDashboard == other.openDashboard &&
          dashboardUrl == other.dashboardUrl;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(offices),
    openDashboard,
    dashboardUrl,
  );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}