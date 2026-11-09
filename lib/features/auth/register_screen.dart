import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import 'auth_controller.dart';
import 'auth_form_ui.dart';
import 'auth_form_utils.dart';
import 'auth_messages.dart';
import 'auth_paths.dart';
import 'widgets/auth_flow_scaffold.dart';

Future<void> _submitRegister(BuildContext context, WidgetRef ref) async {
  final fields = ref.read(registerFormFieldsProvider);
  final ui = ref.read(authFormUiProvider(AuthFormId.register).notifier);
  const formId = AuthFormId.register;

  ui.beginAttempt();
  if (fields.formKey.currentState?.validate() != true) return;
  if (ref.read(authFormUiProvider(formId)).loading) return;
  ui.setLoading(true);
  final error = await ref
      .read(authControllerProvider.notifier)
      .register(
        phone: fields.phone.text.trim(),
        password: fields.password.text,
        passwordConfirmation: fields.confirm.text,
      );
  if (!context.mounted) return;
  if (error == null) {
    ui.clearLoading();
    context.push(AuthPaths.registerVerify);
    return;
  }
  final l10n = AppLocalizations.of(context);
  if (error.isAccountExists) {
    ui.clearLoading();
    final answer = await AppDecision.show(
      context,
      title: l10n.authAccountExistsTitle,
      description: l10n.authAccountExistsMessage,
      confirmLabel: l10n.authAccountExistsLoginAction,
      cancelLabel: l10n.authAccountExistsAnotherPhoneAction,
    );
    if (!context.mounted) return;
    if (answer == OverlayAnswer.confirmed) {
      ref.read(loginPhonePrefillProvider.notifier).setPhone(fields.phone.text.trim());
      fields.password.clear();
      fields.confirm.clear();
      context.go(AuthPaths.login);
    }
    return;
  }
  ui.fail(error);
  final state = ref.read(authFormUiProvider(formId));
  if (state.errorFor('phone') == null && state.errorFor('password') == null) {
    AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
  }
}

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fields = ref.watch(registerFormFieldsProvider);
    final ui = ref.watch(authFormUiProvider(AuthFormId.register));
    final loading = ui.loading;

    return AuthFlowScaffold(
      title: l10n.authRegisterTitle,
      subtitle: l10n.authRegisterSubtitle,
      alignment: AuthFlowAlignment.start,
      child: Form(
        key: fields.formKey,
        autovalidateMode: ui.attempted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
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
              textInputAction: TextInputAction.next,
              validator: (v) => validateEgyptPhone(l10n, v),
            ),
            AppSize.spaceMD.gap,
            CustomTextField(
              controller: fields.password,
              label: l10n.authPassword,
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
              text: l10n.authCreateAccount,
              isLoading: loading,
              onPressed: loading ? null : () => _submitRegister(context, ref),
            ),
            AppSize.spaceSM.gap,
            Builder(
              builder: (context) {
                return Center(
                  child: AppButton.text(
                    foregroundColor: context.colors.primary,
                    text: l10n.authLoginLink,
                    onPressed: loading ? null : () => context.push(AuthPaths.login),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
