import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/auth_api_exception.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../home/home_foundation_scope.dart';
import 'provider_mutation_actions.dart';

Future<void> showProviderEditSheet(
  BuildContext context, {
  required AppProvider provider,
}) {
  return BnoodModalSheet.show<void>(
    context: context,
    builder: (_) => HomeFoundationScope(
      child: ProviderEditSheet(provider: provider),
    ),
  );
}

class ProviderEditSheet extends ConsumerStatefulWidget {
  const ProviderEditSheet({super.key, required this.provider});

  final AppProvider provider;

  @override
  ConsumerState<ProviderEditSheet> createState() => _ProviderEditSheetState();
}

class _ProviderEditSheetState extends ConsumerState<ProviderEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.provider.name);
  late final _phoneCtrl = TextEditingController(text: widget.provider.phone ?? '');
  var _attemptedSubmit = false;
  var _saving = false;
  String? _nameError;
  String? _phoneError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _attemptedSubmit = true;
      _nameError = null;
      _phoneError = null;
    });
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final updated = await saveProviderUpdate(
        ref: ref,
        context: context,
        providerId: widget.provider.id,
        name: _nameCtrl.text.trim(),
        phoneField: _phoneCtrl.text,
      );
      if (updated != null && mounted) Navigator.pop(context);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _nameError = duplicateProviderNameFieldError(l10n, e);
        _phoneError = duplicateProviderPhoneFieldError(l10n, e);
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDeleteProvider(
      context,
      ref,
      providerId: widget.provider.id,
      name: widget.provider.name,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kindMeta = widget.provider.type == AppProviderType.supplier
        ? l10n.directorySupplierKindMeta
        : l10n.directoryCraftsmanKindMeta;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        AppSize.spaceSM,
        AppSize.screenPadding,
        AppSize.spaceMD,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetDragHandle(),
          AppSize.spaceMD.gap,
          Text(l10n.edit, style: context.text.title),
          AppSize.spaceSM.gap,
          Text(kindMeta, style: context.text.caption.copyWith(color: context.colors.onSurfaceMuted)),
          AppSize.spaceMD.gap,
          Form(
            key: _formKey,
            autovalidateMode:
                _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _nameCtrl,
                  label: l10n.providerNameLabel,
                  placeholder: l10n.providerNameHint,
                  fieldHeight: AppSize.fieldHeightComfortable,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  errorMessage: _nameError,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.providerNameRequired;
                    }
                    return null;
                  },
                ),
                AppSize.spaceMD.gap,
                CustomTextField(
                  controller: _phoneCtrl,
                    label: l10n.phoneOptional,
                    placeholder: l10n.clientPhoneHint,
                  fieldHeight: AppSize.fieldHeightComfortable,
                    type: AppInputType.phone,
                  ltrValue: true,
                  textInputAction: TextInputAction.done,
                  errorMessage: _phoneError,
                ),
              ],
            ),
          ),
          AppSize.spaceLG.gap,
          AppButton.primary(
            text: l10n.save,
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
          AppSize.spaceSM.gap,
          AppButton.outlined(
            text: l10n.delete,
            foregroundColor: context.colors.onSurface,
            borderColor: context.colors.outline,
            onPressed: _saving ? null : _delete,
          ),
        ],
      ),
    );
  }
}
