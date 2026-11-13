import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_field_errors.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/items/items_providers.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/bounded_sheet_navigator.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import 'item_mutation_actions.dart';
import 'widgets/item_visual_pickers.dart';

class ItemCreateSheet extends ConsumerStatefulWidget {
  const ItemCreateSheet({
    super.key,
    this.returnCreatedItemId = false,
    this.showSheetChrome = true,
  });

  final bool returnCreatedItemId;
  /// When false, expect an outer [Scaffold] app bar (voucher full-screen create).
  final bool showSheetChrome;

  @override
  ConsumerState<ItemCreateSheet> createState() => _ItemCreateSheetState();
}

class _ItemCreateSheetState extends ConsumerState<ItemCreateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  var _attemptedSubmit = false;
  var _saving = false;
  String? _nameError;
  String _iconKey = 'layers';
  String _colorKey = 'teal';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _attemptedSubmit = true;
      _nameError = null;
    });
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    try {
      final item = await saveItemCreate(
        ref: ref,
        context: context,
        name: _name.text.trim(),
        iconKey: _iconKey,
        colorKey: _colorKey,
      );
      if (item != null && mounted) {
        AppToaster.show(l10n.toastItemCreated, kind: ToastKind.success);
        Navigator.pop(context, widget.returnCreatedItemId ? item.id : null);
      }
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final lookup = ApiFieldErrorLookup(e);
      final fieldError = duplicateItemNameFieldError(l10n, e) ?? lookup.textFor('name');
      if (fieldError != null) {
        setState(() => _nameError = fieldError);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(itemIconsCatalogProvider);
    final bottomPad = SheetChromeInsets.sheetFooterBottomPadding(
      media: MediaQuery.of(context),
      outerModalChromeApplied: widget.showSheetChrome,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        widget.showSheetChrome ? AppSize.spaceSM : AppSize.spaceMD,
        AppSize.screenPadding,
        bottomPad,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showSheetChrome) ...[
              const SheetDragHandle(),
              AppSize.spaceMD.gap,
              Text(l10n.itemCreateSheetTitle, style: context.text.title),
              AppSize.spaceMD.gap,
            ],
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
                errorMessage: _nameError,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.itemNameRequired;
                  }
                  return null;
                },
              ),
            ),
            AppSize.spaceMD.gap,
            AsyncValueBody(
              value: catalog,
              loadingPlaceholder: const SizedBox(height: 120),
              error: (e, _) => Text(e.toString()),
              data: (data) {
                final icons = data.iconKeys;
                final colors = data.colors.map((c) => c.key).toList();
                if (icons.isNotEmpty && !icons.contains(_iconKey)) {
                  _iconKey = icons.first;
                }
                if (colors.isNotEmpty && !colors.contains(_colorKey)) {
                  _colorKey = colors.first;
                }
                return ItemVisualPickers(
                  catalog: data,
                  selectedIconKey: _iconKey,
                  selectedColorKey: _colorKey,
                  onIconKey: (v) => setState(() => _iconKey = v),
                  onColorKey: (v) => setState(() => _colorKey = v),
                );
              },
            ),
            AppSize.spaceMD.gap,
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
