import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../home/home_foundation_scope.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/database/database.dart';
import '../../core/money/ledger_math.dart' show LedgerMath, StatementPeriodTotals;
import '../../core/money/period_bounds.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/buttons/app_button.dart';
import 'pdf_statement_service.dart';
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
  StatementPeriodPreset _preset = StatementPeriodPreset.month;
  late PeriodBounds _bounds = StatementPeriodLogic.monthBounds();
  StatementExportRecord? _lastExport;
  bool _exporting = false;
  bool _prefsAvailable = true;
  List<Transaction> _allRows = const [];

  @override
  void initState() {
    super.initState();
    _loadExportCursor();
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
      final record = store.read(
        workspaceId: ws,
        kind: StatementEntityKind.client,
        entityId: widget.clientId,
      );
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
      StatementPeriodPreset.sinceLastExport =>
        StatementPeriodLogic.sinceLastExportBounds(_lastExport) ?? _bounds,
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

    return HomeFoundationScope(
      child: Scaffold(
      appBar: AppBar(title: Text(l10n.statement)),
      body: FutureBuilder<_StatementData>(
        key: ValueKey('${_bounds.start}-${_bounds.end}-$_preset'),
        future: _load(repo),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }
          final data = snap.data!;
          final bottom = MediaQuery.paddingOf(context).bottom;
          return ListView(
              padding: EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                AppSize.spaceMD,
                AppSize.screenPadding,
                AppSize.spaceXL + bottom,
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
                const SizedBox(height: AppSize.spaceLG),
                AppButton(
                  text: l10n.sharePdf,
                  iconWidget: Assets.icons.shareOutline.svg(width: AppSize.iconCompact, height: AppSize.iconCompact),
                  isLoading: _exporting,
                  onPressed: _exporting ? null : () => _exportPdf(data, l10n),
                ),
              ],
            );
        },
      ),
    ),
    );
  }

  Future<_StatementData> _load(BnoodRepository repo) async {
    final client = await repo.getClient(widget.clientId);
    final project = await repo.primaryActiveProject(widget.clientId);
    if (client == null || project == null) throw StateError('missing');
    final rows = await repo.transactionsForProject(project.id);
    _allRows = rows;
    final totals = LedgerMath.periodTotals(
      projectRows: rows,
      periodStart: _bounds.start,
      periodEnd: _bounds.end,
    );
    final periodSpend =
        rows.where((t) => t.kind == 'spend' && _bounds.containsLocalDate(t.date)).toList();
    final periodReceive =
        rows.where((t) => t.kind == 'receive' && _bounds.containsLocalDate(t.date)).toList();
    final items = await repo.watchActiveItems().first;
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

  Future<Map<String, String>> _partyMap(
    BnoodRepository repo,
    Iterable<String?> ids, {
    bool craftsman = false,
  }) async {
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
    setState(() => _exporting = true);
    try {
      final copy = StatementPdfCopy(l10n);
      final bytes = await PdfStatementService().buildClientStatement(
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
            _lastExport = store.read(
              workspaceId: ws,
              kind: StatementEntityKind.client,
              entityId: widget.clientId,
            );
          });
        }
      }
      if (!mounted) return;
      await Share.shareXFiles([
        XFile.fromData(bytes, mimeType: 'application/pdf', name: 'bnood-client-statement.pdf'),
      ]);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.statementExportFailed)));
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
