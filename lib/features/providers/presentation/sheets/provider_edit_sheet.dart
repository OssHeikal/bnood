import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api/api_field_errors.dart';
import '../../../../core/network/api/auth_api_exception.dart';
import '../../../../core/domain/validation/egypt_mobile_phone_validation.dart';
import '../../../../core/ui/widgets/app_toaster.dart';
import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import 'package:bnood/features/providers/data/app_provider_record.dart';
import '../../../../core/ui/widgets/buttons/app_button.dart';
import '../../../../core/ui/widgets/app_modal_sheet.dart';
import '../../../../core/ui/widgets/custom_text_field.dart';
import '../../../../core/ui/widgets/sheet_footer_refresh.dart';
import '../../../../core/ui/widgets/sheet_form_header.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/providers/presentation/actions/provider_mutation_actions.dart';

Future<void> showProviderEditSheet(
  BuildContext context, {
  required AppProvider provider,
}) {
  final formKey = GlobalKey<_ProviderEditSheetState>();
  final footerRefresh = SheetFooterRefresh();
  final l10n = AppLocalizations.of(context);
  return AppModalSheet.show<void>(
    context: context,
    scrollable: false,
    header: SheetFormHeader(title: l10n.edit),
    body: HomeFoundationScope(
      child: ProviderEditSheet(
        key: formKey,
        provider: provider,
        footerRefresh: footerRefresh,
      ),
    ),
    footer: ListenableBuilder(
      listenable: footerRefresh,
      builder: (context, _) {
        final state = formKey.currentState;
        if (state == null) return const SizedBox.shrink();
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton.primary(
              text: l10n.save,
              isLoading: state._saving,
              onPressed: state._saving ? null : state._save,
            ),
            AppSize.spaceSM.gap,
            AppButton.outlined(
              text: l10n.delete,
              foregroundColor: context.colors.onSurface,
              borderColor: context.colors.outline,
              onPressed: state._saving ? null : state._delete,
            ),
          ],
        );
      },
    ),
  );
}

class ProviderEditSheet extends ConsumerStatefulWidget {
  const ProviderEditSheet({
    super.key,
    required this.provider,
    required this.footerRefresh,
  });

  final AppProvider provider;
  final SheetFooterRefresh footerRefresh;

  @override
  ConsumerState<ProviderEditSheet> createState() => _ProviderEditSheetState();
}

class _ProviderEditSheetState extends ConsumerState<ProviderEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.provider.name);
  late final _phoneCtrl = TextEditingController(
    text: widget.provider.phone ?? '',
  );
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
    try {
      final updated = await saveProviderUpdate(
        ref: ref,
        context: context,
        providerId: widget.provider.id,
        name: _nameCtrl.text.trim(),
        phoneField: _phoneCtrl.text,
      );
      if (updated != null && mounted) {
        final l10n = AppLocalizations.of(context);
        AppToaster.show(l10n.toastProviderUpdated, kind: ToastKind.success);
        Navigator.pop(context);
      }
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final lookup = ApiFieldErrorLookup(e);
      setState(() {
        _nameError =
            duplicateProviderNameFieldError(l10n, e) ?? lookup.textFor('name');
        _phoneError =
            duplicateProviderPhoneFieldError(l10n, e) ??
            lookup.textFor('phone');
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        _bumpFooter();
      }
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
      padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            kindMeta,
            style: context.text.caption.copyWith(
              color: context.colors.onSurfaceMuted,
            ),
          ),
          AppSize.spaceMD.gap,
          Form(
            key: _formKey,
            autovalidateMode: _attemptedSubmit
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
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
                  onChanged: (_) {
                    if (_phoneError != null) setState(() => _phoneError = null);
                  },
                  validator: (value) =>
                      validateOptionalEgyptMobile(l10n, value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
