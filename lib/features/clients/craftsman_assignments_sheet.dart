import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/extensions/text_style_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/database/database.dart';
import '../../core/money/ledger_math.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/widgets/bounded_sheet_navigator.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../../core/widgets/skeleton/skeleton.dart';
import '../home/home_foundation_scope.dart';
import '../vouchers/inline_create_routes.dart';
import 'craftsman_agreement_amount_sheet.dart';
import 'widgets/craftsman_roster_choice_row.dart';

Future<void> showCraftsmanAssignmentsSheet({
  required BuildContext context,
  required String projectId,
  String? clientId,
}) {
  return BnoodModalSheet.show<void>(
    context: context,
    builder: (_) => HomeFoundationScope(
      child: _CraftsmanAssignmentsModalHost(
        projectId: projectId,
        clientId: clientId,
      ),
    ),
  );
}

class _CraftsmanAssignmentsModalHost extends StatelessWidget {
  const _CraftsmanAssignmentsModalHost({
    required this.projectId,
    this.clientId,
  });

  final String projectId;
  final String? clientId;

  @override
  Widget build(BuildContext context) {
    return BoundedSheetNavigator(
      builder: (_) => CraftsmanAssignmentsSheet(
        projectId: projectId,
        clientId: clientId,
      ),
    );
  }
}

class CraftsmanAssignmentsSheet extends ConsumerStatefulWidget {
  const CraftsmanAssignmentsSheet({
    super.key,
    required this.projectId,
    this.clientId,
    this.embedInModalChrome = true,
  });

  final String projectId;
  final String? clientId;

  /// When false (widget tests), renders roster body only.
  final bool embedInModalChrome;

  @override
  ConsumerState<CraftsmanAssignmentsSheet> createState() => _CraftsmanAssignmentsSheetState();
}

class _CraftsmanAssignmentsSheetState extends ConsumerState<CraftsmanAssignmentsSheet> {
  final _selected = <String>{};
  final _selectionLocked = <String>{};
  final _baselineAmountPiastres = <String, int?>{};
  final _draftAmountPiastres = <String, int?>{};

  List<CraftsmenData> _roster = [];
  String _clientName = '';
  var _loading = true;
  Object? _error;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(repositoryProvider);
      final roster = await repo.listActiveCraftsmen();
      final agreements = await repo.agreementsForProject(widget.projectId);
      final transactions = await repo.transactionsForProject(widget.projectId);
      final project = await repo.projectById(widget.projectId);
      var clientName = project?.name ?? '—';
      if (widget.clientId != null) {
        final client = await repo.getClient(widget.clientId!);
        clientName = client.name;
      } else if (project != null) {
        final info = await repo.clientInfoForProjectIds([project.id]);
        clientName = info[project.id]?.clientName ?? clientName;
      }

      final selected = <String>{};
      final locked = <String>{};
      final baseline = <String, int?>{};
      final agreementByCraftsman = {for (final a in agreements) a.craftsmanId: a};
      for (final c in roster) {
        final ag = agreementByCraftsman[c.id];
        if (ag == null) continue;
        selected.add(c.id);
        baseline[c.id] = ag.initialAmountPiastres;
        final paid = LedgerMath.craftsmanPaidPiastres(rows: transactions, craftsmanId: c.id);
        if (paid > 0) locked.add(c.id);
      }

      if (mounted) {
        setState(() {
          _roster = roster;
          _clientName = clientName;
          _selected
            ..clear()
            ..addAll(selected);
          _selectionLocked
            ..clear()
            ..addAll(locked);
          _baselineAmountPiastres
            ..clear()
            ..addAll(baseline);
          _draftAmountPiastres.clear();
          _loading = false;
        });
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
        debugPrintStack(stackTrace: st, label: 'craftsman roster load failed');
      }
    }
  }

  int? _resolvedAmountPiastres(String craftsmanId) {
    if (_draftAmountPiastres.containsKey(craftsmanId)) {
      return _draftAmountPiastres[craftsmanId];
    }
    return _baselineAmountPiastres[craftsmanId];
  }

  int? _amountForPersist(String craftsmanId) {
    if (_draftAmountPiastres.containsKey(craftsmanId)) {
      return _draftAmountPiastres[craftsmanId];
    }
    if (_baselineAmountPiastres.containsKey(craftsmanId)) {
      return _baselineAmountPiastres[craftsmanId];
    }
    return null;
  }

  bool _showAmountSummary(String craftsmanId) {
    if (_draftAmountPiastres.containsKey(craftsmanId)) return true;
    final baseline = _baselineAmountPiastres[craftsmanId];
    return baseline != null;
  }

  Future<void> _openCreateCraftsman() async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const InlineCreateCraftsmanPage(
          padForSystemChrome: false,
          preferContentHeight: true,
        ),
      ),
    );
    if (id == null || !mounted) return;
    final roster = await ref.read(repositoryProvider).listActiveCraftsmen();
    setState(() {
      _roster = roster;
      _selected.add(id);
    });
  }

  Future<void> _openAmountSheet(CraftsmenData craftsman) async {
    final initial = _resolvedAmountPiastres(craftsman.id);
    final saved = await Navigator.of(context).push<CraftsmanAgreementAmountDraftResult>(
      MaterialPageRoute(
        builder: (_) => CraftsmanAgreementAmountPage(
          entry: CraftsmanAgreementAmountEntry.rosterDraft,
          projectId: widget.projectId,
          craftsmanName: craftsman.name,
          clientName: _clientName,
          initialAmountPiastres: initial,
        ),
      ),
    );
    if (!mounted || saved == null) return;
    setState(() => _draftAmountPiastres[craftsman.id] = saved.initialAmountPiastres);
  }

  void _toggleSelection(String craftsmanId) {
    if (_selectionLocked.contains(craftsmanId)) return;
    setState(() {
      if (_selected.contains(craftsmanId)) {
        _selected.remove(craftsmanId);
        if (!_baselineAmountPiastres.containsKey(craftsmanId)) {
          _draftAmountPiastres.remove(craftsmanId);
        }
      } else {
        _selected.add(craftsmanId);
      }
    });
  }

  void _closeHostModal() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _save() async {
    if (_saving || _roster.isEmpty) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(repositoryProvider);
      final agreements = await repo.agreementsForProject(widget.projectId);

      for (final ag in agreements) {
        if (_selected.contains(ag.craftsmanId)) continue;
        if (_selectionLocked.contains(ag.craftsmanId)) continue;
        await repo.removeCraftsmanFromProject(
          projectId: widget.projectId,
          craftsmanId: ag.craftsmanId,
        );
      }

      for (final craftsmanId in _selected) {
        final amount = _amountForPersist(craftsmanId);
        if (amount == null) {
          await repo.upsertAgreement(
            projectId: widget.projectId,
            craftsmanId: craftsmanId,
            clearInitial: true,
          );
        } else {
          await repo.upsertAgreement(
            projectId: widget.projectId,
            craftsmanId: craftsmanId,
            initialAmountPiastres: amount,
          );
        }
      }

      refreshAfterClientMutation(ref, clientId: widget.clientId);
      if (!mounted) return;
      _closeHostModal();
      AppToaster.show(
        AppLocalizations.of(context).crewAssignmentsSaved,
        kind: ToastKind.success,
      );
    } catch (e) {
      if (mounted) {
        AppToaster.show(e.toString(), kind: ToastKind.failure);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildHeader(AppLocalizations l10n, AppColors colors) {
    if (!widget.embedInModalChrome) return const SizedBox.shrink();
    return Padding(
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
          Text(l10n.assignCraftsmen, style: context.text.title),
          AppSize.spaceXS.gap,
          Text(
            l10n.crewAssignmentsIntro,
            style: context.text.caption.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterBody(AppLocalizations l10n, AppColors colors, String localeCode) {
    if (_loading) {
      return const _RosterSkeleton();
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
        child: AppFallback.section(
          icon: Icons.error_outline,
          title: l10n.homeLoadErrorTitle,
          description: _error.toString(),
          actions: [
            AppFallbackAction(
              label: l10n.retry,
              onPressed: _bootstrap,
              role: AppFallbackActionRole.tertiary,
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
          child: Text(
            l10n.crewAssignmentsProjectContext(_clientName),
            style: context.text.supporting.copyWith(color: colors.onSurfaceMuted),
          ),
        ),
        AppSize.spaceMD.gap,
        if (_roster.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
            child: AppFallback.section(
              icon: Icons.handyman_outlined,
              title: l10n.directoryEmptyCraftsmenTitle,
              description: l10n.directoryEmptyCraftsmenDescription,
              actions: [
                AppFallbackAction(
                  label: l10n.directoryAddCraftsmanToRoster,
                  onPressed: _openCreateCraftsman,
                  role: AppFallbackActionRole.tertiary,
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < _roster.length; i++)
            CraftsmanRosterChoiceRow(
              craftsman: _roster[i],
              selected: _selected.contains(_roster[i].id),
              selectionLocked: _selectionLocked.contains(_roster[i].id),
              onToggle: () => _toggleSelection(_roster[i].id),
              showDivider: i < _roster.length - 1,
              localeCode: localeCode,
              showAmountSummary: _selected.contains(_roster[i].id) &&
                  _showAmountSummary(_roster[i].id),
              agreedPiastres: _resolvedAmountPiastres(_roster[i].id),
              onManageAmount: _selected.contains(_roster[i].id)
                  ? () => _openAmountSheet(_roster[i])
                  : null,
            ),
        if (_roster.isNotEmpty) ...[
          AppSize.spaceSM.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
            child: AppPressable(
              onPressed: _openCreateCraftsman,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppSize.spaceSM,
                children: [
                  Icon(Icons.add, color: colors.primary, size: AppSize.icon),
                  Flexible(
                    child: Text(
                      l10n.directoryAddCraftsmanToRoster,
                      style: context.text.body.semiBold.setColor(colors.primaryDark),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveFooter(AppLocalizations l10n) {
    if (_loading || _error != null) return const SizedBox.shrink();
    final viewPadding = MediaQuery.viewPaddingOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        AppSize.spaceLG,
        AppSize.screenPadding,
        AppSize.spaceMD + (widget.embedInModalChrome ? viewPadding.bottom : 0),
      ),
      child: AppButton.primary(
        key: const Key('craftsman_assignments_save'),
        text: l10n.save,
        isLoading: _saving,
        onPressed: _roster.isEmpty || _saving ? null : _save,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final localeCode = Localizations.localeOf(context).languageCode;

    if (!widget.embedInModalChrome) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRosterBody(l10n, colors, localeCode),
          _buildSaveFooter(l10n),
        ],
      );
    }

    return Material(
      color: colors.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cap = SheetContentBounds.maxHeight(constraints, MediaQuery.of(context));
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: cap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(l10n, colors),
                        AppSize.spaceMD.gap,
                        _buildRosterBody(l10n, colors, localeCode),
                      ],
                    ),
                  ),
                ),
                _buildSaveFooter(l10n),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RosterSkeleton extends StatelessWidget {
  const _RosterSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Skeleton(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSize.spaceLG),
          ],
        ),
      ),
    );
  }
}
