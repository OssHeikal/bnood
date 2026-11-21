import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api/api_field_errors.dart';
import '../../../../core/network/api/auth_api_exception.dart';
import '../../../../core/ui/widgets/app_toaster.dart';
import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import 'package:bnood/features/items/data/item_api_record.dart';
import 'package:bnood/features/items/data/items_providers.dart';
import '../../../../core/ui/widgets/buttons/app_button.dart';
import '../../../../core/ui/widgets/custom_text_field.dart';
import '../../../../core/ui/widgets/app_modal_sheet.dart';
import '../../../../core/ui/widgets/sheet_footer_refresh.dart';
import '../../../../core/ui/widgets/sheet_form_header.dart';
import '../../../../core/ui/widgets/skeleton/async_value_body.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/items/presentation/actions/item_mutation_actions.dart';
import 'package:bnood/features/items/presentation/widgets/item_visual_pickers.dart';

Future<void> showItemEditSheet(
  BuildContext context, {
  required CatalogItem item,
}) {
  final formKey = GlobalKey<_ItemEditSheetState>();
  final footerRefresh = SheetFooterRefresh();
  final l10n = AppLocalizations.of(context);
  return AppModalSheet.show<void>(
    context: context,
    header: SheetFormHeader(title: l10n.itemEditSheetTitle),
    body: HomeFoundationScope(
      child: ItemEditSheet(
        key: formKey,
        item: item,
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
          children: state._footerActions(context, l10n),
        );
      },
    ),
  );
}

class ItemEditSheet extends ConsumerStatefulWidget {
  const ItemEditSheet({
    super.key,
    required this.item,
    required this.footerRefresh,
  });

  final CatalogItem item;
  final SheetFooterRefresh footerRefresh;

  @override
  ConsumerState<ItemEditSheet> createState() => _ItemEditSheetState();
}

class _ItemEditSheetState extends ConsumerState<ItemEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.item.name);
  var _attemptedSubmit = false;
  var _saving = false;
  String? _nameError;
  late String _iconKey = widget.item.iconKey;
  late String _colorKey = widget.item.colorKey;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _bumpFooter() => widget.footerRefresh.bump();

  List<Widget> _footerActions(BuildContext context, AppLocalizations l10n) {
    return [
      AppButton.primary(
        text: l10n.save,
        isLoading: _saving,
        onPressed: _saving ? null : _save,
      ),
      AppSize.spaceSM.gap,
      AppButton.outlined(
        key: const Key('item_edit_delete'),
        text: l10n.delete,
        foregroundColor: context.colors.error,
        borderColor: context.colors.outline,
        onPressed: _saving ? null : _delete,
      ),
    ];
  }

  Future<void> _save() async {
    setState(() {
      _attemptedSubmit = true;
      _nameError = null;
    });
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    _bumpFooter();
    try {
      final updated = await saveItemUpdate(
        ref: ref,
        context: context,
        itemId: widget.item.id,
        name: _nameCtrl.text.trim(),
        iconKey: _iconKey,
        colorKey: _colorKey,
      );
      if (updated != null && mounted) {
        final l10n = AppLocalizations.of(context);
        AppToaster.show(l10n.toastItemUpdated, kind: ToastKind.success);
        Navigator.pop(context);
      }
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final lookup = ApiFieldErrorLookup(e);
      final fieldError =
          duplicateItemNameFieldError(l10n, e) ?? lookup.textFor('name');
      if (fieldError != null) {
        setState(() => _nameError = fieldError);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        _bumpFooter();
      }
    }
  }

  Future<void> _delete() async {
    final deleted = await confirmDeleteItem(
      context,
      ref,
      itemId: widget.item.id,
      name: _nameCtrl.text.trim().isEmpty
          ? widget.item.name
          : _nameCtrl.text.trim(),
    );
    if (deleted && mounted) {
      final l10n = AppLocalizations.of(context);
      AppToaster.show(l10n.toastItemDeleted, kind: ToastKind.success);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(itemIconsCatalogProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        AppSize.spaceSM,
        AppSize.screenPadding,
        0,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: _attemptedSubmit
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _nameCtrl,
              label: l10n.itemNameLabel,
              placeholder: l10n.itemNameHint,
              fieldHeight: AppSize.fieldHeightComfortable,
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
            AppSize.spaceLG.gap,
            AsyncValueBody(
              value: catalog,
              loadingPlaceholder: const SizedBox(height: 120),
              error: (e, _) => Text(e.toString()),
              data: (data) => ItemVisualPickers(
                catalog: data,
                selectedIconKey: _iconKey,
                selectedColorKey: _colorKey,
                onIconKey: (v) => setState(() => _iconKey = v),
                onColorKey: (v) => setState(() => _colorKey = v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
