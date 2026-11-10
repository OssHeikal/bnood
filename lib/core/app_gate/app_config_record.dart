enum AppGateStatus {
  ok,
  optionalUpdate,
  forceUpdate,
  maintenance,
}

/// Parsed `GET /v1/app/config` payload with client-side priority guard.
class AppConfigData {
  const AppConfigData({
    required this.status,
    this.message = '',
    this.storeUrl,
    this.maintenanceMessage = '',
    this.currentVersion,
    this.minVersion,
    this.latestVersion,
  });

  final AppGateStatus status;
  final String message;
  final String? storeUrl;
  final String maintenanceMessage;
  final String? currentVersion;
  final String? minVersion;
  final String? latestVersion;

  static AppConfigData failOpen() => const AppConfigData(status: AppGateStatus.ok);

  factory AppConfigData.fromDataJson(Map<String, dynamic>? json) {
    if (json == null) return failOpen();
    final maintenance = json['maintenance'];
    final maintenanceEnabled = maintenance is Map<String, dynamic> && maintenance['enabled'] == true;
    final maintenanceMessage =
        maintenance is Map<String, dynamic> ? (maintenance['message'] as String? ?? '') : '';
    final status = resolveEffectiveStatus(
      maintenanceEnabled: maintenanceEnabled,
      apiStatus: json['status'] as String?,
    );
    return AppConfigData(
      status: status,
      message: json['message'] as String? ?? '',
      storeUrl: json['store_url'] as String?,
      maintenanceMessage: maintenanceMessage,
      currentVersion: json['current_version'] as String?,
      minVersion: json['min_version'] as String?,
      latestVersion: json['latest_version'] as String?,
    );
  }

  /// maintenance > force > optional > ok
  static AppGateStatus resolveEffectiveStatus({
    required bool maintenanceEnabled,
    required String? apiStatus,
  }) {
    if (maintenanceEnabled) return AppGateStatus.maintenance;
    return switch (apiStatus) {
      'maintenance' => AppGateStatus.maintenance,
      'force_update' => AppGateStatus.forceUpdate,
      'optional_update' => AppGateStatus.optionalUpdate,
      'ok' => AppGateStatus.ok,
      _ => AppGateStatus.ok,
    };
  }

  String messageForDisplay(String Function() maintenanceFallback, String Function() forceFallback, String Function() optionalFallback) {
    final trimmed = message.trim();
    if (trimmed.isNotEmpty) return trimmed;
    if (status == AppGateStatus.maintenance) {
      final m = maintenanceMessage.trim();
      if (m.isNotEmpty) return m;
      return maintenanceFallback();
    }
    return switch (status) {
      AppGateStatus.forceUpdate => forceFallback(),
      AppGateStatus.optionalUpdate => optionalFallback(),
      _ => '',
    };
  }
}

/// Compares semantic versions `major.minor.patch` (build metadata ignored).
int compareSemanticVersions(String a, String b) {
  List<int> parts(String v) {
    final core = v.split('+').first;
    return core.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  }

  final ap = parts(a);
  final bp = parts(b);
  final len = ap.length > bp.length ? ap.length : bp.length;
  for (var i = 0; i < len; i++) {
    final av = i < ap.length ? ap[i] : 0;
    final bv = i < bp.length ? bp[i] : 0;
    if (av != bv) return av.compareTo(bv);
  }
  return 0;
}
