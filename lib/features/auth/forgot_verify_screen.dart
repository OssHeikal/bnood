import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/utils/extensions/bidi_isolate.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import 'auth_controller.dart';
import 'auth_form_utils.dart';
import 'auth_messages.dart';
import 'auth_paths.dart';
import 'widgets/auth_flow_scaffold.dart';

class ForgotVerifyScreen extends ConsumerStatefulWidget {
  const ForgotVerifyScreen({super.key});

  @override
  ConsumerState<ForgotVerifyScreen> createState() => _ForgotVerifyScreenState();
}

class _ForgotVerifyScreenState extends ConsumerState<ForgotVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  var _attemptedSubmit = false;
  var _loading = false;
  String? _codeError;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _attemptedSubmit = true;
      _codeError = null;
    });
    if (_formKey.currentState?.validate() != true) return;
    if (_loading) return;
    setState(() => _loading = true);
    final error =
        await ref.read(authControllerProvider.notifier).verifyForgotPassword(_code.text.trim());
    if (!mounted) return;
    if (error == null) {
      context.push(AuthPaths.resetPassword);
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _loading = false;
      _codeError = fieldErrorFor(error, 'code');
    });
    if (_codeError == null) {
      AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pending = ref.watch(authControllerProvider).pendingRecovery;
    if (pending == null) {
      return AuthFlowScaffold(
        title: l10n.authVerificationTitle,
        body: Text(l10n.authFlowExpired),
        footer: AppButton.primary(
          text: l10n.authForgotPasswordTitle,
          onPressed: () => context.go(AuthPaths.forgotPassword),
        ),
      );
    }

    return AuthFlowScaffold(
      title: l10n.authVerificationTitle,
      subtitle: l10n.authRecoveryVerifySubtitle,
      body: Builder(
        builder: (context) {
          return Form(
            key: _formKey,
            autovalidateMode: _attemptedSubmit
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  LtrIsolate.isolate(pending.phone),
                  style: context.text.body,
                ),
                AppSize.spaceLG.gap,
                CustomTextField(
                  controller: _code,
                  label: l10n.authVerificationCode,
                  ltrValue: true,
                  fieldHeight: AppSize.fieldHeightComfortable,
                  errorMessage: _codeError,
                  textInputAction: TextInputAction.done,
                  validator: (v) => validateVerificationCode(l10n, v),
                ),
              ],
            ),
          );
        },
      ),
      footer: AppButton.primary(
        text: l10n.authContinue,
        isLoading: _loading,
        onPressed: _loading ? null : _submit,
      ),
    );
  }
}
