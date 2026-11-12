import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/api/api_error_user_message.dart';
import '../../core/api/api_field_errors.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/validation/egypt_mobile_phone_validation.dart';
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
  String? _nameError;
  String? _phoneError;

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
  final l10n = AppLocalizations.of(context);
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
      AppToaster.show(l10n.toastClientCreated, kind: ToastKind.success);
      Navigator.pop(context, client.id);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final lookup = ApiFieldErrorLookup(e);
      setState(() {
        _nameError = lookup.textFor('name');
        _phoneError = duplicatePhoneFieldError(l10n, e) ?? lookup.textFor('phone');
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      final messageL10n = AppLocalizations.of(context);
      AppToaster.show(apiErrorUserMessage(messageL10n, e), kind: ToastKind.failure);
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
              errorMessage: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
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
              validator: (value) => validateOptionalEgyptMobile(l10n, value),
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
  String? _nameError;
  String? _phoneError;

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
    final l10n = AppLocalizations.of(context);
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
        AppToaster.show(l10n.toastSupplierCreated, kind: ToastKind.success);
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
      final lookup = ApiFieldErrorLookup(e);
      setState(() {
        _nameError = duplicateProviderNameFieldError(l10n, e) ?? lookup.textFor('name');
        _phoneError = duplicateProviderPhoneFieldError(l10n, e) ?? lookup.textFor('phone');
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
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
              errorMessage: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
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
              errorMessage: _phoneError,
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
              validator: (value) => validateOptionalEgyptMobile(l10n, value),
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
  String? _nameError;
  String? _phoneError;

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
    final l10n = AppLocalizations.of(context);
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
        if (!mounted || provider == null) {
          setState(() => _saving = false);
          return;
        }
        AppToaster.show(l10n.toastCraftsmanCreated, kind: ToastKind.success);
        Navigator.pop(context, provider.id);
        return;
      }
      final c = await ref.read(repositoryProvider).createCraftsman(
            name: _name.text.trim(),
            phone: phoneText.isEmpty ? null : phoneText,
          );
      if (!mounted) return;
      Navigator.pop(context, c.id);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final lookup = ApiFieldErrorLookup(e);
      setState(() {
        _nameError = duplicateProviderNameFieldError(l10n, e) ?? lookup.textFor('name');
        _phoneError = duplicateProviderPhoneFieldError(l10n, e) ?? lookup.textFor('phone');
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
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
              errorMessage: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
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
              errorMessage: _phoneError,
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
              validator: (value) => validateOptionalEgyptMobile(l10n, value),
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
