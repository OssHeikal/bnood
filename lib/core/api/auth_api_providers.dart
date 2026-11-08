import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_api.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final api = AuthApi();
  ref.onDispose(api.close);
  return api;
});
