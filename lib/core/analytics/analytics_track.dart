import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_event.dart';
import 'analytics_providers.dart';

void trackAnalyticsEvent(Ref ref, AnalyticsEvent event) {
  unawaited(ref.read(analyticsServiceProvider).track(event));
}

void trackAnalyticsEventFromWidget(WidgetRef ref, AnalyticsEvent event) {
  unawaited(ref.read(analyticsServiceProvider).track(event));
}