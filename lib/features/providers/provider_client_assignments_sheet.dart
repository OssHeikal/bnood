import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/agreements/agreements_error_handler.dart';
import '../../core/agreements/agreements_riverpod.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/clients/client_api_record.dart';
import '../../core/clients/client_provider_agreement_preview.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/widgets/app_fallback.dart';
import '../clients/agreement_mutation_actions.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/widgets/bounded_sheet_navigator.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../../core/widgets/skeleton/skeleton.dart';
import '../clients/widgets/client_roster_choice_row.dart';
import '../home/home_foundation_scope.dart';

Future<void> showProviderClientAssignmentsSheet({
  required BuildContext context,
  required String providerId,
  required String providerName,
  required AppProviderType providerType,
}) {
  return BnoodModalSheet.show<void>(
    context: context,
    builder: (_) => HomeFoundationScope(
      child: _ProviderClientAssignmentsHost(
        providerId: providerId,
        providerName: providerName,
        providerType: providerType,
      ),
    ),
  );
}

class _ProviderClientAssignmentsHost extends StatelessWidget {
  const _ProviderClientAssignmentsHost({
    required this.providerId,
    required this.providerName,
    required this.providerType,
  });

  final String providerId;
  final String providerName;
  final AppProviderType providerType;

  @override
  Widget build(BuildContext context) {
    return BoundedSheetNavigator(
      builder: (_) => ProviderClientAssignmentsSheet(
        providerId: providerId,
        providerName: providerName,
        providerType: providerType,
      ),
    );
  }
}

class ProviderClientAssignmentsSheet extends ConsumerStatefulWidget {
  const ProviderClientAssignmentsSheet({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.providerType,
    this.embedInModalChrome = true,
  });

  final String providerId;
  final String providerName;
  final AppProviderType providerType;
  final bool embedInModalChrome;

  @override
  ConsumerState<ProviderClientAssignmentsSheet> createState() => _ProviderClientAssignmentsSheetState();
}

class _ProviderClientAssignmentsSheetState extends ConsumerState<ProviderClientAssignmentsSheet> {
  final _selected = <String>{};
  final _search = TextEditingController();

  List<ClientApiRecord> _clients = [];
  var _loading = true;
  Object? _error;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  List<ClientApiRecord> get _filteredClients {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _clients;
    return _clients.where((record) {
      final name = record.client.name.toLowerCase();
      final phone = record.client.phone?.toLowerCase() ?? '';
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final clientsRepo = ref.read(clientsRepositoryProvider);
      final agreementsRepo = ref.read(appAgreementsRepositoryProvider);
      final clients = await clientsRepo.listAllActiveClients();
      final providerAgreements = await agreementsRepo.listAllProviderAgreements(widget.providerId);

      final selected = <String>{};
      for (final ag in providerAgreements) {
        selected.add(ag.clientId);
      }

      clients.sort((a, b) => a.client.name.compareTo(b.client.name));

      if (mounted) {
        setState(() {
          _clients = clients;
          _selected
            ..clear()
            ..addAll(selected);
          _loading = false;
        });
      }
    } on AuthApiException catch (e, st) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
        debugPrintStack(stackTrace: st, label: 'provider client roster load failed');
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
        debugPrintStack(stackTrace: st, label: 'provider client roster load failed');
      }
    }
  }

  void _toggleSelection(String clientId) {
    setState(() {
      if (_selected.contains(clientId)) {
        _selected.remove(clientId);
      } else {
        _selected.add(clientId);
      }
    });
  }

  void _closeHostModal() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final agreementsRepo = ref.read(appAgreementsRepositoryProvider);
    try {
      final providerAgreements = await agreementsRepo.listAllProviderAgreements(widget.providerId);
      final scoped = agreementsBelongingToProvider(providerAgreements, widget.providerId);
      final toDelete = providerAgreementsToDeleteOnAssignmentsSave(
        providerAgreements: scoped,
        selectedClientIds: _selected,
      ).toList();

      final existingByClient = {for (final a in scoped) a.clientId: a};
      final affectedClients = <String>{..._selected};
      for (final ag in toDelete) {
        affectedClients.add(ag.clientId);
      }

      for (final ag in toDelete) {
        final name = ag.clientName ?? '—';
        if (!await confirmPaidBeforeUnlinkIfNeeded(
          context: context,
          agreement: ag,
          paidGuardClientName: name,
        )) {
          continue;
        }
        try {
          await agreementsRepo.deleteAgreement(ag.id);
        } on AuthApiException catch (e) {
          if (!mounted) return;
          if (await handleAgreementsApiAuthError(context: context, ref: ref, error: e)) {
            return;
          }
          AppToaster.show(e.message, kind: ToastKind.failure);
          continue;
        }
      }

      for (final clientId in _selected) {
        if (existingByClient.containsKey(clientId)) continue;
        await agreementsRepo.createAgreement(
          clientId: clientId,
          providerId: widget.providerId,
          omitAmount: true,
        );
      }

      if (!mounted) return;
      refreshAfterProviderClientAssignments(
        ref,
        providerId: widget.providerId,
        affectedClientIds: affectedClients,
      );
      _closeHostModal();
      AppToaster.show(
        AppLocalizations.of(context).providerAssignmentsSaved,
        kind: ToastKind.success,
      );
    } on AuthApiException catch (e) {
      if (!mounted) return;
      if (await handleAgreementsApiAuthError(context: context, ref: ref, error: e)) {
        return;
      }
      AppToaster.show(e.message, kind: ToastKind.failure);
    } catch (e) {
      if (mounted) AppToaster.show(e.toString(), kind: ToastKind.failure);
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
          Text(l10n.linkClients, style: context.text.title),
          AppSize.spaceXS.gap,
          Text(
            l10n.linkClientsIntro,
            style: context.text.caption.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, AppColors colors) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
        child: Skeleton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSize.spaceLG),
            ],
          ),
        ),
      );
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

    final visible = _filteredClients;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
          child: Text(
            l10n.linkClientsProviderContext(widget.providerName),
            style: context.text.supporting.copyWith(color: colors.onSurfaceMuted),
          ),
        ),
        AppSize.spaceMD.gap,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
          child: CustomTextField.search(
            controller: _search,
            placeholder: l10n.voucherPickerSearchHint,
            onChanged: (_) => setState(() {}),
          ),
        ),
        AppSize.spaceMD.gap,
        if (_clients.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
            child: AppFallback.section(
              icon: Icons.people_outline,
              title: l10n.voucherPickerEmptyTitle,
            ),
          )
        else if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
            child: AppFallback.section(
              icon: Icons.search_off_outlined,
              title: l10n.voucherPickerNoResults,
            ),
          )
        else
          for (var i = 0; i < visible.length; i++)
            ClientRosterChoiceRow(
              clientId: visible[i].client.id,
              name: visible[i].client.name,
              phone: visible[i].client.phone,
              selected: _selected.contains(visible[i].client.id),
              onToggle: () => _toggleSelection(visible[i].client.id),
              showDivider: i < visible.length - 1,
            ),
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
        key: const Key('provider_client_assignments_save'),
        text: l10n.save,
        isLoading: _saving,
        onPressed: _clients.isEmpty || _saving ? null : _save,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    if (!widget.embedInModalChrome) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBody(l10n, colors),
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
                        _buildBody(l10n, colors),
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
