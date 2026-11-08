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

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _attemptedSubmit = false;
  var _loading = false;
  String? _currentError;
  String? _passwordError;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _attemptedSubmit = true;
      _currentError = null;
      _passwordError = null;
    });
    if (_formKey.currentState?.validate() != true) return;
    if (_loading) return;
    setState(() => _loading = true);
    final error = await ref.read(authControllerProvider.notifier).changePassword(
          currentPassword: _current.text,
          password: _password.text,
          passwordConfirmation: _confirm.text,
        );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (error == null) {
      AppToaster.show(l10n.authPasswordChangedSuccess, kind: ToastKind.success);
      context.pop();
      return;
    }
    setState(() {
      _loading = false;
      _currentError = fieldErrorFor(error, 'current_password');
      _passwordError = fieldErrorFor(error, 'password');
    });
    if (_currentError == null && _passwordError == null) {
      AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthFlowScaffold(
      title: l10n.authChangePassword,
      body: Form(
        key: _formKey,
        autovalidateMode:
            _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _current,
              label: l10n.authCurrentPassword,
              type: AppInputType.password,
              fieldHeight: AppSize.fieldHeightComfortable,
              errorMessage: _currentError,
              textInputAction: TextInputAction.next,
              validator: (v) => validateRequired(l10n, v),
            ),
            AppSize.spaceMD.gap,
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
        text: l10n.save,
        isLoading: _loading,
        onPressed: _loading ? null : _submit,
      ),
    );
  }
}
