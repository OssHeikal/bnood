abstract interface class AppsFlyerGateway {
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  Future<void> setCustomerUserId(String? customerId);

  Future<void> setUserData(Map<String, String> data);
}