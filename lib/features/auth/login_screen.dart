import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import 'auth_controller.dart';
import 'auth_form_ui.dart';
import 'auth_form_utils.dart';
import 'auth_login_outcome.dart';
import 'auth_messages.dart';
import 'auth_paths.dart';
import 'widgets/auth_flow_scaffold.dart';

Future<void> _submitLogin(BuildContext context, WidgetRef ref) async {
  final fields = ref.read(loginFormFieldsProvider);
  final ui = ref.read(authFormUiProvider(AuthFormId.login).notifier);
  final formId = AuthFormId.login;

  ui.beginAttempt();
  if (fields.formKey.currentState?.validate() != true) return;
  if (ref.read(authFormUiProvider(formId)).loading) return;
  ui.setLoading(true);
  final outcome = await ref
      .read(authControllerProvider.notifier)
      .login(phone: fields.phone.text.trim(), password: fields.password.text);
  if (!context.mounted) return;

  switch (outcome) {
    case LoginOutcomeAuthenticated():
      ui.clearLoading();
      final user = ref.read(authControllerProvider).user!;
      context.go(authenticatedHomeFor(user));
    case LoginOutcomeRegistrationChallenge():
      ui.clearLoading();
      context.push(AuthPaths.registerVerify);
    case LoginOutcomeFailed(:final error):
      final l10n = AppLocalizations.of(context);
      ui.fail(error);
      final state = ref.read(authFormUiProvider(formId));
      if (state.errorFor('phone') == null && state.errorFor('password') == null) {
        AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
      }
  }
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(loginPhonePrefillInitProvider);
    final l10n = AppLocalizations.of(context);
    final fields = ref.watch(loginFormFieldsProvider);
    final ui = ref.watch(authFormUiProvider(AuthFormId.login));
    final loading = ui.loading;

    return AuthFlowScaffold(
      title: l10n.authLoginTitle,
      subtitle: l10n.authLoginSubtitle,
      alignment: AuthFlowAlignment.center,
      showLogo: true,
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
              textInputAction: TextInputAction.done,
              validator: (v) => validateRequired(l10n, v),
            ),
            AppSize.spaceMD.gap,
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppButton.text(
                text: l10n.authForgotPassword,
                onPressed: loading ? null : () => context.push(AuthPaths.forgotPassword),
              ),
            ),
            AppSize.spaceMD.gap,
            AppButton.primary(
              text: l10n.authLoginAction,
              isLoading: loading,
              onPressed: loading ? null : () => _submitLogin(context, ref),
            ),
            AppSize.spaceSM.gap,
            Builder(
              builder: (context) {
                return Center(
                  child: AppButton.text(
                    foregroundColor: context.colors.primary,
                    text: l10n.authRegisterLink,
                    onPressed: loading ? null : () => context.push(AuthPaths.register),
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
