import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/sheet_drag_handle.dart';

class ItemCreateSheet extends ConsumerStatefulWidget {
  const ItemCreateSheet({super.key});

  @override
  ConsumerState<ItemCreateSheet> createState() => _ItemCreateSheetState();
}

class _ItemCreateSheetState extends ConsumerState<ItemCreateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  var _attemptedSubmit = false;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _attemptedSubmit = true);
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(repositoryProvider).createItem(
            name: _name.text.trim(),
            colorKey: 'teal',
            iconName: 'category',
          );
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
          Text(l10n.itemCreateSheetTitle, style: context.text.title),
          AppSize.spaceMD.gap,
          Form(
            key: _formKey,
            autovalidateMode:
                _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: CustomTextField(
              controller: _name,
              label: l10n.itemNameLabel,
              placeholder: l10n.itemNameHint,
              fieldHeight: AppSize.fieldHeightComfortable,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.itemNameRequired;
                }
                return null;
              },
            ),
          ),
          AppSize.spaceMD.gap,
          AppButton.primary(
            text: l10n.save,
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
