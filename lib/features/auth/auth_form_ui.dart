import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../core/api/auth_api_exception.dart';
import 'auth_controller.dart';
import 'auth_messages.dart';

enum AuthFormId {
  login,
  register,
  forgotPassword,
  forgotVerify,
  resetPassword,
  changePassword,
  completeProfile,
}

class AuthFormUiState {
  const AuthFormUiState({
    this.attempted = false,
    this.loading = false,
    this.fieldErrors = const {},
  });

  final bool attempted;
  final bool loading;
  final Map<String, String?> fieldErrors;

  String? errorFor(String field) => fieldErrors[field];

  AuthFormUiState copyWith({
    bool? attempted,
    bool? loading,
    Map<String, String?>? fieldErrors,
    bool clearFieldErrors = false,
  }) {
    return AuthFormUiState(
      attempted: attempted ?? this.attempted,
      loading: loading ?? this.loading,
      fieldErrors: clearFieldErrors ? {} : (fieldErrors ?? this.fieldErrors),
    );
  }
}

class AuthFormUiNotifier extends AutoDisposeFamilyNotifier<AuthFormUiState, AuthFormId> {
  @override
  AuthFormUiState build(AuthFormId arg) => const AuthFormUiState();

  void beginAttempt() {
    state = state.copyWith(attempted: true, clearFieldErrors: true);
  }

  void setLoading(bool loading) {
    state = state.copyWith(loading: loading);
  }

  void fail(AuthApiException error) {
    final errors = <String, String?>{};
    final raw = error.fieldErrors;
    if (raw != null) {
      for (final entry in raw.entries) {
        if (entry.value.isNotEmpty) {
          errors[entry.key] = entry.value.first;
        }
      }
    }
    state = state.copyWith(loading: false, attempted: true, fieldErrors: errors);
  }

  void clearLoading() {
    state = state.copyWith(loading: false);
  }
}

final authFormUiProvider =
    NotifierProvider.autoDispose.family<AuthFormUiNotifier, AuthFormUiState, AuthFormId>(
  AuthFormUiNotifier.new,
);

class LoginFormFields {
  LoginFormFields()
      : formKey = GlobalKey<FormState>(),
        phone = TextEditingController(),
        password = TextEditingController();

  final GlobalKey<FormState> formKey;
  final TextEditingController phone;
  final TextEditingController password;

  void dispose() {
    phone.dispose();
    password.dispose();
  }
}

final loginFormFieldsProvider = Provider.autoDispose<LoginFormFields>((ref) {
  final fields = LoginFormFields();
  ref.onDispose(fields.dispose);
  return fields;
});

class LoginPhonePrefillNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setPhone(String phone) {
    state = phone.trim();
  }

  /// Reads and clears the pending prefill so it is applied only once.
  String? takePhone() {
    final value = state;
    state = null;
    return value;
  }
}

final loginPhonePrefillProvider =
    NotifierProvider<LoginPhonePrefillNotifier, String?>(LoginPhonePrefillNotifier.new);

final loginPhonePrefillInitProvider = Provider.autoDispose<void>((ref) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final phone = ref.read(loginPhonePrefillProvider.notifier).takePhone();
    if (phone != null && phone.isNotEmpty) {
      final fields = ref.read(loginFormFieldsProvider);
      fields.phone.text = phone;
      fields.password.clear();
    }
  });
});

class RegisterFormFields {
  RegisterFormFields()
      : formKey = GlobalKey<FormState>(),
        phone = TextEditingController(),
        password = TextEditingController(),
        confirm = TextEditingController();

  final GlobalKey<FormState> formKey;
  final TextEditingController phone;
  final TextEditingController password;
  final TextEditingController confirm;

  void dispose() {
    phone.dispose();
    password.dispose();
    confirm.dispose();
  }
}

final registerFormFieldsProvider = Provider.autoDispose<RegisterFormFields>((ref) {
  final fields = RegisterFormFields();
  ref.onDispose(fields.dispose);
  return fields;
});

class ForgotPasswordFormFields {
  ForgotPasswordFormFields()
      : formKey = GlobalKey<FormState>(),
        phone = TextEditingController();

  final GlobalKey<FormState> formKey;
  final TextEditingController phone;

  void dispose() {
    phone.dispose();
  }
}

final forgotPasswordFormFieldsProvider = Provider.autoDispose<ForgotPasswordFormFields>((ref) {
  final fields = ForgotPasswordFormFields();
  ref.onDispose(fields.dispose);
  return fields;
});

class OtpFormFields {
  OtpFormFields()
      : formKey = GlobalKey<FormState>(),
        pinController = PinInputController();

  final GlobalKey<FormState> formKey;
  final PinInputController pinController;

  void dispose() {
    pinController.dispose();
  }
}

final forgotVerifyFormFieldsProvider = Provider.autoDispose<OtpFormFields>((ref) {
  final fields = OtpFormFields();
  ref.onDispose(fields.dispose);
  return fields;
});

final registerVerifyFormFieldsProvider = Provider.autoDispose<OtpFormFields>((ref) {
  final fields = OtpFormFields();
  ref.onDispose(fields.dispose);
  return fields;
});

class ResetPasswordFormFields {
  ResetPasswordFormFields()
      : formKey = GlobalKey<FormState>(),
        password = TextEditingController(),
        confirm = TextEditingController();

  final GlobalKey<FormState> formKey;
  final TextEditingController password;
  final TextEditingController confirm;

  void dispose() {
    password.dispose();
    confirm.dispose();
  }
}

final resetPasswordFormFieldsProvider = Provider.autoDispose<ResetPasswordFormFields>((ref) {
  final fields = ResetPasswordFormFields();
  ref.onDispose(fields.dispose);
  return fields;
});

class ChangePasswordFormFields {
  ChangePasswordFormFields()
      : formKey = GlobalKey<FormState>(),
        current = TextEditingController(),
        password = TextEditingController(),
        confirm = TextEditingController();

  final GlobalKey<FormState> formKey;
  final TextEditingController current;
  final TextEditingController password;
  final TextEditingController confirm;

  void dispose() {
    current.dispose();
    password.dispose();
    confirm.dispose();
  }
}

final changePasswordFormFieldsProvider = Provider.autoDispose<ChangePasswordFormFields>((ref) {
  final fields = ChangePasswordFormFields();
  ref.onDispose(fields.dispose);
  return fields;
});

class CompleteProfileFormFields {
  CompleteProfileFormFields()
      : formKey = GlobalKey<FormState>(),
        name = TextEditingController();

  final GlobalKey<FormState> formKey;
  final TextEditingController name;

  void dispose() {
    name.dispose();
  }
}

final completeProfileFormFieldsProvider = Provider.autoDispose<CompleteProfileFormFields>((ref) {
  final fields = CompleteProfileFormFields();
  ref.onDispose(fields.dispose);
  return fields;
});

class RegisterVerifyUiState {
  const RegisterVerifyUiState({
    this.attempted = false,
    this.loading = false,
    this.resendLoading = false,
    this.resendSeconds = 0,
    this.codeError,
  });

  final bool attempted;
  final bool loading;
  final bool resendLoading;
  final int resendSeconds;
  final String? codeError;

  RegisterVerifyUiState copyWith({
    bool? attempted,
    bool? loading,
    bool? resendLoading,
    int? resendSeconds,
    String? codeError,
    bool clearCodeError = false,
  }) {
    return RegisterVerifyUiState(
      attempted: attempted ?? this.attempted,
      loading: loading ?? this.loading,
      resendLoading: resendLoading ?? this.resendLoading,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      codeError: clearCodeError ? null : (codeError ?? this.codeError),
    );
  }
}

class RegisterVerifyUiNotifier extends AutoDisposeNotifier<RegisterVerifyUiState> {
  Timer? _resendTimer;

  @override
  RegisterVerifyUiState build() {
    ref.onDispose(() => _resendTimer?.cancel());
    return const RegisterVerifyUiState();
  }

  void beginAttempt() {
    state = state.copyWith(attempted: true, clearCodeError: true);
  }

  void clearCodeError() {
    state = state.copyWith(clearCodeError: true);
  }

  void setLoading(bool loading) {
    state = state.copyWith(loading: loading);
  }

  void setResendLoading(bool resendLoading) {
    state = state.copyWith(resendLoading: resendLoading);
  }

  void failCode(AuthApiException error) {
    state = state.copyWith(
      loading: false,
      attempted: true,
      codeError: fieldErrorFor(error, 'code'),
    );
  }

  void clearLoading() {
    state = state.copyWith(loading: false);
  }

  void syncFromPending() {
    final pending = ref.read(authControllerProvider).pendingRegistration;
    final seconds = pending?.resendAfterSeconds ?? 0;
    state = state.copyWith(resendSeconds: seconds);
    _startResendCountdown();
  }

  void startCountdownFromPending() {
    final pending = ref.read(authControllerProvider).pendingRegistration;
    final seconds = pending?.resendAfterSeconds ?? 0;
    state = state.copyWith(resendSeconds: seconds);
    _startResendCountdown();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    if (state.resendSeconds <= 0) return;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.resendSeconds <= 1) {
        t.cancel();
        state = state.copyWith(resendSeconds: 0);
      } else {
        state = state.copyWith(resendSeconds: state.resendSeconds - 1);
      }
    });
  }
}

final registerVerifyUiProvider =
    NotifierProvider.autoDispose<RegisterVerifyUiNotifier, RegisterVerifyUiState>(
  RegisterVerifyUiNotifier.new,
);

final registerVerifyInitProvider = Provider.autoDispose<void>((ref) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(registerVerifyUiProvider.notifier).syncFromPending();
  });
});

final authBootstrapInitProvider = Provider.autoDispose<void>((ref) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(authControllerProvider.notifier).ensureBootstrap();
  });
});
