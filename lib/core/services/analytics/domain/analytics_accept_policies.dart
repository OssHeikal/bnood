import 'analytics_event.dart';

bool firebaseAcceptPolicy(AnalyticsEvent event) {
  return switch (event) {
    ClientCreated() => true,
    StatementShared() => true,
    ScreenViewed() => true,
    SubscriptionStarted() => true,
    SubscriptionRenewed() => true,
    SignupCompleted() => false,
  };
}

bool appsFlyerAcceptPolicy(AnalyticsEvent event) {
  return switch (event) {
    SignupCompleted() => true,
    SubscriptionStarted() => true,
    SubscriptionRenewed() => true,
    ClientCreated() => false,
    StatementShared() => false,
    ScreenViewed() => false,
  };
}
