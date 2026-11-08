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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _attemptedSubmit = false;
  var _loading = false;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _attemptedSubmit = true;
      _phoneError = null;
      _passwordError = null;
    });
    if (_formKey.currentState?.validate() != true) return;
    if (_loading) return;
    setState(() => _loading = true);
    final error = await ref.read(authControllerProvider.notifier).register(
          phone: _phone.text.trim(),
          password: _password.text,
          passwordConfirmation: _confirm.text,
        );
    if (!mounted) return;
    if (error == null) {
      context.push(AuthPaths.registerVerify);
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _loading = false;
      _phoneError = fieldErrorFor(error, 'phone');
      _passwordError = fieldErrorFor(error, 'password');
    });
    if (_phoneError == null && _passwordError == null) {
      AppToaster.show(subscriberAuthMessage(l10n, error), kind: ToastKind.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthFlowScaffold(
      title: l10n.authRegisterTitle,
      subtitle: l10n.authRegisterSubtitle,
      body: Form(
        key: _formKey,
        autovalidateMode:
            _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _phone,
              label: l10n.authPhone,
              placeholder: l10n.clientPhoneHint,
              type: AppInputType.phone,
              ltrValue: true,
              fieldHeight: AppSize.fieldHeightComfortable,
              errorMessage: _phoneError,
              textInputAction: TextInputAction.next,
              validator: (v) => validateEgyptPhone(l10n, v),
            ),
            AppSize.spaceMD.gap,
            CustomTextField(
              controller: _password,
              label: l10n.authPassword,
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
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton.primary(
            text: l10n.authCreateAccount,
            isLoading: _loading,
            onPressed: _loading ? null : _submit,
          ),
          AppSize.spaceSM.gap,
          TextButton(
            onPressed: _loading ? null : () => context.push(AuthPaths.login),
            child: Text(l10n.authLoginLink),
          ),
        ],
      ),
    );
  }
}
