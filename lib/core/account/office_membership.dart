class OfficeMembership {
  const OfficeMembership({
    required this.id,
    required this.name,
    required this.readOnly,
    this.status = 'active',
    this.dashboardUrl,
  });

  final String id;
  final String name;
  final bool readOnly;
  final String status;
  final String? dashboardUrl;

  bool get isReadOnly => readOnly || status == 'read_only';

  factory OfficeMembership.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] as String?)?.trim() ?? 'active';
    final readOnlyFlag = json['read_only'] == true;
    return OfficeMembership(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim() ?? '',
      readOnly: readOnlyFlag || status == 'read_only',
      status: status,
      dashboardUrl: json['dashboard_url']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfficeMembership &&
          id == other.id &&
          name == other.name &&
          readOnly == other.readOnly &&
          status == other.status &&
          dashboardUrl == other.dashboardUrl;

  @override
  int get hashCode => Object.hash(id, name, readOnly, status, dashboardUrl);
}