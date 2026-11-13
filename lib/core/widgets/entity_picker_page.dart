import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../config/extensions/num_extensions.dart';
import '../layout/bnood_form_route_canvas.dart';
import '../config/extensions/text_style_extensions.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_size.dart';
import 'app_fallback.dart';
import 'app_pressable.dart';
import 'custom_app_bar.dart';
import 'custom_text_field.dart';
import 'entity_picker_row.dart';
import 'bounded_sheet_navigator.dart';
import 'overlay_form_presentation.dart';
import 'sheet_drag_handle.dart';

typedef EntityPickerTileBuilder =
    Widget Function(BuildContext context, String id, bool selected, VoidCallback onSelect, bool showDivider);

/// Searchable entity list; pops with selected id string.
class EntityPickerPage extends StatefulWidget {
  const EntityPickerPage({
    super.key,
    required this.title,
    required this.entries,
    required this.onCreateRoute,
    this.selectedId,
    this.searchKeys,
    this.tileBuilder,
    this.emptyTitle,
    this.emptyDescription,
    this.onBeforeCreate,
    this.presentation = OverlayFormPresentation.inSheet,
  });

  final String title;
  final List<(String id, String label)> entries;
  final Widget Function() onCreateRoute;
  final Future<bool> Function(BuildContext context)? onBeforeCreate;
  final String? selectedId;
  final List<String>? searchKeys;
  final EntityPickerTileBuilder? tileBuilder;
  final String? emptyTitle;
  final String? emptyDescription;
  final OverlayFormPresentation presentation;

  @override
  State<EntityPickerPage> createState() => _EntityPickerPageState();
}

class _EntityPickerPageState extends State<EntityPickerPage> {
  late final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _blobForIndex(int index) {
    final label = widget.entries[index].$2;
    final extra = widget.searchKeys != null && index < widget.searchKeys!.length ? widget.searchKeys![index] : '';
    return '$label $extra'.toLowerCase();
  }

  List<int> get _filteredIndices {
    final q = _search.text.trim().toLowerCase();
    final out = <int>[];
    for (var i = 0; i < widget.entries.length; i++) {
      if (q.isEmpty || _blobForIndex(i).contains(q)) out.add(i);
    }
    return out;
  }

  Future<void> _create() async {
    if (widget.onBeforeCreate != null) {
      final allowed = await widget.onBeforeCreate!(context);
      if (!allowed || !mounted) return;
    }
    final created = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => widget.onCreateRoute()));
    if (created != null && mounted) {
      Navigator.pop(context, created);
    }
  }

  Widget _searchField(AppLocalizations l10n) {
    return CustomTextField.search(
      controller: _search,
      placeholder: l10n.voucherPickerSearchHint,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _listBody(AppLocalizations l10n, List<int> indices, bool isCompletelyEmpty, bool isSearchEmpty) {
    if (isCompletelyEmpty || isSearchEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
        child: AppFallback.section(
          icon: Icons.search_off_outlined,
          title: isCompletelyEmpty ? (widget.emptyTitle ?? l10n.voucherPickerEmptyTitle) : l10n.voucherPickerNoResults,
          description: isCompletelyEmpty ? widget.emptyDescription : null,
          actions: [
            AppFallbackAction(
              label: l10n.createNew,
              onPressed: _create,
              role: AppFallbackActionRole.primary,
              icon: Icons.add,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSize.spaceLG),
      itemCount: indices.length,
      itemBuilder: (context, listIndex) {
        final index = indices[listIndex];
        final entry = widget.entries[index];
        final selected = widget.selectedId == entry.$1;
        final isLast = listIndex == indices.length - 1;
        void onSelect() => Navigator.pop(context, entry.$1);
        if (widget.tileBuilder != null) {
          return widget.tileBuilder!(context, entry.$1, selected, onSelect, !isLast);
        }
        return EntityPickerOptionRow(
          selected: selected,
          onSelect: onSelect,
          leadingWidth: AppSize.hitMin,
          showDivider: !isLast,
          leading: CircleAvatar(child: Text(entry.$2.characters.first)),
          title: entry.$2,
        );
      },
    );
  }

  Widget? _createFooter(AppLocalizations l10n, bool showCreateRow) {
    if (!showCreateRow) return null;
    final colors = context.colors;
    final media = MediaQuery.of(context);
    final inModal = widget.presentation != OverlayFormPresentation.fullScreen;
    final bottomPad = SheetChromeInsets.sheetFooterBottomPadding(
      media: media,
      outerModalChromeApplied: inModal,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSize.screenPadding, AppSize.spaceSM, AppSize.screenPadding, bottomPad),
      child: AppPressable(
        onPressed: _create,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppSize.spaceSM,
          children: [
            Icon(Icons.add, color: colors.primary, size: AppSize.icon),
            Text(l10n.createNew, style: context.text.body.semiBold.setColor(colors.primaryDark)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final indices = _filteredIndices;
    final isCompletelyEmpty = widget.entries.isEmpty;
    final isSearchEmpty = !isCompletelyEmpty && indices.isEmpty;
    final showCreateRow = !isCompletelyEmpty && !isSearchEmpty;
    final footer = _createFooter(l10n, showCreateRow);

    if (widget.presentation == OverlayFormPresentation.fullScreen) {
      return BnoodFormRouteCanvas(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: CustomAppBar(title: widget.title),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSize.screenPadding, AppSize.spaceMD, AppSize.screenPadding, 0),
                child: _searchField(l10n),
              ),
              AppSize.spaceMD.gap,
              Expanded(child: _listBody(l10n, indices, isCompletelyEmpty, isSearchEmpty)),
              if (footer != null) SafeArea(top: false, child: footer),
            ],
          ),
        ),
      );
    }

    return Material(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSize.screenPadding, AppSize.spaceSM, AppSize.screenPadding, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetDragHandle(),
                AppSize.spaceMD.gap,
                Row(
                  children: [
                    BackButton(onPressed: () => Navigator.maybePop(context)),
                    Expanded(child: Text(widget.title, style: context.text.title)),
                  ],
                ),
                AppSize.spaceMD.gap,
                _searchField(l10n),
              ],
            ),
          ),
          AppSize.spaceMD.gap,
          Expanded(child: _listBody(l10n, indices, isCompletelyEmpty, isSearchEmpty)),
          ?footer,
        ],
      ),
    );
  }
}
