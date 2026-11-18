enum ClientCreatedSource {
  remote,
  local,
}

sealed class AnalyticsEvent {
  const AnalyticsEvent();

  String get name;

  /// Values are [String], [num], or [bool] only.
  Map<String, Object> get params;
}

final class SignupCompleted extends AnalyticsEvent {
  const SignupCompleted();

  @override
  String get name => 'signup_completed';

  @override
  Map<String, Object> get params => const {};
}

final class ClientCreated extends AnalyticsEvent {
  const ClientCreated({required this.source});

  final ClientCreatedSource source;

  @override
  String get name => 'client_created';

  @override
  Map<String, Object> get params => {'source': source.name};
}

final class StatementShared extends AnalyticsEvent {
  const StatementShared();

  @override
  String get name => 'statement_shared';

  @override
  Map<String, Object> get params => const {};
}

final class ScreenViewed extends AnalyticsEvent {
  const ScreenViewed({required this.screenName});

  final String screenName;

  @override
  String get name => 'screen_viewed';

  @override
  Map<String, Object> get params => {'screen_name': screenName};
}

final class SubscriptionStarted extends AnalyticsEvent {
  const SubscriptionStarted({
    required this.packageSlug,
    required this.revenue,
    required this.currency,
  });

  final String packageSlug;
  final num revenue;
  final String currency;

  @override
  String get name => 'subscription_started';

  @override
  Map<String, Object> get params => {
        'package_slug': packageSlug,
        'revenue': revenue,
        'currency': currency,
      };
}

final class SubscriptionRenewed extends AnalyticsEvent {
  const SubscriptionRenewed({
    required this.packageSlug,
    required this.revenue,
    required this.currency,
  });

  final String packageSlug;
  final num revenue;
  final String currency;

  @override
  String get name => 'subscription_renewed';

  @override
  Map<String, Object> get params => {
        'package_slug': packageSlug,
        'revenue': revenue,
        'currency': currency,
      };
}