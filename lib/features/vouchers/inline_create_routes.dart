import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/contacts/contact_import_action.dart';
import '../../core/widgets/custom_text_field.dart';
import 'inline_entity_create_shell.dart';

class InlineCreateClientPage extends ConsumerStatefulWidget {
  const InlineCreateClientPage({super.key, this.padForSystemChrome = true});

  final bool padForSystemChrome;

  @override
  ConsumerState<InlineCreateClientPage> createState() =>
      _InlineCreateClientPageState();
}

class _InlineCreateClientPageState
    extends ConsumerState<InlineCreateClientPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  var _attemptedSubmit = false;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _attemptedSubmit = true);
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final client = await ref.read(repositoryProvider).createClient(
            name: _name.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, client.id);
    } catch (e) {
      if (!mounted) return;
      AppToaster.show(e.toString(), kind: ToastKind.failure);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InlineEntityCreateShell(
      title: l10n.addClient,
      padForSystemChrome: widget.padForSystemChrome,
      body: Form(
        key: _formKey,
        autovalidateMode:
            _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ContactImportAction(
              nameController: _name,
              phoneController: _phone,
              enabled: !_saving,
            ),
            AppSize.spaceMD.gap,
            CustomTextField(
              controller: _name,
              label: l10n.clientName,
              placeholder: l10n.clientNameHint,
              fieldHeight: AppSize.fieldHeightComfortable,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.clientNameRequired;
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
            ),
          ],
        ),
      ),
      footer: AppButton.primary(
        text: l10n.save,
        isLoading: _saving,
        onPressed: _saving ? null : _save,
      ),
    );
  }
}

class InlineCreateItemPage extends ConsumerStatefulWidget {
  const InlineCreateItemPage({super.key});

  @override
  ConsumerState<InlineCreateItemPage> createState() =>
      _InlineCreateItemPageState();
}

class _InlineCreateItemPageState extends ConsumerState<InlineCreateItemPage> {
  final _name = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final item = await ref.read(repositoryProvider).createItem(
            name: _name.text.trim(),
            colorKey: 'teal',
            iconName: 'category',
          );
      if (!mounted) return;
      Navigator.pop(context, item.id);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InlineEntityCreateShell(
      title: l10n.item,
      body: CustomTextField(
        controller: _name,
        label: l10n.item,
        placeholder: l10n.item,
        fieldHeight: AppSize.fieldHeightComfortable,
        autofocus: true,
        textInputAction: TextInputAction.done,
      ),
      footer: AppButton.primary(
        text: l10n.save,
        isLoading: _saving,
        onPressed: _saving ? null : _save,
      ),
    );
  }
}

class InlineCreateSupplierPage extends ConsumerStatefulWidget {
  const InlineCreateSupplierPage({super.key, this.padForSystemChrome = true});

  final bool padForSystemChrome;

  @override
  ConsumerState<InlineCreateSupplierPage> createState() =>
      _InlineCreateSupplierPageState();
}

class _InlineCreateSupplierPageState
    extends ConsumerState<InlineCreateSupplierPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  var _attemptedSubmit = false;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _attemptedSubmit = true);
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final s = await ref.read(repositoryProvider).createSupplier(
            name: _name.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, s.id);
    } catch (e) {
      if (!mounted) return;
      AppToaster.show(e.toString(), kind: ToastKind.failure);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InlineEntityCreateShell(
      title: l10n.directoryAddSupplier,
      padForSystemChrome: widget.padForSystemChrome,
      body: Form(
        key: _formKey,
        autovalidateMode:
            _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _name,
              label: l10n.supplier,
              placeholder: l10n.directorySupplierNameHint,
              fieldHeight: AppSize.fieldHeightComfortable,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.supplierNameRequired;
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
            ),
          ],
        ),
      ),
      footer: AppButton.primary(
        text: l10n.save,
        isLoading: _saving,
        onPressed: _saving ? null : _save,
      ),
    );
  }
}

class InlineCreateCraftsmanPage extends ConsumerStatefulWidget {
  const InlineCreateCraftsmanPage({
    super.key,
    this.padForSystemChrome = true,
    this.preferContentHeight = false,
  });

  final bool padForSystemChrome;
  final bool preferContentHeight;

  @override
  ConsumerState<InlineCreateCraftsmanPage> createState() =>
      _InlineCreateCraftsmanPageState();
}

class _InlineCreateCraftsmanPageState
    extends ConsumerState<InlineCreateCraftsmanPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  var _attemptedSubmit = false;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _attemptedSubmit = true);
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final phoneText = _phone.text.trim();
      final c = await ref.read(repositoryProvider).createCraftsman(
            name: _name.text.trim(),
            phone: phoneText.isEmpty ? null : phoneText,
          );
      if (!mounted) return;
      Navigator.pop(context, c.id);
    } catch (e) {
      if (!mounted) return;
      AppToaster.show(e.toString(), kind: ToastKind.failure);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InlineEntityCreateShell(
      title: l10n.directoryAddCraftsman,
      padForSystemChrome: widget.padForSystemChrome,
      preferContentHeight: widget.preferContentHeight,
      body: Form(
        key: _formKey,
        autovalidateMode:
            _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ContactImportAction(
              nameController: _name,
              phoneController: _phone,
              enabled: !_saving,
            ),
            AppSize.spaceMD.gap,
            CustomTextField(
              controller: _name,
              label: l10n.craftsman,
              placeholder: l10n.directoryCraftsmanNameHint,
              fieldHeight: AppSize.fieldHeightComfortable,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.craftsmanNameRequired;
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
            ),
          ],
        ),
      ),
      footer: AppButton.primary(
        text: l10n.save,
        isLoading: _saving,
        onPressed: _saving ? null : _save,
      ),
    );
  }
}
