import 'dart:async';

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

class RegisterVerifyScreen extends ConsumerStatefulWidget {
  const RegisterVerifyScreen({super.key});

  @override
  ConsumerState<RegisterVerifyScreen> createState() => _RegisterVerifyScreenState();
}

class _RegisterVerifyScreenState extends ConsumerState<RegisterVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  var _attemptedSubmit = false;
  var _loading = false;
  var _resendLoading = false;
  Timer? _resendTimer;
  var _resendSeconds = 0;
  String? _codeError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = ref.read(authControllerProvider).pendingRegistration;
      setState(() => _resendSeconds = pending?.resendAfterSeconds ?? 0);
      _startResendCountdown();
    });
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    if (_resendSeconds <= 0) return;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendSeconds <= 1) {
        t.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds -= 1);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
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
        await ref.read(authControllerProvider.notifier).verifyRegistration(_code.text.trim());
    if (!mounted) return;
    if (error == null) {
      context.go(AuthPaths.remote);
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

  Future<void> _resend() async {
    if (_resendSeconds > 0 || _resendLoading) return;
    setState(() => _resendLoading = true);
    final error = await ref.read(authControllerProvider.notifier).resendRegistration();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _resendLoading = false);
    if (error != null) {
      AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
      return;
    }
    final pending = ref.read(authControllerProvider).pendingRegistration;
    setState(() => _resendSeconds = pending?.resendAfterSeconds ?? 0);
    _startResendCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pending = ref.watch(authControllerProvider).pendingRegistration;
    if (pending == null) {
      return AuthFlowScaffold(
        title: l10n.authVerificationTitle,
        body: Text(l10n.authFlowExpired),
        footer: AppButton.primary(
          text: l10n.authRegisterTitle,
          onPressed: () => context.go(AuthPaths.register),
        ),
      );
    }

    return AuthFlowScaffold(
      title: l10n.authVerificationTitle,
      subtitle: l10n.authVerificationSubtitle,
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
                  l10n.authPhone,
                  style: context.text.label,
                  textAlign: TextAlign.start,
                ),
                AppSize.spaceXS.gap,
                Text(
                  LtrIsolate.isolate(pending.phone),
                  style: context.text.body,
                ),
                AppSize.spaceLG.gap,
                CustomTextField(
                  controller: _code,
                  label: l10n.authVerificationCode,
                  fieldHeight: AppSize.fieldHeightComfortable,
                  ltrValue: true,
                  errorMessage: _codeError,
                  textInputAction: TextInputAction.done,
                  validator: (v) => validateVerificationCode(l10n, v),
                ),
              ],
            ),
          );
        },
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton.primary(
            text: l10n.authVerifyAction,
            isLoading: _loading,
            onPressed: _loading ? null : _submit,
          ),
          AppSize.spaceSM.gap,
          TextButton(
            onPressed: (_resendSeconds > 0 || _resendLoading) ? null : _resend,
            child: Text(
              _resendSeconds > 0
                  ? l10n.authResendWait(_resendSeconds)
                  : l10n.authResendCode,
            ),
          ),
        ],
      ),
    );
  }
}
