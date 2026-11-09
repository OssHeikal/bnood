import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_foundation_scope.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/database/database.dart';
import '../../core/money/ledger_math.dart' show LedgerMath, StatementPeriodTotals;
import '../../core/money/period_bounds.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/foundation_app_bar.dart';
import '../../core/widgets/toast/app_toast.dart';
import 'pdf_statement_service.dart';
import 'statement_pdf_export.dart';
import 'statement_screen_toast.dart';
import 'statement_client_document.dart';
import 'statement_export_store.dart';
import 'statement_pdf_copy.dart';
import 'statement_period_controls.dart';
import 'statement_period_logic.dart';
import 'statement_prefs_access.dart';

class ClientStatementScreen extends ConsumerStatefulWidget {
  const ClientStatementScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<ClientStatementScreen> createState() => _ClientStatementScreenState();
}

class _ClientStatementScreenState extends ConsumerState<ClientStatementScreen> {
  final _sharePdfButtonKey = GlobalKey();
  StatementPeriodPreset _preset = StatementPeriodPreset.month;
  late PeriodBounds _bounds = StatementPeriodLogic.monthBounds();
  StatementExportRecord? _lastExport;
  bool _exporting = false;
  bool _prefsAvailable = true;
  List<Transaction> _allRows = const [];
  Future<_StatementData>? _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadExportCursor();
  }

  void _startLoad(BnoodRepository repo) {
    _loadFuture = _load(repo);
  }

  Future<void> _loadExportCursor() async {
    try {
      final prefs = await StatementPrefsAccess.getInstance();
      if (prefs == null) {
        if (mounted) {
          setState(() {
            _prefsAvailable = false;
            _lastExport = null;
          });
        }
        return;
      }
      final repo = ref.read(repositoryProvider);
      final store = StatementExportStore(prefs);
      final ws = await repo.workspaceId();
      final record = store.read(workspaceId: ws, kind: StatementEntityKind.client, entityId: widget.clientId);
      if (mounted) {
        setState(() {
          _prefsAvailable = true;
          _lastExport = record;
        });
      }
    } catch (e, st) {
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st));
      if (mounted) {
        setState(() {
          _prefsAvailable = false;
          _lastExport = null;
        });
      }
    }
  }

  PeriodBounds _resolvePreset(StatementPeriodPreset preset) {
    return switch (preset) {
      StatementPeriodPreset.today => StatementPeriodLogic.todayBounds(),
      StatementPeriodPreset.month => StatementPeriodLogic.monthBounds(),
      StatementPeriodPreset.all => StatementPeriodLogic.allTimeBounds(_allRows),
      StatementPeriodPreset.sinceLastExport => StatementPeriodLogic.sinceLastExportBounds(_lastExport) ?? _bounds,
      StatementPeriodPreset.custom => _bounds,
    };
  }

  bool get _sinceLastExportAvailable =>
      _prefsAvailable && StatementPeriodLogic.sinceLastExportBounds(_lastExport) != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(repositoryProvider);
    final localeCode = Localizations.localeOf(context).languageCode;
    _loadFuture ??= _load(repo);

    return HomeFoundationScope(
      child: FutureBuilder<_StatementData>(
        future: _loadFuture,
        builder: (context, snap) {
          final colors = context.colors;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: FoundationAppBar(title: l10n.statement),
            body: _buildBody(context, snap, repo, localeCode),
            bottomNavigationBar: snap.hasData
                ? Material(
                    color: colors.canvas,
                    elevation: 0,
                    child: SafeArea(
                      top: false,
                      minimum: const EdgeInsets.fromLTRB(
                        AppSize.screenPadding,
                        AppSize.spaceSM,
                        AppSize.screenPadding,
                        AppSize.spaceMD,
                      ),
                      child: AppButton(
                        key: _sharePdfButtonKey,
                        text: l10n.sharePdf,
                        iconWidget: Assets.icons.shareOutline.svg(
                          width: AppSize.iconCompact,
                          height: AppSize.iconCompact,
                        ),
                        isLoading: _exporting,
                        onPressed: _exporting ? null : () => _exportPdf(snap.data!, l10n),
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<_StatementData> snap, BnoodRepository repo, String localeCode) {
    if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snap.hasError) {
      return Center(child: Text(snap.error.toString()));
    }
    final data = snap.data!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        AppSize.spaceMD,
        AppSize.screenPadding,
        AppSize.spaceMD,
      ),
      children: [
        StatementPeriodControls(
          bounds: _bounds,
          preset: _preset,
          lastExport: _lastExport,
          sinceLastExportAvailable: _sinceLastExportAvailable,
          onChanged: (b, preset) {
            setState(() {
              _preset = preset;
              _bounds = preset == StatementPeriodPreset.custom ? b : _resolvePreset(preset);
              _startLoad(repo);
            });
          },
        ),
        const SizedBox(height: AppSize.spaceMD),
        StatementClientDocument(
          clientName: data.client.name,
          unitAddress: data.unitAddress,
          totals: data.totals,
          periodReceive: data.periodReceive,
          periodSpend: data.periodSpend,
          itemNames: data.itemNames,
          supplierNames: data.supplierNames,
          craftsmanNames: data.craftsmanNames,
          localeCode: localeCode,
          showPeriodOpening: _preset != StatementPeriodPreset.all,
        ),
      ],
    );
  }

  Future<_StatementData> _load(BnoodRepository repo) async {
    final client = await repo.getClient(widget.clientId);
    final project = await repo.primaryActiveProject(widget.clientId);
    if (project == null) throw StateError('missing');
    final rows = await repo.transactionsForProject(project.id);
    _allRows = rows;
    final totals = LedgerMath.periodTotals(projectRows: rows, periodStart: _bounds.start, periodEnd: _bounds.end);
    final periodSpend = rows.where((t) => t.kind == 'spend' && _bounds.containsLocalDate(t.date)).toList();
    final periodReceive = rows.where((t) => t.kind == 'receive' && _bounds.containsLocalDate(t.date)).toList();
    final items = await repo.activeItems();
    final itemNames = {for (final i in items) i.id: i.name};
    final supplierNames = await _partyMap(repo, periodSpend.map((t) => t.supplierId));
    final craftsmanNames = await _partyMap(repo, periodSpend.map((t) => t.craftsmanId), craftsman: true);
    return _StatementData(
      client: client,
      unitAddress: project.unitAddress,
      totals: totals,
      periodSpend: periodSpend,
      periodReceive: periodReceive,
      itemNames: itemNames,
      supplierNames: supplierNames,
      craftsmanNames: craftsmanNames,
    );
  }

  Future<Map<String, String>> _partyMap(BnoodRepository repo, Iterable<String?> ids, {bool craftsman = false}) async {
    final map = <String, String>{};
    for (final id in ids.whereType<String>().toSet()) {
      if (craftsman) {
        final c = await repo.getCraftsman(id);
        if (c != null) map[id] = c.name;
      } else {
        final s = await repo.getSupplier(id);
        if (s != null) map[id] = s.name;
      }
    }
    return map;
  }

  Future<void> _exportPdf(_StatementData data, AppLocalizations l10n) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    const fileName = 'bnood-client-statement.pdf';
    try {
      final copy = StatementPdfCopy(l10n);
      late final Uint8List bytes;
      try {
        bytes = await PdfStatementService().buildClientStatement(
          client: data.client,
          totals: data.totals,
          periodSpend: data.periodSpend,
          periodReceive: data.periodReceive,
          itemNames: data.itemNames,
          supplierNames: data.supplierNames,
          craftsmanNames: data.craftsmanNames,
          bounds: _bounds,
          copy: copy,
          unitAddress: data.unitAddress,
        );
      } catch (e, st) {
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st, library: 'statement_pdf'));
        if (mounted) {
          StatementScreenToast.failure(
            context,
            l10n.statementExportFailed,
            action: ToastAction(label: l10n.retry, onPressed: () => _exportPdf(data, l10n)),
          );
        }
        return;
      }

      final prefs = await StatementPrefsAccess.getInstance();
      if (prefs != null) {
        final repo = ref.read(repositoryProvider);
        final store = StatementExportStore(prefs);
        final ws = await repo.workspaceId();
        await store.recordSuccessfulExport(
          workspaceId: ws,
          kind: StatementEntityKind.client,
          entityId: widget.clientId,
          exportedAt: DateTime.now(),
          periodEndInclusive: _bounds.end,
        );
        if (mounted) {
          setState(() {
            _prefsAvailable = true;
            _lastExport = store.read(workspaceId: ws, kind: StatementEntityKind.client, entityId: widget.clientId);
          });
        }
      }

      final path = await StatementPdfExport.persistTempPdf(bytes, fileName);
      if (!mounted) return;
      final shareOrigin = StatementPdfExport.sharePositionOriginFor(_sharePdfButtonKey.currentContext ?? context);
      try {
        await StatementPdfExport.shareFromFile(path, fileName, sharePositionOrigin: shareOrigin);
      } catch (e, st) {
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st, library: 'statement_share'));
        if (mounted) {
          StatementScreenToast.failure(
            context,
            l10n.statementExportShareFailed,
            action: ToastAction(label: l10n.retry, onPressed: () => _shareExistingFile(path, fileName, l10n)),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _shareExistingFile(String path, String fileName, AppLocalizations l10n) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final shareOrigin = StatementPdfExport.sharePositionOriginFor(_sharePdfButtonKey.currentContext ?? context);
      await StatementPdfExport.shareFromFile(path, fileName, sharePositionOrigin: shareOrigin);
    } catch (e, st) {
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st, library: 'statement_share'));
      if (mounted) {
        StatementScreenToast.failure(context, l10n.statementExportShareFailed);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}

class _StatementData {
  _StatementData({
    required this.client,
    required this.unitAddress,
    required this.totals,
    required this.periodSpend,
    required this.periodReceive,
    required this.itemNames,
    required this.supplierNames,
    required this.craftsmanNames,
  });

  final Client client;
  final String? unitAddress;
  final StatementPeriodTotals totals;
  final List<Transaction> periodSpend;
  final List<Transaction> periodReceive;
  final Map<String, String> itemNames;
  final Map<String, String> supplierNames;
  final Map<String, String> craftsmanNames;
}
