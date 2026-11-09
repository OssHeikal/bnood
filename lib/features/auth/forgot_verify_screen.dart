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

Future<void> _submitForgotVerify(BuildContext context, WidgetRef ref) async {
  final fields = ref.read(forgotVerifyFormFieldsProvider);
  final ui = ref.read(authFormUiProvider(AuthFormId.forgotVerify).notifier);
  const formId = AuthFormId.forgotVerify;

  ui.beginAttempt();
  if (fields.formKey.currentState?.validate() != true) {
    fields.pinController.triggerError();
    return;
  }
  if (ref.read(authFormUiProvider(formId)).loading) return;
  ui.setLoading(true);
  final code = fields.pinController.text.trim();
  final error = await ref.read(authControllerProvider.notifier).verifyForgotPassword(code);
  if (!context.mounted) return;
  if (error == null) {
    ui.clearLoading();
    context.push(AuthPaths.resetPassword);
    return;
  }
  final l10n = AppLocalizations.of(context);
  ui.fail(error);
  final codeError = ref.read(authFormUiProvider(formId)).errorFor('code');
  if (codeError != null) {
    fields.pinController.triggerError();
  } else {
    AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
  }
}

class ForgotVerifyScreen extends ConsumerWidget {
  const ForgotVerifyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pending = ref.watch(authControllerProvider).pendingRecovery;
    final fields = ref.watch(forgotVerifyFormFieldsProvider);
    final ui = ref.watch(authFormUiProvider(AuthFormId.forgotVerify));

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
              text: l10n.authForgotPasswordTitle,
              onPressed: () => context.go(AuthPaths.forgotPassword),
            ),
          ],
        ),
      );
    }

    final phoneDisplay = LtrIsolate.isolate(pending.phone);

    return AuthFlowScaffold(
      title: l10n.authVerificationTitle,
      subtitle: l10n.authRecoveryDeliverySubtitle(phoneDisplay),
      alignment: AuthFlowAlignment.start,
      child: AuthOtpChallengeForm(
        formKey: fields.formKey,
        pinController: fields.pinController,
        phone: pending.phone,
        autovalidateMode:
            ui.attempted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        loading: ui.loading,
        verifyLabel: l10n.authContinue,
        onVerify: () => _submitForgotVerify(context, ref),
        codeError: ui.errorFor('code'),
        codeErrorOf: () => ref.read(authFormUiProvider(AuthFormId.forgotVerify)).errorFor('code'),
      ),
    );
  }
}
