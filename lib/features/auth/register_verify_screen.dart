import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/utils/extensions/bidi_isolate.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/buttons/app_button.dart';
import 'auth_controller.dart';
import 'auth_form_ui.dart';
import 'auth_messages.dart';
import 'auth_paths.dart';
import 'widgets/auth_flow_scaffold.dart';
import 'widgets/auth_otp_challenge_form.dart';

Future<void> _submitRegisterVerify(BuildContext context, WidgetRef ref) async {
  final fields = ref.read(registerVerifyFormFieldsProvider);
  final ui = ref.read(registerVerifyUiProvider.notifier);
  final uiState = ref.read(registerVerifyUiProvider);

  ui.beginAttempt();
  if (fields.formKey.currentState?.validate() != true) {
    fields.pinController.triggerError();
    return;
  }
  if (uiState.loading) return;
  ui.setLoading(true);
  final code = fields.pinController.text.trim();
  final error = await ref.read(authControllerProvider.notifier).verifyRegistration(code);
  if (!context.mounted) return;
  if (error == null) {
    final user = ref.read(authControllerProvider).user!;
    context.go(authenticatedHomeFor(user));
    return;
  }
  final l10n = AppLocalizations.of(context);
  ui.failCode(error);
  final codeError = ref.read(registerVerifyUiProvider).codeError;
  if (codeError != null) {
    fields.pinController.triggerError();
  } else {
    AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
  }
}

Future<void> _resendRegisterVerify(BuildContext context, WidgetRef ref) async {
  final ui = ref.read(registerVerifyUiProvider.notifier);
  final uiState = ref.read(registerVerifyUiProvider);
  if (uiState.resendSeconds > 0 || uiState.resendLoading) return;
  ui.clearCodeError();
  ui.setResendLoading(true);
  final error = await ref.read(authControllerProvider.notifier).resendRegistration();
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  ui.setResendLoading(false);
  if (error != null) {
    AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
    return;
  }
  ui.startCountdownFromPending();
}

class RegisterVerifyScreen extends ConsumerWidget {
  const RegisterVerifyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(registerVerifyInitProvider);
    final l10n = AppLocalizations.of(context);
    final pending = ref.watch(authControllerProvider).pendingRegistration;
    final fields = ref.watch(registerVerifyFormFieldsProvider);
    final ui = ref.watch(registerVerifyUiProvider);

    if (pending == null) {
      return AuthFlowScaffold(
        title: l10n.authVerificationTitle,
        alignment: AuthFlowAlignment.start,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.authFlowExpired),
            AppSize.spaceLG.gap,
            AppButton.primary(
              text: l10n.authRegisterTitle,
              onPressed: () => context.go(AuthPaths.register),
            ),
          ],
        ),
      );
    }

    final phoneDisplay = LtrIsolate.isolate(pending.phone);

    return AuthFlowScaffold(
      title: l10n.authVerificationTitle,
      subtitle: l10n.authVerificationDeliverySubtitle(phoneDisplay),
      alignment: AuthFlowAlignment.start,
      child: AuthOtpChallengeForm(
        formKey: fields.formKey,
        pinController: fields.pinController,
        phone: pending.phone,
        autovalidateMode:
            ui.attempted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        loading: ui.loading,
        verifyLabel: l10n.authVerifyAction,
        onVerify: () => _submitRegisterVerify(context, ref),
        codeError: ui.codeError,
        codeErrorOf: () => ref.read(registerVerifyUiProvider).codeError,
        resendSeconds: ui.resendSeconds,
        resendLoading: ui.resendLoading,
        onResend: () => _resendRegisterVerify(context, ref),
      ),
    );
  }
}
