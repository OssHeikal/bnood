import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscriber_auth_api.dart';

final subscriberAuthApiProvider = Provider<SubscriberAuthApi>((ref) {
  final api = SubscriberAuthApi();
  ref.onDispose(api.close);
  return api;
});
