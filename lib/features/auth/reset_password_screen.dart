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
import 'auth_form_utils.dart';
import 'auth_messages.dart';
import 'auth_paths.dart';
import 'widgets/auth_flow_scaffold.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _attemptedSubmit = false;
  var _loading = false;
  String? _passwordError;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _attemptedSubmit = true;
      _passwordError = null;
    });
    if (_formKey.currentState?.validate() != true) return;
    if (_loading) return;
    setState(() => _loading = true);
    final error = await ref.read(authControllerProvider.notifier).resetPassword(
          password: _password.text,
          passwordConfirmation: _confirm.text,
        );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (error == null) {
      AppToaster.show(l10n.authPasswordResetSuccess, kind: ToastKind.success);
      context.go(AuthPaths.login);
      return;
    }
    setState(() {
      _loading = false;
      _passwordError = fieldErrorFor(error, 'password');
    });
    if (_passwordError == null) {
      AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasToken = ref.watch(authControllerProvider).resetToken != null;
    if (!hasToken) {
      return AuthFlowScaffold(
        title: l10n.authResetPasswordTitle,
        body: Text(l10n.authFlowExpired),
        footer: AppButton.primary(
          text: l10n.authLoginAction,
          onPressed: () => context.go(AuthPaths.login),
        ),
      );
    }

    return AuthFlowScaffold(
      title: l10n.authResetPasswordTitle,
      body: Form(
        key: _formKey,
        autovalidateMode:
            _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _password,
              label: l10n.authNewPassword,
              type: AppInputType.password,
              fieldHeight: AppSize.fieldHeightComfortable,
              errorMessage: _passwordError,
              textInputAction: TextInputAction.next,
              validator: (v) => validatePassword(l10n, v),
            ),
            AppSize.spaceMD.gap,
            CustomTextField(
              controller: _confirm,
              label: l10n.authPasswordConfirm,
              type: AppInputType.password,
              fieldHeight: AppSize.fieldHeightComfortable,
              textInputAction: TextInputAction.done,
              validator: (v) => validatePasswordConfirmation(l10n, v, _password.text),
            ),
          ],
        ),
      ),
      footer: AppButton.primary(
        text: l10n.authResetPasswordAction,
        isLoading: _loading,
        onPressed: _loading ? null : _submit,
      ),
    );
  }
}
