import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/buttons/app_button.dart';
import 'auth_otp_pin_field.dart';

/// Registration / recovery OTP body: phone label, PIN field, verify + optional resend in scroll.
class AuthOtpChallengeForm extends StatelessWidget {
  const AuthOtpChallengeForm({
    super.key,
    required this.formKey,
    required this.pinController,
    required this.phone,
    required this.autovalidateMode,
    required this.loading,
    required this.verifyLabel,
    required this.onVerify,
    this.codeError,
    this.codeErrorOf,
    this.resendSeconds = 0,
    this.resendLoading = false,
    this.onResend,
    this.resendLabel,
    this.resendWaitLabel,
  });

  final GlobalKey<FormState> formKey;
  final PinInputController pinController;
  final String phone;
  final AutovalidateMode autovalidateMode;
  final bool loading;
  final String verifyLabel;
  final VoidCallback onVerify;
  final String? codeError;

  /// Live read of [codeError]. Submit clears the notifier before [FormState.validate].
  final String? Function()? codeErrorOf;
  final int resendSeconds;
  final bool resendLoading;
  final VoidCallback? onResend;
  final String? resendLabel;
  final String Function(int seconds)? resendWaitLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resend = onResend;
    final resendBlocked = resendSeconds > 0 || resendLoading || loading;
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSize.spaceLG.gap,
          AuthOtpPinField(
            pinController: pinController,
            enabled: !loading,
            autovalidateMode: autovalidateMode,
            serverFieldError: codeError,
            readServerError: codeErrorOf ?? () => codeError,
            onCompleted: loading ? null : (_) => onVerify(),
          ),
          AppSize.spaceXL.gap,
          AppButton.primary(text: verifyLabel, isLoading: loading, onPressed: loading ? null : onVerify),
          if (resend != null) ...[
            AppSize.spaceSM.gap,
            AppButton.text(
              text: resendSeconds > 0
                  ? (resendWaitLabel?.call(resendSeconds) ?? l10n.authResendWait(resendSeconds))
                  : (resendLabel ?? l10n.authResendCode),
              onPressed: resendBlocked
                  ? null
                  : () {
                      pinController.clear();
                      formKey.currentState?.reset();
                      pinController.requestFocus();
                      resend();
                    },
            ),
          ],
        ],
      ),
    );
  }
}
