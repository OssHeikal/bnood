import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/domain/money/period_bounds.dart';
import 'package:bnood/features/clients/data/client_statement_record.dart';
import '../../../../core/services/analytics/providers/analytics_feature_hooks.dart';
import '../../../../core/network/api/auth_api_exception.dart';
import 'package:bnood/features/clients/data/clients_error_handler.dart';
import 'package:bnood/features/clients/data/clients_providers.dart';
import 'package:bnood/features/items/data/item_api_record.dart';
import 'package:bnood/features/items/data/items_providers.dart';
import '../../../../core/ui/resources/gen/assets.gen.dart';
import '../../../../core/ui/widgets/buttons/app_button.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import '../../../../core/ui/widgets/toast/app_toast.dart';
import 'package:bnood/features/statements/presentation/actions/statement_pdf_export.dart';
import 'package:bnood/features/statements/presentation/actions/statement_screen_toast.dart';
import 'package:bnood/features/statements/presentation/models/statement_api_client_document.dart';
import 'package:bnood/features/statements/presentation/models/statement_export_store.dart';
import 'package:bnood/features/statements/presentation/widgets/statement_period_controls.dart';
import 'package:bnood/features/statements/presentation/models/statement_period_logic.dart';
import 'package:bnood/features/statements/presentation/models/statement_prefs_access.dart';
import 'package:bnood/features/statements/data/statement_workspace_scope.dart';

class ClientStatementScreen extends ConsumerStatefulWidget {
  const ClientStatementScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<ClientStatementScreen> createState() =>
      _ClientStatementScreenState();
}

class _ClientStatementScreenState extends ConsumerState<ClientStatementScreen> {
  final _sharePdfButtonKey = GlobalKey();
  StatementPeriodPreset _preset = StatementPeriodPreset.all;
  late PeriodBounds _bounds = StatementPeriodLogic.wholePeriodBounds();
  StatementExportRecord? _lastExport;
  bool _exporting = false;
  int _exportGeneration = 0;
  int? _statementShareTrackedGeneration;
  bool _prefsAvailable = true;
  DateTime? _remoteNaturalStart;
  DateTime? _clientCreatedAtDay;
  Future<_RemoteStatementData>? _remoteLoadFuture;

  @override
  void initState() {
    super.initState();
    _loadExportCursor();
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
      final store = StatementExportStore(prefs);
      final ws = statementWorkspaceId(ref);
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
      StatementPeriodPreset.all => StatementPeriodLogic.wholePeriodBounds(
        naturalStart: _remoteNaturalStart ?? _clientCreatedAtDay,
      ),
      StatementPeriodPreset.sinceLastExport =>
        StatementPeriodLogic.sinceLastExportBounds(_lastExport) ?? _bounds,
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

  void _applyRemoteWholePeriodBounds(
    AppClientStatement statement,
    DateTime clientCreatedDay,
  ) {
    if (_preset != StatementPeriodPreset.all) return;
    final periodStart =
        StatementPeriodLogic.parseStatementApiDate(statement.periodStart) ??
        StatementPeriodLogic.parseStatementApiDate(statement.from) ??
        clientCreatedDay;
    final effectiveTo =
        StatementPeriodLogic.parseStatementApiDate(statement.to) ??
        StatementPeriodLogic.cairoTodayDate();
    final nextNatural = periodStart;
    final nextBounds = PeriodBounds.normalize(
      start: periodStart,
      end: effectiveTo,
    );
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
      _prefsAvailable &&
      StatementPeriodLogic.sinceLastExportBounds(_lastExport) != null;

  Future<void> _recordSuccessfulExportCursor() async {
    final prefs = await StatementPrefsAccess.getInstance();
    if (prefs == null) return;
    final store = StatementExportStore(prefs);
    final ws = statementWorkspaceId(ref);
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
        _exportGeneration++;
      });
    }
  }

  void _trackStatementShareWhenSheetClosed() {
    if (_statementShareTrackedGeneration == _exportGeneration) return;
    _statementShareTrackedGeneration = _exportGeneration;
    trackClientStatementShared(ref);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    _remoteLoadFuture ??= _loadRemote();

    return HomeFoundationScope(
      child: FutureBuilder<_RemoteStatementData>(
        future: _remoteLoadFuture,
        builder: (context, snap) => _scaffoldForBody(
          context,
          l10n,
          showPdfFooter: snap.hasData,
          body: _buildRemoteBody(context, snap, localeCode),
          onSharePdf: snap.hasData ? () => _exportRemotePdf(l10n) : null,
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
                  onPressed: _exporting || onSharePdf == null
                      ? null
                      : onSharePdf,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildRemoteBody(
    BuildContext context,
    AsyncSnapshot<_RemoteStatementData> snap,
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
              _bounds = preset == StatementPeriodPreset.custom
                  ? b
                  : _resolvePreset(preset);
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

  Future<_RemoteStatementData> _loadRemote() async {
    final clientsRepo = ref.read(clientsRepositoryProvider);
    final record = await clientsRepo.getClient(widget.clientId);
    final clientCreatedDay = StatementPeriodLogic.cairoCalendarDayFromUtc(
      record.client.createdAt,
    );
    _clientCreatedAtDay ??= clientCreatedDay;
    if (_preset == StatementPeriodPreset.all && _remoteNaturalStart == null) {
      _bounds = StatementPeriodLogic.wholePeriodBounds(
        naturalStart: clientCreatedDay,
      );
    }
    final query = _remoteStatementQuery();
    final statement = await clientsRepo.getClientStatement(
      clientId: widget.clientId,
      from: query.from,
      to: query.to,
    );
    if (mounted) {
      setState(
        () => _applyRemoteWholePeriodBounds(statement, clientCreatedDay),
      );
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
        final pdf = await ref
            .read(clientsRepositoryProvider)
            .downloadClientStatementPdf(
              clientId: widget.clientId,
              from: query.from,
              to: query.to,
            );
        await _recordSuccessfulExportCursor();
        await _shareDownloadedPdf(pdf.bytes, pdf.fileName, l10n);
      } on AuthApiException catch (e, st) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: e,
            stack: st,
            library: 'statement_pdf_remote',
          ),
        );
        if (!mounted) return;
        if (await handleClientsApiAuthError(
          context: context,
          ref: ref,
          error: e,
        )) {
          return;
        }
        if (!mounted) return;
        StatementScreenToast.failure(
          context,
          _statementPdfFailureMessage(l10n, e),
          action: ToastAction(
            label: l10n.retry,
            onPressed: () => _exportRemotePdf(l10n),
          ),
        );
      } catch (e, st) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: e,
            stack: st,
            library: 'statement_pdf_remote',
          ),
        );
        if (mounted) {
          StatementScreenToast.failure(
            context,
            l10n.statementExportFailed,
            action: ToastAction(
              label: l10n.retry,
              onPressed: () => _exportRemotePdf(l10n),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _shareDownloadedPdf(
    Uint8List bytes,
    String fileName,
    AppLocalizations l10n,
  ) async {
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
      _trackStatementShareWhenSheetClosed();
    } catch (e, st) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: st,
          library: 'statement_share',
        ),
      );
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
  }

  Future<void> _shareExistingFile(
    String path,
    String fileName,
    AppLocalizations l10n,
  ) async {
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
      _trackStatementShareWhenSheetClosed();
    } catch (e, st) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: st,
          library: 'statement_share',
        ),
      );
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
