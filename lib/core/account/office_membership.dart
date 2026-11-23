class OfficeMembership {
  const OfficeMembership({
    required this.id,
    required this.name,
    required this.readOnly,
    this.status = 'active',
    this.dashboardUrl,
    this.isOwner = false,
    this.permissionKeys,
  });

  final String id;
  final String name;
  final bool readOnly;
  final String status;
  final String? dashboardUrl;

  /// From `/auth/me` → `offices[].role.is_owner`.
  final bool isOwner;

  /// Granted office permission keys when the API exposes them (`permission_keys`).
  final List<String>? permissionKeys;

  bool get isReadOnly => readOnly || status == 'read_only';

  factory OfficeMembership.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] as String?)?.trim() ?? 'active';
    final readOnlyFlag = json['read_only'] == true;
    final roleRaw = json['role'];
    var isOwner = json['is_owner'] == true;
    if (roleRaw is Map) {
      isOwner = roleRaw['is_owner'] == true || isOwner;
    }
    List<String>? permissionKeys;
    final rawKeys = json['permission_keys'] ?? json['permissions'];
    if (rawKeys is List) {
      permissionKeys = rawKeys.whereType<String>().toList(growable: false);
    }
    return OfficeMembership(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim() ?? '',
      readOnly: readOnlyFlag || status == 'read_only',
      status: status,
      dashboardUrl: json['dashboard_url']?.toString(),
      isOwner: isOwner,
      permissionKeys: permissionKeys,
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
          dashboardUrl == other.dashboardUrl &&
          isOwner == other.isOwner &&
          _listEquals(permissionKeys, other.permissionKeys);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    readOnly,
    status,
    dashboardUrl,
    isOwner,
    permissionKeys == null ? null : Object.hashAll(permissionKeys!),
  );
}

bool _listEquals(List<String>? a, List<String>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}