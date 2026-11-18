import 'analytics_event.dart';

/// AppsFlyer standard event name for registration complete.
const String appsFlyerCompleteRegistrationEvent = 'af_complete_registration';

bool appsFlyerShouldEmitEvent(AnalyticsEvent event) => event is SignupCompleted;