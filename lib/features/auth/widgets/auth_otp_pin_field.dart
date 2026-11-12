import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../auth_form_utils.dart';
import '../auth_otp.dart';

/// Shared OTP PIN field (pin_code_fields 9.x) — LTR digits, autofill.
class AuthOtpPinField extends StatelessWidget {
  const AuthOtpPinField({
    super.key,
    required this.pinController,
    required this.enabled,
    required this.autovalidateMode,
    this.serverFieldError,
    this.readServerError,
    this.onCompleted,
  });

  final PinInputController pinController;
  final bool enabled;
  final AutovalidateMode autovalidateMode;
  final String? serverFieldError;

  /// Live read so a cleared error is visible to [validator] before the next build.
  final String? Function()? readServerError;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const length = authOtpPinCellCount;
          const spacing = AppSize.spaceSM;
          final cellSide = (constraints.maxWidth - spacing * (length - 1)) / length;
          final theme = MaterialPinTheme(
            shape: MaterialPinShape.outlined,
            cellSize: Size.square(cellSide),
            spacing: spacing,
            borderRadius: BorderRadius.circular(AppSize.radiusMD),
            borderWidth: 1,
            focusedBorderWidth: 1.5,
            borderColor: colors.outlineSubtle,
            focusedBorderColor: colors.primary,
            errorColor: colors.error,
            fillColor: colors.surface,
            focusedFillColor: colors.surface,
            textStyle: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: colors.onSurface),
            showCursor: true,
            cursorColor: colors.primary,
            enableErrorShake: true,
          );

          return MaterialPinFormField(
            length: length,
            pinController: pinController,
            enabled: enabled,
            autovalidateMode: autovalidateMode,
            enableAutofill: true,
            autofillHints: const [AutofillHints.oneTimeCode],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            autoFocus: true,
            theme: theme,
            validator: (value) {
              final formMessage = validateVerificationCode(l10n, value);
              if (formMessage != null) return formMessage;
              final server = readServerError?.call() ?? serverFieldError;
              if (server != null) return server;
              return null;
            },
            onChanged: (_) {
              if (serverFieldError != null) {
                pinController.clearError();
              }
            },
            onCompleted: onCompleted,
          );
        },
      ),
    );
  }
}
