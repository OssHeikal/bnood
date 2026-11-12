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
import 'widgets/auth_flow_scaffold.dart';

Future<void> _submitChangePassword(BuildContext context, WidgetRef ref) async {
  final fields = ref.read(changePasswordFormFieldsProvider);
  final ui = ref.read(authFormUiProvider(AuthFormId.changePassword).notifier);
  const formId = AuthFormId.changePassword;

  ui.beginAttempt();
  if (fields.formKey.currentState?.validate() != true) return;
  if (ref.read(authFormUiProvider(formId)).loading) return;
  ui.setLoading(true);
  final error = await ref.read(authControllerProvider.notifier).changePassword(
        currentPassword: fields.current.text,
        password: fields.password.text,
        passwordConfirmation: fields.confirm.text,
      );
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  if (error == null) {
    AppToaster.show(l10n.authPasswordChangedSuccess, kind: ToastKind.success);
    context.pop();
    return;
  }
  ui.fail(error);
  final state = ref.read(authFormUiProvider(formId));
  if (state.errorFor('current_password') == null && state.errorFor('password') == null) {
    AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
  }
}

class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fields = ref.watch(changePasswordFormFieldsProvider);
    final ui = ref.watch(authFormUiProvider(AuthFormId.changePassword));
    final loading = ui.loading;

    return AuthFlowScaffold(
      title: l10n.authChangePassword,
      alignment: AuthFlowAlignment.start,
      child: Form(
        key: fields.formKey,
        autovalidateMode:
            ui.attempted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: fields.current,
              label: l10n.authCurrentPassword,
              type: AppInputType.password,
              fieldHeight: AppSize.fieldHeightComfortable,
              errorMessage: ui.errorFor('current_password'),
              textInputAction: TextInputAction.next,
              validator: (v) => validateRequired(l10n, v),
            ),
            AppSize.spaceMD.gap,
            CustomTextField(
              controller: fields.password,
              label: l10n.authNewPassword,
              type: AppInputType.password,
              fieldHeight: AppSize.fieldHeightComfortable,
              errorMessage: ui.errorFor('password'),
              textInputAction: TextInputAction.next,
              validator: (v) => validatePassword(l10n, v),
            ),
            AppSize.spaceMD.gap,
            CustomTextField(
              controller: fields.confirm,
              label: l10n.authPasswordConfirm,
              type: AppInputType.password,
              fieldHeight: AppSize.fieldHeightComfortable,
              textInputAction: TextInputAction.done,
              validator: (v) => validatePasswordConfirmation(l10n, v, fields.password.text),
            ),
            AppSize.spaceXL.gap,
            AppButton.primary(
              text: l10n.save,
              isLoading: loading,
              onPressed: loading ? null : () => _submitChangePassword(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
