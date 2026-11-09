import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/database/database.dart';
import '../../core/money/period_bounds.dart';
import '../../core/money/supplier_period_math.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/toast/app_toast.dart';
import '../home/home_foundation_scope.dart';
import 'pdf_statement_service.dart';
import 'statement_pdf_export.dart';
import 'statement_screen_toast.dart';
import 'statement_export_store.dart';
import 'statement_pdf_copy.dart';
import 'statement_period_controls.dart';
import 'statement_period_logic.dart';
import 'statement_prefs_access.dart';
import 'statement_supplier_document.dart';

class SupplierStatementScreen extends ConsumerStatefulWidget {
  const SupplierStatementScreen({super.key, required this.supplierId});

  final String supplierId;

  @override
  ConsumerState<SupplierStatementScreen> createState() => _SupplierStatementScreenState();
}

class _SupplierStatementScreenState extends ConsumerState<SupplierStatementScreen> {
  final _sharePdfButtonKey = GlobalKey();
  StatementPeriodPreset _preset = StatementPeriodPreset.month;
  late PeriodBounds _bounds = StatementPeriodLogic.monthBounds();
  StatementExportRecord? _lastExport;
  bool _exporting = false;
  bool _prefsAvailable = true;
  List<Transaction> _allRows = const [];
  Future<_Data>? _loadFuture;

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
      final record = store.read(
        workspaceId: ws,
        kind: StatementEntityKind.supplier,
        entityId: widget.supplierId,
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
    _loadFuture ??= _load(repo);

    return HomeFoundationScope(
      child: FutureBuilder<_Data>(
        future: _loadFuture,
        builder: (context, snap) {
          final colors = context.colors;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(title: l10n.statement),
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

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<_Data> snap,
    BnoodRepository repo,
    String localeCode,
  ) {
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
        StatementSupplierDocument(
          supplierName: data.supplier.name,
          totals: data.totals,
          periodRows: data.periodRows,
          clientNamesByProjectId: data.clientNamesByProjectId,
          localeCode: localeCode,
          showPeriodOpening: _preset != StatementPeriodPreset.all,
        ),
      ],
    );
  }

  Future<_Data> _load(BnoodRepository repo) async {
    final supplier = await repo.getSupplier(widget.supplierId);
    if (supplier == null) throw StateError('supplier');
    final rows = await repo.supplierTransactions(widget.supplierId);
    _allRows = rows;
    final totals = SupplierPeriodMath.totals(supplierSpends: rows, bounds: _bounds);
    final periodRows = rows.where((t) => _bounds.containsLocalDate(t.date)).toList();
    final clientInfo = await repo.clientInfoForProjectIds(rows.map((t) => t.projectId));
    final clientNames = {for (final e in clientInfo.entries) e.key: e.value.clientName};
    return _Data(
      supplier: supplier,
      totals: totals,
      periodRows: periodRows,
      clientNamesByProjectId: clientNames,
    );
  }

  Future<void> _exportPdf(_Data data, AppLocalizations l10n) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    const fileName = 'bnood-supplier-statement.pdf';
    try {
      final copy = StatementPdfCopy(l10n);
      late final Uint8List bytes;
      try {
        bytes = await PdfStatementService().buildSupplierStatement(
          supplier: data.supplier,
          totals: data.totals,
          periodRows: data.periodRows,
          clientNamesByProjectId: data.clientNamesByProjectId,
          bounds: _bounds,
          copy: copy,
        );
      } catch (e, st) {
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st, library: 'statement_pdf'));
        if (mounted) {
          StatementScreenToast.failure(
            context,
            l10n.statementExportFailed,
            action: ToastAction(
              label: l10n.retry,
              onPressed: () => _exportPdf(data, l10n),
            ),
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
          kind: StatementEntityKind.supplier,
          entityId: widget.supplierId,
          exportedAt: DateTime.now(),
          periodEndInclusive: _bounds.end,
        );
        if (mounted) {
          setState(() {
            _prefsAvailable = true;
            _lastExport = store.read(
              workspaceId: ws,
              kind: StatementEntityKind.supplier,
              entityId: widget.supplierId,
            );
          });
        }
      }

      final path = await StatementPdfExport.persistTempPdf(bytes, fileName);
      if (!mounted) return;
      final shareOrigin = StatementPdfExport.sharePositionOriginFor(
        _sharePdfButtonKey.currentContext ?? context,
      );
      try {
        await StatementPdfExport.shareFromFile(
          path,
          fileName,
          sharePositionOrigin: shareOrigin,
        );
      } catch (e, st) {
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st, library: 'statement_share'));
        if (mounted) {
          StatementScreenToast.failure(
            context,
            l10n.statementExportShareFailed,
            action: ToastAction(
              label: l10n.retry,
              onPressed: () => _shareExistingFile(path, fileName, l10n),
            ),
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
      final shareOrigin = StatementPdfExport.sharePositionOriginFor(
        _sharePdfButtonKey.currentContext ?? context,
      );
      await StatementPdfExport.shareFromFile(
        path,
        fileName,
        sharePositionOrigin: shareOrigin,
      );
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

class _Data {
  _Data({
    required this.supplier,
    required this.totals,
    required this.periodRows,
    required this.clientNamesByProjectId,
  });

  final Supplier supplier;
  final SupplierPeriodTotals totals;
  final List<Transaction> periodRows;
  final Map<String, String> clientNamesByProjectId;
}
