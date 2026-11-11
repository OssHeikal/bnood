import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/items/items_providers.dart';
import '../../core/providers/app_providers.dart';
import '../../core/vouchers/vouchers_riverpod.dart';
import '../items/item_mutation_actions.dart';
import '../../core/widgets/app_toaster.dart';
import '../clients/client_mutation_actions.dart';
import '../providers/provider_mutation_actions.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/providers_api/providers_riverpod.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/contacts/contact_import_action.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/overlay_form_presentation.dart';
import 'inline_entity_create_shell.dart';

class InlineCreateClientPage extends ConsumerStatefulWidget {
  const InlineCreateClientPage({
    super.key,
    this.presentation = OverlayFormPresentation.inSheet,
    this.padForSystemChrome = true,
  });

  final OverlayFormPresentation presentation;
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
  String? _phoneError;

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
      final client = await saveClientCreate(
        ref: ref,
        context: context,
        name: _name.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      );
      if (!mounted || client == null) {
        setState(() => _saving = false);
        return;
      }
      Navigator.pop(context, client.id);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _phoneError = duplicatePhoneFieldError(l10n, e);
        _saving = false;
      });
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
      presentation: widget.presentation,
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
              errorMessage: _phoneError,
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
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
      if (ref.read(remoteItemsEnabledProvider)) {
        final item = await saveItemCreate(
          ref: ref,
          context: context,
          name: _name.text.trim(),
          iconKey: 'category',
          colorKey: 'teal',
        );
        if (!mounted || item == null) return;
        Navigator.pop(context, item.id);
        return;
      }
      final item = await ref.read(repositoryProvider).createItem(
            name: _name.text.trim(),
            colorKey: 'teal',
            iconName: 'category',
          );
      if (!mounted) return;
      Navigator.pop(context, item.id);
    } on AuthApiException {
      if (mounted) setState(() => _saving = false);
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
  const InlineCreateSupplierPage({
    super.key,
    this.presentation = OverlayFormPresentation.inSheet,
    this.padForSystemChrome = true,
  });

  final OverlayFormPresentation presentation;
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
      final phoneText = _phone.text.trim();
      if (ref.read(remoteProvidersEnabledProvider) || ref.read(remoteVouchersEnabledProvider)) {
        final provider = await saveProviderCreate(
          ref: ref,
          context: context,
          name: _name.text.trim(),
          type: AppProviderType.supplier,
          phone: phoneText.isEmpty ? null : phoneText,
        );
        if (!mounted || provider == null) {
          setState(() => _saving = false);
          return;
        }
        Navigator.pop(context, provider.id);
        return;
      }
      final s = await ref.read(repositoryProvider).createSupplier(
            name: _name.text.trim(),
            phone: phoneText.isEmpty ? null : phoneText,
          );
      if (!mounted) return;
      Navigator.pop(context, s.id);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      AppToaster.show(duplicatePhoneFieldError(l10n, e) ?? e.message, kind: ToastKind.failure);
      setState(() => _saving = false);
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
      presentation: widget.presentation,
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
    this.presentation = OverlayFormPresentation.inSheet,
    this.padForSystemChrome = true,
    this.preferContentHeight = false,
  });

  final OverlayFormPresentation presentation;
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
      if (ref.read(remoteProvidersEnabledProvider)) {
        final provider = await saveProviderCreate(
          ref: ref,
          context: context,
          name: _name.text.trim(),
          type: AppProviderType.craftsman,
          phone: phoneText.isEmpty ? null : phoneText,
        );
        if (!mounted || provider == null) return;
        Navigator.pop(context, provider.id);
        return;
      }
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
      presentation: widget.presentation,
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
