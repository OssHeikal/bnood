import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'sentry_config.dart';

/// go_router observers for Sentry navigation performance transactions.
List<NavigatorObserver> sentryNavigationObservers() {
  if (!SentryConfig.isEnabled) return const [];
  return [SentryNavigatorObserver()];
}