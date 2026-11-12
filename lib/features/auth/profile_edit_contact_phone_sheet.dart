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

String? validateOptionalEgyptContactPhone(AppLocalizations l10n, String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return null;
  return validateEgyptPhone(l10n, value);
}

Future<bool?> showProfileEditContactPhoneSheet(
  BuildContext context, {
  String? initialContactPhone,
}) {
  return BnoodModalSheet.show<bool>(
    context: context,
    builder: (_) => HomeFoundationScope(
      child: ProfileEditContactPhoneSheet(initialContactPhone: initialContactPhone),
    ),
  );
}

class ProfileEditContactPhoneSheet extends ConsumerStatefulWidget {
  const ProfileEditContactPhoneSheet({super.key, this.initialContactPhone});

  final String? initialContactPhone;

  @override
  ConsumerState<ProfileEditContactPhoneSheet> createState() => _ProfileEditContactPhoneSheetState();
}

class _ProfileEditContactPhoneSheetState extends ConsumerState<ProfileEditContactPhoneSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _phoneCtrl = TextEditingController(text: _localDigits(widget.initialContactPhone));
  var _saving = false;
  String? _phoneError;

  static String _localDigits(String? e164OrLocal) {
    if (e164OrLocal == null || e164OrLocal.isEmpty) return '';
    final digits = e164OrLocal.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('20') && digits.length >= 12) {
      return '0${digits.substring(2)}';
    }
    return digits.startsWith('0') ? digits : digits;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() {
      _saving = true;
      _phoneError = null;
    });
    final raw = _phoneCtrl.text.trim();
    final payload = raw.isEmpty ? null : raw;
    final error = await ref.read(authControllerProvider.notifier).saveContactPhone(payload);
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, true);
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = false;
      _phoneError = fieldErrorFor(error, 'contact_phone') ?? authApiMessage(l10n, error);
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
            child: Text(l10n.profileEditContactPhoneTitle, style: context.text.pageTitle, textAlign: TextAlign.start),
          ),
          AppSize.spaceSM.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Text(
              l10n.profileContactPhoneStatementHint,
              style: context.text.caption.copyWith(color: context.colors.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ),
          AppSize.spaceXL.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Form(
              key: _formKey,
              child: CustomTextField(
                controller: _phoneCtrl,
                label: l10n.profileContactPhone,
                placeholder: l10n.clientPhoneHint,
                type: AppInputType.phone,
                ltrValue: true,
                fieldHeight: AppSize.fieldHeightComfortable,
                errorMessage: _phoneError,
                textInputAction: TextInputAction.done,
                validator: (v) => validateOptionalEgyptContactPhone(l10n, v),
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
