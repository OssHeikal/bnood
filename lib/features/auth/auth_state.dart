import 'models/subscriber_user.dart';

enum AuthBootstrapStatus {
  idle,
  bootstrapping,
  unauthenticated,
  authenticated,
  bootstrapNetworkError,
}

class PendingRegistration {
  const PendingRegistration({
    required this.registrationId,
    required this.phone,
    required this.resendAfterSeconds,
  });

  final String registrationId;
  final String phone;
  final int resendAfterSeconds;
}

class PendingRecovery {
  const PendingRecovery({
    required this.recoveryId,
    required this.phone,
    required this.resendAfterSeconds,
  });

  final String recoveryId;
  final String phone;
  final int resendAfterSeconds;
}

class AuthState {
  const AuthState({
    this.bootstrapStatus = AuthBootstrapStatus.idle,
    this.user,
    this.pendingRegistration,
    this.pendingRecovery,
    this.resetToken,
    this.resetTokenExpiresIn,
    this.bootstrapStarted = false,
  });

  final AuthBootstrapStatus bootstrapStatus;
  final SubscriberUser? user;
  final PendingRegistration? pendingRegistration;
  final PendingRecovery? pendingRecovery;
  final String? resetToken;
  final int? resetTokenExpiresIn;
  final bool bootstrapStarted;

  bool get isAuthenticated =>
      bootstrapStatus == AuthBootstrapStatus.authenticated && user != null;

  bool get isBootstrapping =>
      bootstrapStatus == AuthBootstrapStatus.bootstrapping ||
      (bootstrapStatus == AuthBootstrapStatus.idle && bootstrapStarted);

  AuthState copyWith({
    AuthBootstrapStatus? bootstrapStatus,
    SubscriberUser? user,
    bool clearUser = false,
    PendingRegistration? pendingRegistration,
    bool clearPendingRegistration = false,
    PendingRecovery? pendingRecovery,
    bool clearPendingRecovery = false,
    String? resetToken,
    bool clearResetToken = false,
    int? resetTokenExpiresIn,
    bool clearResetExpires = false,
    bool? bootstrapStarted,
  }) {
    return AuthState(
      bootstrapStatus: bootstrapStatus ?? this.bootstrapStatus,
      user: clearUser ? null : (user ?? this.user),
      pendingRegistration: clearPendingRegistration
          ? null
          : (pendingRegistration ?? this.pendingRegistration),
      pendingRecovery:
          clearPendingRecovery ? null : (pendingRecovery ?? this.pendingRecovery),
      resetToken: clearResetToken ? null : (resetToken ?? this.resetToken),
      resetTokenExpiresIn: clearResetExpires
          ? null
          : (resetTokenExpiresIn ?? this.resetTokenExpiresIn),
      bootstrapStarted: bootstrapStarted ?? this.bootstrapStarted,
    );
  }
}
