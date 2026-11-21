import 'package:flutter/widgets.dart';

/// Stable go_router path template from [Route.settings.name] (not ids).
String? analyticsScreenNameForRoute(Route<dynamic> route) {
  if (route is PopupRoute) return null;
  final name = route.settings.name?.trim();
  if (name == null || name.isEmpty) return null;
  if (name.startsWith('/')) return name;
  return '/$name';
}
