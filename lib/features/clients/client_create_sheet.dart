import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_field_errors.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/contacts/contact_import_action.dart';
import '../../core/validation/egypt_mobile_phone_validation.dart';
import '../../core/widgets/app_modal_sheet.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/sheet_footer_refresh.dart';
import '../../core/widgets/sheet_form_header.dart';
import '../home/home_foundation_scope.dart';
import 'client_mutation_actions.dart';

Future<String?> showClientCreateSheet(BuildContext context) {
  final formKey = GlobalKey<_ClientCreateSheetState>();
  final footerRefresh = SheetFooterRefresh();
  final l10n = AppLocalizations.of(context);
  return AppModalSheet.show<String?>(
    context: context,
    scrollable: false,
    header: const SheetDragHeader(),
    body: HomeFoundationScope(
      child: ClientCreateSheet(
        key: formKey,
        footerRefresh: footerRefresh,
      ),
    ),
    footer: ListenableBuilder(
      listenable: footerRefresh,
      builder: (context, _) {
        final state = formKey.currentState;
        if (state == null) return const SizedBox.shrink();
        return AppButton.primary(
          text: l10n.save,
          isLoading: state._saving,
          onPressed: state._saving ? null : state._save,
        );
      },
    ),
  );
}

class ClientCreateSheet extends ConsumerStatefulWidget {
  const ClientCreateSheet({super.key, required this.footerRefresh});

  final SheetFooterRefresh footerRefresh;

  @override
  ConsumerState<ClientCreateSheet> createState() => _ClientCreateSheetState();
}

class _ClientCreateSheetState extends ConsumerState<ClientCreateSheet> {
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

  void _bumpFooter() => widget.footerRefresh.bump();

  Future<void> _save() async {
    setState(() {
      _attemptedSubmit = true;
      _nameError = null;
      _phoneError = null;
    });
    _bumpFooter();
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    _bumpFooter();
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
        _bumpFooter();
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
      _bumpFooter();
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
        0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.addClient, style: context.text.title),
          AppSize.spaceMD.gap,
          Form(
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
        ],
      ),
    );
  }
}