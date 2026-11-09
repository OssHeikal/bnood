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

Future<void> _submitCompleteProfile(BuildContext context, WidgetRef ref) async {
  final fields = ref.read(completeProfileFormFieldsProvider);
  final ui = ref.read(authFormUiProvider(AuthFormId.completeProfile).notifier);
  const formId = AuthFormId.completeProfile;

  ui.beginAttempt();
  if (fields.formKey.currentState?.validate() != true) return;
  if (ref.read(authFormUiProvider(formId)).loading) return;
  ui.setLoading(true);
  final error = await ref.read(authControllerProvider.notifier).saveProfileName(fields.name.text);
  if (!context.mounted) return;
  if (error == null) {
    context.go(AuthPaths.remote);
    return;
  }
  final l10n = AppLocalizations.of(context);
  ui.fail(error);
  if (ref.read(authFormUiProvider(formId)).errorFor('name') == null) {
    AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
  }
}

Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  final failure = await ref.read(authControllerProvider.notifier).logout();
  if (!context.mounted) return;
  if (failure != null) {
    final l10n = AppLocalizations.of(context);
    AppToaster.show(authApiMessage(l10n, failure), kind: ToastKind.warning);
  }
  context.go(AuthPaths.login);
}

class CompleteProfileScreen extends ConsumerWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fields = ref.watch(completeProfileFormFieldsProvider);
    final ui = ref.watch(authFormUiProvider(AuthFormId.completeProfile));
    final loading = ui.loading;

    return AuthFlowScaffold(
      title: l10n.authCompleteProfileTitle,
      subtitle: l10n.authCompleteProfileSubtitle,
      alignment: AuthFlowAlignment.start,
      child: Form(
        key: fields.formKey,
        autovalidateMode:
            ui.attempted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: fields.name,
              label: l10n.authDisplayName,
              placeholder: l10n.authDisplayNameHint,
              fieldHeight: AppSize.fieldHeightComfortable,
              errorMessage: ui.errorFor('name'),
              textInputAction: TextInputAction.done,
              validator: (v) => validateRequired(l10n, v?.trim()),
            ),
            AppSize.spaceXL.gap,
            AppButton.primary(
              text: l10n.authContinue,
              isLoading: loading,
              onPressed: loading ? null : () => _submitCompleteProfile(context, ref),
            ),
            AppSize.spaceSM.gap,
            AppButton.text(
              text: l10n.authSignOut,
              onPressed: loading ? null : () => _signOut(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
