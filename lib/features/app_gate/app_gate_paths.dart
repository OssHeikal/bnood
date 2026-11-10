abstract final class AppGatePaths {
  static const maintenance = '/gate/maintenance';
  static const forceUpdate = '/gate/force-update';
  static const optionalUpdate = '/gate/optional-update';
}

bool isAppGateLocation(String location) {
  return location == AppGatePaths.maintenance ||
      location == AppGatePaths.forceUpdate ||
      location == AppGatePaths.optionalUpdate;
}

bool isPublicContentPageLocation(String location) {
  return location.startsWith('/pages/');
}
