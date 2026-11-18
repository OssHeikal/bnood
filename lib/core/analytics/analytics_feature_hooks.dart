import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_event.dart';
import 'analytics_track.dart';

/// After a successful remote client create API response.
void trackClientCreatedAfterApi(WidgetRef ref) {
  trackAnalyticsEventFromWidget(ref, const ClientCreated(source: ClientCreatedSource.remote));
}

/// After registration profile name is saved (complete-profile screen only).
void trackSignupCompletedAfterRegistration(WidgetRef ref) {
  trackAnalyticsEventFromWidget(ref, const SignupCompleted());
}

/// After the client statement share sheet closes successfully for this export.
void trackClientStatementShared(WidgetRef ref) {
  trackAnalyticsEventFromWidget(ref, const StatementShared());
}
