import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/agreements/agreements_riverpod.dart';
import '../../core/money/money_format.dart';
import '../../core/money/remote_money_format.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../home/home_foundation_scope.dart';
import '../suppliers/craftsman_detail_provider.dart';
import 'agreement_mutation_actions.dart';

/// Draft save payload from the roster amount sub-sheet (`null` amount = no agreed amount).
class CraftsmanAgreementAmountDraftResult {
  const CraftsmanAgreementAmountDraftResult(this.initialAmountPiastres);

  final int? initialAmountPiastres;
}

enum CraftsmanAgreementAmountEntry { rosterDraft, craftsmanDetailEdit }

Future<void> showRemoteAgreementAmountEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String agreementId,
  required String clientId,
  required String providerId,
  required String clientName,
  required String craftsmanName,
  int? initialAmountPiastres,
}) {
  return BnoodModalSheet.show<void>(
    context: context,
    builder: (_) => HomeFoundationScope(
      child: CraftsmanAgreementAmountPage(
        entry: CraftsmanAgreementAmountEntry.craftsmanDetailEdit,
        projectId: clientId,
        clientName: clientName,
        craftsmanName: craftsmanName,
        initialAmountPiastres: initialAmountPiastres,
        onPersist: (amount) => saveRemoteAgreementAmount(
          context: context,
          ref: ref,
          agreementId: agreementId,
          amountPiastres: amount,
          clientId: clientId,
          providerId: providerId,
        ),
      ),
    ),
  );
}

Future<void> showCraftsmanProjectAgreementEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String projectId,
  required String craftsmanId,
  required String clientName,
  required String craftsmanName,
  required String clientId,
  int? initialAmountPiastres,
}) {
  return BnoodModalSheet.show<void>(
    context: context,
    builder: (_) => HomeFoundationScope(
      child: CraftsmanAgreementAmountPage(
              entry: CraftsmanAgreementAmountEntry.craftsmanDetailEdit,
              projectId: projectId,
              craftsmanId: craftsmanId,
              craftsmanName: craftsmanName,
              clientName: clientName,
              initialAmountPiastres: initialAmountPiastres,
              onPersist: (amount) async {
                final repo = ref.read(repositoryProvider);
                if (amount == null) {
                  await repo.upsertAgreement(
                    projectId: projectId,
                    craftsmanId: craftsmanId,
                    clearInitial: true,
                  );
                } else {
                  await repo.upsertAgreement(
                    projectId: projectId,
                    craftsmanId: craftsmanId,
                    initialAmountPiastres: amount,
                  );
                }
                await ref.read(craftsmanDetailProvider(craftsmanId).notifier).refreshSilently();
                refreshAfterClientMutation(ref, clientId: clientId);
              },
            ),
    ),
  );
}

class CraftsmanAgreementAmountPage extends ConsumerStatefulWidget {
  const CraftsmanAgreementAmountPage({
    super.key,
    required this.entry,
    required this.projectId,
    required this.craftsmanName,
    required this.clientName,
    this.craftsmanId,
    this.initialAmountPiastres,
    this.onPersist,
  });

  final CraftsmanAgreementAmountEntry entry;
  final String projectId;
  final String? craftsmanId;
  final String craftsmanName;
  final String clientName;
  final int? initialAmountPiastres;
  final Future<void> Function(int? amount)? onPersist;

  @override
  ConsumerState<CraftsmanAgreementAmountPage> createState() => _CraftsmanAgreementAmountPageState();
}

class _CraftsmanAgreementAmountPageState extends ConsumerState<CraftsmanAgreementAmountPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount = TextEditingController();
  var _amountFieldInitialized = false;
  var _attemptedSubmit = false;
  var _saving = false;

  bool get _useRemoteMoneyScale => ref.read(remoteAgreementsEnabledProvider);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_amountFieldInitialized) return;
    _amountFieldInitialized = true;
    final initial = widget.initialAmountPiastres;
    if (initial == null) return;
    _amount.text = _useRemoteMoneyScale
        ? RemoteMoneyFormat.majorInputTextFromMinor(initial)
        : (initial / 100).toString();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  String _title(AppLocalizations l10n) {
    return switch (widget.entry) {
      CraftsmanAgreementAmountEntry.rosterDraft => l10n.craftsmanAgreedAmountSheetTitle,
      CraftsmanAgreementAmountEntry.craftsmanDetailEdit => l10n.craftsmanDetailEditAgreement,
    };
  }

  String? _validate(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;
    final minor = _useRemoteMoneyScale
        ? RemoteMoneyFormat.parseMajorInput(raw)
        : MoneyFormat.parseEgpInput(raw);
    if (minor == null || minor < 0) {
      return AppLocalizations.of(context).craftsmanAgreementAmountInvalid;
    }
    return null;
  }

  int? _parseAmount() {
    final text = _amount.text.trim();
    if (text.isEmpty) return null;
    return _useRemoteMoneyScale
        ? RemoteMoneyFormat.parseMajorInput(text)
        : MoneyFormat.parseEgpInput(text);
  }

  void _closeHostModal() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _save() async {
    setState(() => _attemptedSubmit = true);
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    final parsed = _parseAmount();
    final text = _amount.text.trim();
    if (text.isNotEmpty && parsed == null) return;

    if (widget.entry == CraftsmanAgreementAmountEntry.rosterDraft) {
      if (!mounted) return;
      Navigator.of(context).pop(
        CraftsmanAgreementAmountDraftResult(parsed),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onPersist?.call(parsed);
      if (!mounted) return;
      _closeHostModal();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final showBack = widget.entry == CraftsmanAgreementAmountEntry.rosterDraft;

    final body = Column(
      mainAxisSize: MainAxisSize.min,
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
              if (showBack)
                Row(
                  children: [
                    BackButton(onPressed: () => Navigator.maybePop(context)),
                    Expanded(child: Text(_title(l10n), style: context.text.title)),
                  ],
                )
              else
                Text(_title(l10n), style: context.text.title),
              AppSize.spaceXS.gap,
              Text(
                l10n.crewAssignmentsProjectContext(widget.clientName),
                style: context.text.supporting.copyWith(color: colors.onSurfaceMuted),
              ),
              AppSize.spaceXS.gap,
              Text(
                widget.craftsmanName,
                style: context.text.supporting.copyWith(color: colors.onSurfaceMuted),
              ),
            ],
          ),
        ),
        AppSize.spaceMD.gap,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
          child: Form(
            key: _formKey,
            autovalidateMode: _attemptedSubmit
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _amount,
                  label: l10n.craftsmanAgreedForClientLabel,
                  placeholder: l10n.craftsmanAgreementAmountPlaceholder,
                  type: AppInputType.currency,
                  ltrValue: true,
                  suffix: Text(MoneyFormat.currencyLabel),
                  fieldHeight: AppSize.fieldHeightComfortable,
                  autofocus: true,
                  validator: _validate,
                ),
                AppSize.spaceXS.gap,
                Text(
                  l10n.craftsmanAgreementAmountCaption,
                  style: context.text.caption.copyWith(color: colors.onSurfaceMuted),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSize.screenPadding,
            AppSize.spaceLG,
            AppSize.screenPadding,
            AppSize.spaceMD + viewPadding.bottom,
          ),
          child: AppButton.primary(
            text: l10n.save,
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ),
      ],
    );

    return Material(
      color: colors.surface,
      child: body,
    );
  }
}
