import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_field_errors.dart';
import '../../../../core/api/auth_api_exception.dart';
import '../../../../core/config/extensions/num_extensions.dart';
import '../../../../core/config/theme/app_size.dart';
import '../../../../core/validation/egypt_mobile_phone_validation.dart';
import '../../../../core/widgets/app_modal_sheet.dart';
import '../../../../core/widgets/app_toaster.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/sheet_footer_refresh.dart';
import '../../../../core/widgets/sheet_form_header.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/clients/presentation/actions/client_mutation_actions.dart';

Future<void> showClientEditSheet({
  required BuildContext context,
  required String clientId,
  required String clientName,
  String? phone,
}) {
  final formKey = GlobalKey<_ClientEditSheetState>();
  final footerRefresh = SheetFooterRefresh();
  final l10n = AppLocalizations.of(context);
  return AppModalSheet.show<void>(
    context: context,
    scrollable: false,
    header: SheetFormHeader(title: l10n.edit),
    body: HomeFoundationScope(
      child: ClientEditSheet(
        key: formKey,
        clientId: clientId,
        clientName: clientName,
        phone: phone,
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

class ClientEditSheet extends ConsumerStatefulWidget {
  const ClientEditSheet({
    super.key,
    required this.clientId,
    required this.clientName,
    this.phone,
    required this.footerRefresh,
  });

  final String clientId;
  final String clientName;
  final String? phone;
  final SheetFooterRefresh footerRefresh;

  @override
  ConsumerState<ClientEditSheet> createState() => _ClientEditSheetState();
}

class _ClientEditSheetState extends ConsumerState<ClientEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.clientName);
  late final _phoneCtrl = TextEditingController(text: widget.phone ?? '');
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
      final updated = await saveClientUpdate(
        ref: ref,
        context: context,
        clientId: widget.clientId,
        name: _nameCtrl.text.trim(),
        phoneField: _phoneCtrl.text,
      );
      if (updated != null && mounted) {
        AppToaster.show(l10n.toastClientUpdated, kind: ToastKind.success);
        Navigator.pop(context);
      }
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final lookup = ApiFieldErrorLookup(e);
      setState(() {
        _nameError = lookup.textFor('name');
        _phoneError =
            duplicatePhoneFieldError(l10n, e) ?? lookup.textFor('phone');
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        _bumpFooter();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phoneError = _phoneError;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
      child: Form(
        key: _formKey,
        autovalidateMode: _attemptedSubmit
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _nameCtrl,
              label: l10n.clientName,
              placeholder: l10n.clientNameHint,
              fieldHeight: AppSize.fieldHeightComfortable,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
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
              controller: _phoneCtrl,
              label: l10n.phoneOptional,
              placeholder: l10n.clientPhoneHint,
              fieldHeight: AppSize.fieldHeightComfortable,
              type: AppInputType.phone,
              ltrValue: true,
              textInputAction: TextInputAction.done,
              errorMessage: phoneError,
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
              validator: (value) => validateOptionalEgyptMobile(l10n, value),
            ),
          ],
        ),
      ),
    );
  }
}
