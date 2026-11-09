import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../home/home_foundation_scope.dart';
import 'auth_controller.dart';
import 'auth_form_utils.dart';
import 'auth_messages.dart';

Future<bool?> showProfileEditNameSheet(
  BuildContext context, {
  required String initialName,
}) {
  return BnoodModalSheet.show<bool>(
    context: context,
    builder: (_) => HomeFoundationScope(
      child: ProfileEditNameSheet(initialName: initialName),
    ),
  );
}

class ProfileEditNameSheet extends ConsumerStatefulWidget {
  const ProfileEditNameSheet({super.key, required this.initialName});

  final String initialName;

  @override
  ConsumerState<ProfileEditNameSheet> createState() => _ProfileEditNameSheetState();
}

class _ProfileEditNameSheetState extends ConsumerState<ProfileEditNameSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.initialName);
  var _saving = false;
  String? _nameError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() {
      _saving = true;
      _nameError = null;
    });
    final error = await ref.read(authControllerProvider.notifier).saveProfileName(_nameCtrl.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, true);
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = false;
      _nameError = fieldErrorFor(error, 'name') ?? authApiMessage(l10n, error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSize.spaceMD.gap,
          const SheetDragHandle(),
          AppSize.spaceLG.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Text(l10n.profileEditNameTitle, style: context.text.pageTitle, textAlign: TextAlign.start),
          ),
          AppSize.spaceXL.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Form(
              key: _formKey,
              child: CustomTextField(
                controller: _nameCtrl,
                label: l10n.authDisplayName,
                placeholder: l10n.authDisplayNameHint,
                fieldHeight: AppSize.fieldHeightComfortable,
                errorMessage: _nameError,
                textInputAction: TextInputAction.done,
                validator: (v) => validateDisplayName(l10n, v),
              ),
            ),
          ),
          AppSize.spaceXL.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    text: l10n.cancel,
                    onPressed: _saving ? null : () => Navigator.pop(context, false),
                  ),
                ),
                AppSize.spaceMD.gap,
                Expanded(
                  child: AppButton.primary(
                    text: l10n.save,
                    isLoading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ),
              ],
            ),
          ),
          AppSize.spaceLG.gap,
        ],
      ),
    );
  }
}
