import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/app_button.dart' as legacy;
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';

class InlineCreateClientPage extends ConsumerStatefulWidget {
  const InlineCreateClientPage({super.key});

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        0,
        AppSize.screenPadding,
        AppSize.spaceMD,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode:
            _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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

class InlineCreateItemPage extends ConsumerStatefulWidget {
  const InlineCreateItemPage({super.key});

  @override
  ConsumerState<InlineCreateItemPage> createState() =>
      _InlineCreateItemPageState();
}

class _InlineCreateItemPageState extends ConsumerState<InlineCreateItemPage> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.item)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.item)),
            const Spacer(),
            legacy.AppButton(
              label: l10n.save,
              onPressed: () async {
                if (_name.text.trim().isEmpty) return;
                final item = await ref.read(repositoryProvider).createItem(
                      name: _name.text.trim(),
                      colorKey: 'teal',
                      iconName: 'category',
                    );
                if (context.mounted) Navigator.pop(context, item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InlineCreateSupplierPage extends ConsumerStatefulWidget {
  const InlineCreateSupplierPage({super.key});

  @override
  ConsumerState<InlineCreateSupplierPage> createState() =>
      _InlineCreateSupplierPageState();
}

class _InlineCreateSupplierPageState
    extends ConsumerState<InlineCreateSupplierPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.supplier)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.supplier)),
            TextField(
                controller: _phone,
                decoration: InputDecoration(labelText: l10n.phoneOptional)),
            const Spacer(),
            legacy.AppButton(
              label: l10n.save,
              onPressed: () async {
                if (_name.text.trim().isEmpty) return;
                final s = await ref.read(repositoryProvider).createSupplier(
                      name: _name.text.trim(),
                      phone: _phone.text.trim().isEmpty
                          ? null
                          : _phone.text.trim(),
                    );
                if (context.mounted) Navigator.pop(context, s.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InlineCreateCraftsmanPage extends ConsumerStatefulWidget {
  const InlineCreateCraftsmanPage({super.key});

  @override
  ConsumerState<InlineCreateCraftsmanPage> createState() =>
      _InlineCreateCraftsmanPageState();
}

class _InlineCreateCraftsmanPageState
    extends ConsumerState<InlineCreateCraftsmanPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.craftsman)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.craftsman)),
            TextField(
                controller: _phone,
                decoration: InputDecoration(labelText: l10n.phoneOptional)),
            const Spacer(),
            legacy.AppButton(
              label: l10n.save,
              onPressed: () async {
                if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
                  return;
                }
                final c = await ref.read(repositoryProvider).createCraftsman(
                      name: _name.text.trim(),
                      phone: _phone.text.trim(),
                    );
                if (context.mounted) Navigator.pop(context, c.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
