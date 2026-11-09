import 'package:bnood/app/app_splash_routing.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('appSplashDestinationFor routes unauthenticated to login', () {
    const auth = AuthState(
      bootstrapStatus: AuthBootstrapStatus.unauthenticated,
      bootstrapStarted: true,
    );
    expect(appSplashDestinationFor(auth), AuthPaths.login);
  });

  test('appSplashDestinationFor routes authenticated user to clients', () {
    const auth = AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      bootstrapStarted: true,
      user: User(id: 'u', phone: '+2010', name: 'Eng'),
    );
    expect(appSplashDestinationFor(auth), '/clients');
  });
}
