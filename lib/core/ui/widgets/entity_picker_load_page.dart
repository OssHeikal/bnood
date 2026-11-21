import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../services/config/extensions/num_extensions.dart';
import '../../services/config/theme/app_colors.dart';
import '../../services/config/theme/app_size.dart';
import '../layout/app_form_route_canvas.dart';
import 'app_fallback.dart';
import 'custom_app_bar.dart';
import 'entity_picker_page.dart';
import 'overlay_form_presentation.dart';
import 'skeleton/entity_picker_list_skeleton.dart';
import 'sheet_drag_handle.dart';

class EntityPickerLoadedBundle {
  const EntityPickerLoadedBundle({
    required this.entries,
    required this.tileBuilder,
    this.searchKeys,
    this.emptyTitle,
    this.emptyDescription,
  });

  final List<(String id, String label)> entries;
  final List<String>? searchKeys;
  final EntityPickerTileBuilder tileBuilder;
  final String? emptyTitle;
  final String? emptyDescription;
}

/// Opens immediately; loads roster behind a skeleton, then shows [EntityPickerPage] list UI.
class EntityPickerLoadPage extends StatefulWidget {
  const EntityPickerLoadPage({
    super.key,
    required this.title,
    required this.presentation,
    required this.load,
    required this.onCreateRoute,
    this.selectedId,
    this.onBeforeCreate,
  });

  final String title;
  final OverlayFormPresentation presentation;
  final String? selectedId;
  final Future<EntityPickerLoadedBundle> Function() load;
  final Widget Function() onCreateRoute;
  final Future<bool> Function(BuildContext context)? onBeforeCreate;

  @override
  State<EntityPickerLoadPage> createState() => _EntityPickerLoadPageState();
}

class _EntityPickerLoadPageState extends State<EntityPickerLoadPage> {
  EntityPickerLoadedBundle? _bundle;
  Object? _error;
  var _loading = true;
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final gen = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bundle = await widget.load();
      if (!mounted || gen != _generation) return;
      setState(() {
        _bundle = bundle;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || gen != _generation) return;
      setState(() {
        _error = e;
        _loading = false;
        _bundle = null;
      });
    }
  }

  Widget _chrome({required Widget body}) {
    final colors = context.colors;

    if (widget.presentation == OverlayFormPresentation.fullScreen) {
      return AppFormRouteCanvas(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: CustomAppBar(title: widget.title),
          body: body,
        ),
      );
    }

    return Material(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSize.screenPadding,
              AppSize.spaceSM,
              AppSize.screenPadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetDragHandle(),
                AppSize.spaceMD.gap,
                Row(
                  children: [
                    BackButton(onPressed: () => Navigator.maybePop(context)),
                    Expanded(
                      child: Text(widget.title, style: context.text.title),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSize.spaceMD.gap,
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _errorBody(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
        child: AppFallback.section(
          icon: Icons.error_outline,
          title: l10n.homeLoadErrorTitle,
          description: _error.toString(),
          actions: [
            AppFallbackAction(
              label: l10n.retry,
              onPressed: _fetch,
              role: AppFallbackActionRole.tertiary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return _chrome(body: const EntityPickerListSkeleton());
    }

    if (_error != null) {
      return _chrome(body: _errorBody(l10n));
    }

    final bundle = _bundle!;
    return EntityPickerPage(
      title: widget.title,
      presentation: widget.presentation,
      entries: bundle.entries,
      searchKeys: bundle.searchKeys,
      selectedId: widget.selectedId,
      emptyTitle: bundle.emptyTitle,
      emptyDescription: bundle.emptyDescription,
      tileBuilder: bundle.tileBuilder,
      onCreateRoute: widget.onCreateRoute,
      onBeforeCreate: widget.onBeforeCreate,
    );
  }
}
