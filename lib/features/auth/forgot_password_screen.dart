import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import 'auth_controller.dart';
import 'auth_form_ui.dart';
import 'auth_form_utils.dart';
import 'auth_messages.dart';
import 'auth_paths.dart';
import 'widgets/auth_flow_scaffold.dart';

Future<void> _submitForgotPassword(BuildContext context, WidgetRef ref) async {
  final fields = ref.read(forgotPasswordFormFieldsProvider);
  final ui = ref.read(authFormUiProvider(AuthFormId.forgotPassword).notifier);
  const formId = AuthFormId.forgotPassword;

  ui.beginAttempt();
  if (fields.formKey.currentState?.validate() != true) return;
  if (ref.read(authFormUiProvider(formId)).loading) return;
  ui.setLoading(true);
  final error =
      await ref.read(authControllerProvider.notifier).forgotPassword(fields.phone.text.trim());
  if (!context.mounted) return;
  if (error == null) {
    ui.clearLoading();
    context.push(AuthPaths.forgotVerify);
    return;
  }
  final l10n = AppLocalizations.of(context);
  ui.fail(error);
  if (ref.read(authFormUiProvider(formId)).errorFor('phone') == null) {
    AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
  }
}

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fields = ref.watch(forgotPasswordFormFieldsProvider);
    final ui = ref.watch(authFormUiProvider(AuthFormId.forgotPassword));
    final loading = ui.loading;

    return AuthFlowScaffold(
      title: l10n.authForgotPasswordTitle,
      subtitle: l10n.authForgotPasswordSubtitle,
      alignment: AuthFlowAlignment.start,
      child: Form(
        key: fields.formKey,
        autovalidateMode:
            ui.attempted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: fields.phone,
              label: l10n.authPhone,
              placeholder: l10n.clientPhoneHint,
              type: AppInputType.phone,
              ltrValue: true,
              fieldHeight: AppSize.fieldHeightComfortable,
              errorMessage: ui.errorFor('phone'),
              textInputAction: TextInputAction.done,
              validator: (v) => validateEgyptPhone(l10n, v),
            ),
            AppSize.spaceXL.gap,
            AppButton.primary(
              text: l10n.authContinue,
              isLoading: loading,
              onPressed: loading ? null : () => _submitForgotPassword(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
