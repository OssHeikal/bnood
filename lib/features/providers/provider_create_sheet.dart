import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/auth_api_exception.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_shape.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/contacts/contact_import_action.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import 'provider_mutation_actions.dart';

class ProviderCreateSheet extends ConsumerStatefulWidget {
  const ProviderCreateSheet({
    super.key,
    this.initialType = AppProviderType.supplier,
  });

  final AppProviderType initialType;

  @override
  ConsumerState<ProviderCreateSheet> createState() => _ProviderCreateSheetState();
}

class _ProviderCreateSheetState extends ConsumerState<ProviderCreateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  var _attemptedSubmit = false;
  var _saving = false;
  String? _nameError;
  String? _phoneError;
  late AppProviderType _type = widget.initialType;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
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
    final phoneRaw = _phone.text.trim();
    try {
      final created = await saveProviderCreate(
        ref: ref,
        context: context,
        name: _name.text.trim(),
        type: _type,
        phone: phoneRaw.isEmpty ? null : phoneRaw,
      );
      if (created != null && mounted) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        AppSize.spaceSM,
        AppSize.screenPadding,
        AppSize.spaceMD,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetDragHandle(),
            AppSize.spaceMD.gap,
            Text(l10n.providerCreateSheetTitle, style: context.text.title),
            AppSize.spaceMD.gap,
            Form(
              key: _formKey,
              autovalidateMode:
                  _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.providerTypeLabel, style: context.text.label),
                  AppSize.spaceSM.gap,
                  _ProviderTypeTabs(
                    supplierLabel: l10n.supplier,
                    craftsmanLabel: l10n.craftsman,
                    selected: _type,
                    enabled: !_saving,
                    onChanged: (type) => setState(() => _type = type),
                  ),
                  AppSize.spaceMD.gap,
                  ContactImportAction(
                    nameController: _name,
                    phoneController: _phone,
                    enabled: !_saving,
                  ),
                  AppSize.spaceMD.gap,
                  CustomTextField(
                    controller: _name,
                    label: l10n.providerNameLabel,
                    placeholder: l10n.providerNameHint,
                    fieldHeight: AppSize.fieldHeightComfortable,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    errorMessage: _nameError,
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.providerNameRequired;
                      }
                      return null;
                    },
                  ),
                  AppSize.spaceMD.gap,
                  CustomTextField(
                    controller: _phone,
                    label: l10n.phoneOptional,
                    placeholder: l10n.clientPhoneHint,
                    fieldHeight: AppSize.fieldHeightComfortable,
                    type: AppInputType.phone,
                    ltrValue: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    errorMessage: _phoneError,
                    onChanged: (_) {
                      if (_phoneError != null) setState(() => _phoneError = null);
                    },
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
          ],
        ),
      ),
    );
  }
}

class _ProviderTypeTabs extends StatelessWidget {
  const _ProviderTypeTabs({
    required this.supplierLabel,
    required this.craftsmanLabel,
    required this.selected,
    required this.onChanged,
    required this.enabled,
  });

  final String supplierLabel;
  final String craftsmanLabel;
  final AppProviderType selected;
  final ValueChanged<AppProviderType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProviderTypeChip(
            chipKey: const Key('provider_type_supplier'),
            label: supplierLabel,
            selected: selected == AppProviderType.supplier,
            enabled: enabled,
            onTap: () => onChanged(AppProviderType.supplier),
          ),
        ),
        AppSize.spaceSM.gap,
        Expanded(
          child: _ProviderTypeChip(
            chipKey: const Key('provider_type_craftsman'),
            label: craftsmanLabel,
            selected: selected == AppProviderType.craftsman,
            enabled: enabled,
            onTap: () => onChanged(AppProviderType.craftsman),
          ),
        ),
      ],
    );
  }
}

class _ProviderTypeChip extends StatelessWidget {
  const _ProviderTypeChip({
    required this.chipKey,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.enabled,
  });

  final Key chipKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        key: chipKey,
        color: selected ? colors.primary : colors.surface,
        shape: AppShape.superellipse(radius: AppSize.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: SizedBox(
            height: AppSize.buttonHeightSmall,
            child: Center(
              child: Text(
                label,
                style: context.text.bodyEmphasis.copyWith(
                  color: selected ? colors.onPrimary : colors.onSurfaceMuted,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
