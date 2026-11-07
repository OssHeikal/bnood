import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../home/home_foundation_scope.dart';

Future<void> showClientEditSheet({
  required BuildContext context,
  required String clientId,
  required String clientName,
  String? phone,
}) {
  return BnoodModalSheet.show<void>(
    context: context,
    builder: (_) => HomeFoundationScope(
      child: ClientEditSheet(
        clientId: clientId,
        clientName: clientName,
        phone: phone,
      ),
    ),
  );
}

class ClientEditSheet extends ConsumerStatefulWidget {
  const ClientEditSheet({
    super.key,
    required this.clientId,
    required this.clientName,
    this.phone,
  });

  final String clientId;
  final String clientName;
  final String? phone;

  @override
  ConsumerState<ClientEditSheet> createState() => _ClientEditSheetState();
}

class _ClientEditSheetState extends ConsumerState<ClientEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.clientName);
  late final _phoneCtrl = TextEditingController(text: widget.phone ?? '');
  var _attemptedSubmit = false;
  var _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _attemptedSubmit = true);
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(repositoryProvider).updateClient(
            clientId: widget.clientId,
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty ? '' : _phoneCtrl.text.trim(),
          );
      refreshAfterClientMutation(ref, clientId: widget.clientId);
      if (mounted) Navigator.pop(context);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetDragHandle(),
          AppSize.spaceMD.gap,
          Text(l10n.edit, style: context.text.title),
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
                  label: l10n.clientName,
                  placeholder: l10n.clientNameHint,
                  fieldHeight: AppSize.fieldHeightComfortable,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
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
                ),
              ],
            ),
          ),
          AppSize.spaceLG.gap,
          AppButton.primary(text: l10n.save, isLoading: _saving, onPressed: _saving ? null : _save),
        ],
      ),
    );
  }
}
