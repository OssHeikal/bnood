import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../home/home_foundation_scope.dart';
import 'auth_controller.dart';
import 'auth_form_utils.dart';
import 'auth_messages.dart';
import 'auth_paths.dart';

Future<void> showDeleteAccountConfirmSheet(BuildContext context) {
  return BnoodModalSheet.show<void>(
    context: context,
    builder: (_) => const HomeFoundationScope(child: DeleteAccountConfirmSheet()),
  );
}

class DeleteAccountConfirmSheet extends ConsumerStatefulWidget {
  const DeleteAccountConfirmSheet({super.key});

  @override
  ConsumerState<DeleteAccountConfirmSheet> createState() => _DeleteAccountConfirmSheetState();
}

class _DeleteAccountConfirmSheetState extends ConsumerState<DeleteAccountConfirmSheet> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  var _submitting = false;
  String? _passwordError;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _passwordError = null;
    });
    final error = await ref.read(authControllerProvider.notifier).deleteAccount(
          currentPassword: _passwordCtrl.text,
        );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (error == null) {
      Navigator.pop(context);
      AppToaster.show(l10n.authDeleteAccountSuccess, kind: ToastKind.success);
      context.go(AuthPaths.login);
      return;
    }
    setState(() {
      _submitting = false;
      if (error.isInvalidCredentials) {
        _passwordError = l10n.authInvalidCredentials;
      } else if (error.isAccountDeleted) {
        _passwordError = l10n.authAccountDeletedMessage;
      } else {
        final field = fieldErrorFor(error, 'current_password');
        _passwordError = field ?? authApiMessage(l10n, error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSize.spaceMD.gap,
          const SheetDragHandle(),
          AppSize.spaceLG.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Text(l10n.authDeleteAccountConfirmTitle, style: context.text.pageTitle, textAlign: TextAlign.start),
          ),
          AppSize.spaceSM.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Text(
              l10n.authDeleteAccountConfirmBody,
              style: context.text.body.copyWith(color: colors.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ),
          AppSize.spaceXL.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Form(
              key: _formKey,
              child: CustomTextField(
                controller: _passwordCtrl,
                label: l10n.authCurrentPassword,
                type: AppInputType.password,
                fieldHeight: AppSize.fieldHeightComfortable,
                errorMessage: _passwordError,
                textInputAction: TextInputAction.done,
                validator: (v) => validateRequired(l10n, v),
              ),
            ),
          ),
          AppSize.spaceXL.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: AppButton.destructive(
              text: l10n.authDeleteAccount,
              isLoading: _submitting,
              onPressed: _submitting ? null : _confirmDelete,
            ),
          ),
          AppSize.spaceMD.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: AppButton.outlined(
              text: l10n.cancel,
              onPressed: _submitting ? null : () => Navigator.pop(context),
            ),
          ),
          AppSize.spaceLG.gap,
        ],
    );
  }
}
