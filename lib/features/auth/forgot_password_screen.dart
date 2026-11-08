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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  var _attemptedSubmit = false;
  var _loading = false;
  String? _phoneError;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _attemptedSubmit = true;
      _phoneError = null;
    });
    if (_formKey.currentState?.validate() != true) return;
    if (_loading) return;
    setState(() => _loading = true);
    final error = await ref.read(authControllerProvider.notifier).forgotPassword(_phone.text.trim());
    if (!mounted) return;
    if (error == null) {
      context.push(AuthPaths.forgotVerify);
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _loading = false;
      _phoneError = fieldErrorFor(error, 'phone');
    });
    if (_phoneError == null) {
      AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthFlowScaffold(
      title: l10n.authForgotPasswordTitle,
      subtitle: l10n.authForgotPasswordSubtitle,
      body: Form(
        key: _formKey,
        autovalidateMode:
            _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: CustomTextField(
          controller: _phone,
          label: l10n.authPhone,
          placeholder: l10n.clientPhoneHint,
          type: AppInputType.phone,
          ltrValue: true,
          fieldHeight: AppSize.fieldHeightComfortable,
          errorMessage: _phoneError,
          textInputAction: TextInputAction.done,
          validator: (v) => validateEgyptPhone(l10n, v),
        ),
      ),
      footer: AppButton.primary(
        text: l10n.authContinue,
        isLoading: _loading,
        onPressed: _loading ? null : _submit,
      ),
    );
  }
}
