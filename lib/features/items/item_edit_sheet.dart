import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_field_errors.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/items/item_api_record.dart';
import '../../core/items/items_providers.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/app_modal_sheet.dart';
import '../../core/widgets/sheet_footer_refresh.dart';
import '../../core/widgets/sheet_form_header.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../home/home_foundation_scope.dart';
import 'item_mutation_actions.dart';
import 'widgets/item_visual_pickers.dart';

Future<void> showItemEditSheet(
  BuildContext context, {
  required CatalogItem item,
}) {
  final formKey = GlobalKey<_ItemEditSheetState>();
  final footerRefresh = SheetFooterRefresh();
  final l10n = AppLocalizations.of(context);
  return AppModalSheet.show<void>(
    context: context,
    scrollable: false,
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
    final archived = widget.item.isArchived;
    final children = <Widget>[
      AppButton.primary(
        text: l10n.save,
        isLoading: _saving,
        onPressed: _saving ? null : _save,
      ),
    ];
    if (archived) {
      children
        ..add(AppSize.spaceSM.gap)
        ..add(
          AppButton.outlined(
            text: l10n.unarchive,
            foregroundColor: context.colors.onSurface,
            borderColor: context.colors.outline,
            onPressed: _saving ? null : _unarchive,
          ),
        );
    } else {
      children
        ..add(AppSize.spaceSM.gap)
        ..add(
          AppButton.outlined(
            text: l10n.delete,
            foregroundColor: context.colors.onSurface,
            borderColor: context.colors.outline,
            onPressed: _saving ? null : _delete,
          ),
        );
    }
    return children;
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
      final fieldError = duplicateItemNameFieldError(l10n, e) ?? lookup.textFor('name');
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
      name: _nameCtrl.text.trim().isEmpty ? widget.item.name : _nameCtrl.text.trim(),
    );
    if (deleted && mounted) {
      final l10n = AppLocalizations.of(context);
      AppToaster.show(l10n.toastItemDeleted, kind: ToastKind.success);
      Navigator.pop(context);
    }
  }

  Future<void> _unarchive() async {
    final restored = await performItemUnarchive(
      context: context,
      ref: ref,
      itemId: widget.item.id,
    );
    if (restored && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(itemIconsCatalogProvider);
    return Form(
      key: _formKey,
      autovalidateMode: _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
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
          AppSize.spaceMD.gap,
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
    );
  }
}