import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh();

  void onAuthStateChanged() {
    notifyListeners();
  }
}

final authRouterRefreshProvider = Provider<AuthRouterRefresh>((ref) {
  final refresh = AuthRouterRefresh();
  ref.listen(authControllerProvider, (_, _) => refresh.onAuthStateChanged());
  ref.onDispose(refresh.dispose);
  return refresh;
});
