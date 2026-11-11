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
import '../../core/clients/client_statement_record.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/clients/clients_error_handler.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/items/item_api_record.dart';
import '../../core/items/items_providers.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/toast/app_toast.dart';
import 'pdf_statement_service.dart';
import 'statement_pdf_export.dart';
import 'statement_screen_toast.dart';
import 'statement_api_client_document.dart';
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
  StatementPeriodPreset _preset = StatementPeriodPreset.all;
  late PeriodBounds _bounds = StatementPeriodLogic.wholePeriodBounds();
  StatementExportRecord? _lastExport;
  bool _exporting = false;
  bool _prefsAvailable = true;
  List<Transaction> _allRows = const [];
  DateTime? _remoteNaturalStart;
  DateTime? _clientCreatedAtDay;
  Client? _localClient;
  Future<_StatementData>? _loadFuture;
  Future<_RemoteStatementData>? _remoteLoadFuture;

  @override
  void initState() {
    super.initState();
    _loadExportCursor();
  }

  void _startLoad(BnoodRepository repo) {
    _loadFuture = _load(repo);
  }

  void _startRemoteLoad() {
    _remoteLoadFuture = _loadRemote();
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
    final remote = ref.read(remoteClientsEnabledProvider);
    return switch (preset) {
      StatementPeriodPreset.today => StatementPeriodLogic.todayBounds(),
      StatementPeriodPreset.month => StatementPeriodLogic.monthBounds(),
      StatementPeriodPreset.all => remote
          ? StatementPeriodLogic.wholePeriodBounds(
              naturalStart: _remoteNaturalStart ?? _clientCreatedAtDay,
            )
          : StatementPeriodLogic.allTimeBounds(
              _allRows,
              emptyFallbackStart: _localClient?.createdAt,
            ),
      StatementPeriodPreset.sinceLastExport => StatementPeriodLogic.sinceLastExportBounds(_lastExport) ?? _bounds,
      StatementPeriodPreset.custom => _bounds,
    };
  }

  ({String? from, String to}) _remoteStatementQuery() {
    final apiBounds = StatementPeriodLogic.clampForRemoteApi(_bounds);
    final to = _formatStatementDate(apiBounds.end);
    if (_preset == StatementPeriodPreset.all) {
      if (_remoteNaturalStart != null) {
        return (from: _formatStatementDate(_remoteNaturalStart!), to: to);
      }
      return (from: null, to: to);
    }
    return (from: _formatStatementDate(apiBounds.start), to: to);
  }

  void _applyRemoteWholePeriodBounds(AppClientStatement statement, DateTime clientCreatedDay) {
    if (_preset != StatementPeriodPreset.all) return;
    final periodStart = StatementPeriodLogic.parseStatementApiDate(statement.periodStart) ??
        StatementPeriodLogic.parseStatementApiDate(statement.from) ??
        clientCreatedDay;
    final effectiveTo = StatementPeriodLogic.parseStatementApiDate(statement.to) ?? StatementPeriodLogic.cairoTodayDate();
    final nextNatural = periodStart;
    final nextBounds = PeriodBounds.normalize(start: periodStart, end: effectiveTo);
    if (_remoteNaturalStart == nextNatural &&
        _bounds.start == nextBounds.start &&
        _bounds.end == nextBounds.end) {
      return;
    }
    _remoteNaturalStart = nextNatural;
    _bounds = nextBounds;
  }

  static String _formatStatementDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool get _sinceLastExportAvailable =>
      _prefsAvailable && StatementPeriodLogic.sinceLastExportBounds(_lastExport) != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(repositoryProvider);
    final remote = ref.watch(remoteClientsEnabledProvider);
    final localeCode = Localizations.localeOf(context).languageCode;
    if (remote) {
      _remoteLoadFuture ??= _loadRemote();
    } else {
      _loadFuture ??= _load(repo);
    }

    return HomeFoundationScope(
      child: remote
          ? FutureBuilder<_RemoteStatementData>(
              future: _remoteLoadFuture,
              builder: (context, snap) => _scaffoldForBody(
                context,
                l10n,
                showPdfFooter: snap.hasData,
                body: _buildRemoteBody(context, snap, localeCode),
                onSharePdf: snap.hasData ? () => _exportRemotePdf(l10n) : null,
              ),
            )
          : FutureBuilder<_StatementData>(
              future: _loadFuture,
              builder: (context, snap) => _scaffoldForBody(
                context,
                l10n,
                showPdfFooter: snap.hasData,
                body: _buildLocalBody(context, snap, repo, localeCode),
                onSharePdf: snap.hasData ? () => _exportPdf(snap.data!, l10n) : null,
              ),
            ),
    );
  }

  Widget _scaffoldForBody(
    BuildContext context,
    AppLocalizations l10n, {
    required Widget body,
    required bool showPdfFooter,
    VoidCallback? onSharePdf,
  }) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: CustomAppBar(title: l10n.statement),
      body: body,
      bottomNavigationBar: showPdfFooter
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
                  onPressed: _exporting || onSharePdf == null ? null : onSharePdf,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildRemoteBody(BuildContext context, AsyncSnapshot<_RemoteStatementData> snap, String localeCode) {
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
          lastExport: null,
          sinceLastExportAvailable: false,
          onChanged: (b, preset) {
            setState(() {
              _preset = preset;
              _bounds = preset == StatementPeriodPreset.custom ? b : _resolvePreset(preset);
              _startRemoteLoad();
            });
          },
        ),
        const SizedBox(height: AppSize.spaceMD),
        StatementApiClientDocument(
          clientName: data.clientName,
          statement: data.statement,
          localeCode: localeCode,
          catalogById: data.catalogById,
        ),
      ],
    );
  }

  Widget _buildLocalBody(BuildContext context, AsyncSnapshot<_StatementData> snap, BnoodRepository repo, String localeCode) {
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
              if (ref.read(remoteClientsEnabledProvider)) {
                _startRemoteLoad();
              } else {
                _startLoad(repo);
              }
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

  Future<_RemoteStatementData> _loadRemote() async {
    final clientsRepo = ref.read(clientsRepositoryProvider);
    final record = await clientsRepo.getClient(widget.clientId);
    final clientCreatedDay = StatementPeriodLogic.cairoCalendarDayFromUtc(record.client.createdAt);
    _clientCreatedAtDay ??= clientCreatedDay;
    if (_preset == StatementPeriodPreset.all && _remoteNaturalStart == null) {
      _bounds = StatementPeriodLogic.wholePeriodBounds(naturalStart: clientCreatedDay);
    }
    final query = _remoteStatementQuery();
    final statement = await clientsRepo.getClientStatement(
      clientId: widget.clientId,
      from: query.from,
      to: query.to,
    );
    if (mounted) {
      setState(() => _applyRemoteWholePeriodBounds(statement, clientCreatedDay));
    } else {
      _applyRemoteWholePeriodBounds(statement, clientCreatedDay);
    }
    Map<String, CatalogItem> catalogById = const {};
    try {
      catalogById = await ref.read(itemsCatalogByIdProvider.future);
    } catch (_) {
      catalogById = const {};
    }
    return _RemoteStatementData(
      clientName: record.client.name,
      statement: statement,
      catalogById: catalogById,
    );
  }

  Future<_StatementData> _load(BnoodRepository repo) async {
    final client = await repo.getClient(widget.clientId);
    _localClient = client;
    final project = await repo.primaryActiveProject(widget.clientId);
    if (project == null) throw StateError('missing');
    final rows = await repo.transactionsForProject(project.id);
    _allRows = rows;
    if (mounted && _preset == StatementPeriodPreset.all) {
      setState(() {
        _bounds = StatementPeriodLogic.allTimeBounds(_allRows, emptyFallbackStart: client.createdAt);
      });
    }
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

  String _statementPdfFailureMessage(AppLocalizations l10n, Object error) {
    if (error is AuthApiException) {
      if (error.message.isNotEmpty) return error.message;
    }
    return l10n.statementExportFailed;
  }

  Future<void> _exportRemotePdf(AppLocalizations l10n) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final query = _remoteStatementQuery();
      try {
        final pdf = await ref.read(clientsRepositoryProvider).downloadClientStatementPdf(
              clientId: widget.clientId,
              from: query.from,
              to: query.to,
            );
        await _shareDownloadedPdf(pdf.bytes, pdf.fileName, l10n);
      } on AuthApiException catch (e, st) {
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st, library: 'statement_pdf_remote'));
        if (!mounted) return;
        if (await handleClientsApiAuthError(context: context, ref: ref, error: e)) return;
        if (!mounted) return;
        StatementScreenToast.failure(
          context,
          _statementPdfFailureMessage(l10n, e),
          action: ToastAction(label: l10n.retry, onPressed: () => _exportRemotePdf(l10n)),
        );
      } catch (e, st) {
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st, library: 'statement_pdf_remote'));
        if (mounted) {
          StatementScreenToast.failure(
            context,
            l10n.statementExportFailed,
            action: ToastAction(label: l10n.retry, onPressed: () => _exportRemotePdf(l10n)),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _shareDownloadedPdf(Uint8List bytes, String fileName, AppLocalizations l10n) async {
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

      await _shareDownloadedPdf(bytes, fileName, l10n);
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

class _RemoteStatementData {
  const _RemoteStatementData({
    required this.clientName,
    required this.statement,
    required this.catalogById,
  });

  final String clientName;
  final AppClientStatement statement;
  final Map<String, CatalogItem> catalogById;
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
