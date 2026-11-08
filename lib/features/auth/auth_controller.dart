import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/subscriber_api_exception.dart';
import '../../core/api/subscriber_auth_api.dart';
import '../../core/api/subscriber_auth_providers.dart';
import '../../core/storage/session_store.dart';
import 'auth_state.dart';
import 'models/subscriber_user.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  SessionStore get _store => ref.read(sessionStoreProvider);
  SubscriberAuthApi get _api => ref.read(subscriberAuthApiProvider);

  @override
  AuthState build() => const AuthState();

  Future<void> ensureBootstrap() async {
    if (state.bootstrapStarted) return;
    state = state.copyWith(bootstrapStarted: true);
    await bootstrapFromStoredSession();
  }

  Future<void> bootstrapFromStoredSession() async {
    state = state.copyWith(bootstrapStatus: AuthBootstrapStatus.bootstrapping);
    try {
      final token = await _store.readToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(
          bootstrapStatus: AuthBootstrapStatus.unauthenticated,
          clearUser: true,
        );
        return;
      }
      final user = await _api.me(token);
      state = state.copyWith(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: user,
      );
    } on SubscriberApiException catch (e) {
      if (e.isUnauthorized || e.isSessionExpired) {
        await _store.clearToken();
        state = state.copyWith(
          bootstrapStatus: AuthBootstrapStatus.unauthenticated,
          clearUser: true,
        );
        return;
      }
      if (e.isNetwork) {
        state = state.copyWith(
          bootstrapStatus: AuthBootstrapStatus.bootstrapNetworkError,
        );
        return;
      }
      state = state.copyWith(
        bootstrapStatus: AuthBootstrapStatus.unauthenticated,
        clearUser: true,
      );
    } catch (_) {
      state = state.copyWith(
        bootstrapStatus: AuthBootstrapStatus.bootstrapNetworkError,
      );
    }
  }

  Future<void> retryBootstrap() => bootstrapFromStoredSession();

  Future<SubscriberApiException?> register({
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final accepted = await _api.register(
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = state.copyWith(
        pendingRegistration: PendingRegistration(
          registrationId: accepted.registrationId,
          phone: phone,
          resendAfterSeconds: accepted.resendAfter,
        ),
        clearPendingRecovery: true,
        clearResetToken: true,
      );
      return null;
    } on SubscriberApiException catch (e) {
      return e;
    }
  }

  Future<SubscriberApiException?> resendRegistration() async {
    final pending = state.pendingRegistration;
    if (pending == null) return null;
    try {
      final accepted = await _api.resendRegistration(pending.registrationId);
      state = state.copyWith(
        pendingRegistration: PendingRegistration(
          registrationId: accepted.registrationId,
          phone: pending.phone,
          resendAfterSeconds: accepted.resendAfter,
        ),
      );
      return null;
    } on SubscriberApiException catch (e) {
      return e;
    }
  }

  Future<SubscriberApiException?> verifyRegistration(String code) async {
    final pending = state.pendingRegistration;
    if (pending == null) return null;
    try {
      final session = await _api.verifyRegistration(
        registrationId: pending.registrationId,
        code: code,
      );
      await _store.writeToken(session.token);
      state = state.copyWith(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: session.user,
        clearPendingRegistration: true,
      );
      return null;
    } on SubscriberApiException catch (e) {
      return e;
    }
  }

  Future<SubscriberApiException?> login({
    required String phone,
    required String password,
  }) async {
    try {
      final session = await _api.login(phone: phone, password: password);
      await _store.writeToken(session.token);
      state = state.copyWith(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: session.user,
      );
      return null;
    } on SubscriberApiException catch (e) {
      return e;
    }
  }

  Future<SubscriberApiException?> forgotPassword(String phone) async {
    try {
      final accepted = await _api.forgotPassword(phone);
      state = state.copyWith(
        pendingRecovery: PendingRecovery(
          recoveryId: accepted.recoveryId,
          phone: phone,
          resendAfterSeconds: accepted.resendAfter,
        ),
        clearPendingRegistration: true,
        clearResetToken: true,
      );
      return null;
    } on SubscriberApiException catch (e) {
      return e;
    }
  }

  Future<SubscriberApiException?> verifyForgotPassword(String code) async {
    final pending = state.pendingRecovery;
    if (pending == null) return null;
    try {
      final auth = await _api.verifyForgotPassword(
        recoveryId: pending.recoveryId,
        code: code,
      );
      state = state.copyWith(
        resetToken: auth.resetToken,
        resetTokenExpiresIn: auth.expiresIn,
      );
      return null;
    } on SubscriberApiException catch (e) {
      return e;
    }
  }

  Future<SubscriberApiException?> resetPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    final resetToken = state.resetToken;
    if (resetToken == null) return null;
    try {
      await _api.resetPassword(
        resetToken: resetToken,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = state.copyWith(
        clearResetToken: true,
        clearPendingRecovery: true,
        clearResetExpires: true,
      );
      return null;
    } on SubscriberApiException catch (e) {
      return e;
    }
  }

  Future<SubscriberApiException?> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final token = await _store.readToken();
    if (token == null || token.isEmpty) {
      return SubscriberApiException(
        statusCode: 401,
        message: 'No session',
        code: 'unauthorized',
      );
    }
    try {
      await _api.changePassword(
        bearer: token,
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return null;
    } on SubscriberApiException catch (e) {
      return e;
    }
  }

  Future<SubscriberApiException?> logout() async {
    final token = await _store.readToken();
    SubscriberApiException? failure;
    if (token != null && token.isNotEmpty) {
      try {
        await _api.logout(token);
      } on SubscriberApiException catch (e) {
        failure = e;
      }
    }
    await _store.clearToken();
    state = state.copyWith(
      bootstrapStatus: AuthBootstrapStatus.unauthenticated,
      clearUser: true,
      clearPendingRegistration: true,
      clearPendingRecovery: true,
      clearResetToken: true,
    );
    return failure;
  }

  void clearRecoveryFlow() {
    state = state.copyWith(
      clearPendingRecovery: true,
      clearResetToken: true,
      clearResetExpires: true,
    );
  }

  void clearRegistrationFlow() {
    state = state.copyWith(clearPendingRegistration: true);
  }

  /// Test override: mark session without hitting secure storage.
  void adoptSessionForTest(SubscriberUser user) {
    state = state.copyWith(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: user,
      bootstrapStarted: true,
    );
  }
}
