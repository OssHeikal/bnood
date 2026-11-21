abstract interface class FirebaseAnalyticsGateway {
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  });

  Future<void> logScreenView({required String screenName});

  Future<void> setUserId(String? id);

  Future<void> setUserProperty({required String name, String? value});
}
