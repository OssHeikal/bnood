import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../home/home_foundation_scope.dart';
import 'items_archive.dart';

Future<void> showItemEditSheet(
  BuildContext context, {
  required String itemId,
  required String name,
}) {
  return BnoodModalSheet.show<void>(
    context: context,
    builder: (_) => HomeFoundationScope(
      child: ItemEditSheet(itemId: itemId, name: name),
    ),
  );
}

class ItemEditSheet extends ConsumerStatefulWidget {
  const ItemEditSheet({
    super.key,
    required this.itemId,
    required this.name,
  });

  final String itemId;
  final String name;

  @override
  ConsumerState<ItemEditSheet> createState() => _ItemEditSheetState();
}

class _ItemEditSheetState extends ConsumerState<ItemEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.name);
  var _attemptedSubmit = false;
  var _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _attemptedSubmit = true);
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(repositoryProvider).updateItem(
            id: widget.itemId,
            name: _nameCtrl.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _archive() async {
    final archived = await confirmArchiveItem(
      context,
      ref,
      itemId: widget.itemId,
      name: _nameCtrl.text.trim().isEmpty ? widget.name : _nameCtrl.text.trim(),
    );
    if (archived && mounted) Navigator.pop(context);
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
          Text(l10n.itemEditSheetTitle, style: context.text.title),
          AppSize.spaceMD.gap,
          Form(
            key: _formKey,
            autovalidateMode:
                _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: CustomTextField(
              controller: _nameCtrl,
              label: l10n.itemNameLabel,
              placeholder: l10n.itemNameHint,
              fieldHeight: AppSize.fieldHeightComfortable,
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
          AppSize.spaceSM.gap,
          AppButton.outlined(
            text: l10n.archive,
            foregroundColor: context.colors.onSurface,
            borderColor: context.colors.outline,
            onPressed: _saving ? null : _archive,
          ),
        ],
      ),
    );
  }
}
