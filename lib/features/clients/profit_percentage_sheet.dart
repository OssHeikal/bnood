import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/money/basis_points.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/app_modal_sheet.dart';
import '../../core/widgets/sheet_footer_refresh.dart';
import '../../core/widgets/sheet_form_header.dart';
import '../home/home_foundation_scope.dart';

Future<void> showProfitPercentageSheet({
  required BuildContext context,
  required String clientId,
  required String projectId,
  required String clientName,
  int? engineerBasisPoints,
}) {
  final formKey = GlobalKey<_ProfitPercentageSheetState>();
  final footerRefresh = SheetFooterRefresh();
  final l10n = AppLocalizations.of(context);
  return AppModalSheet.show<void>(
    context: context,
    scrollable: false,
    header: SheetFormHeader(title: l10n.engineerFeeSheetTitle),
    body: HomeFoundationScope(
      child: ProfitPercentageSheet(
        key: formKey,
        clientId: clientId,
        projectId: projectId,
        clientName: clientName,
        engineerBasisPoints: engineerBasisPoints,
        footerRefresh: footerRefresh,
      ),
    ),
    footer: ListenableBuilder(
      listenable: footerRefresh,
      builder: (context, _) {
        final state = formKey.currentState;
        if (state == null) return const SizedBox.shrink();
        return AppButton.primary(
          text: l10n.save,
          isLoading: state._saving,
          onPressed: state._saving ? null : state._save,
        );
      },
    ),
  );
}

/// Optional profit percentage on total spend (internal estimate only; `engineerBasisPoints` in DB).
class ProfitPercentageSheet extends ConsumerStatefulWidget {
  const ProfitPercentageSheet({
    super.key,
    required this.clientId,
    required this.projectId,
    required this.clientName,
    this.engineerBasisPoints,
    required this.footerRefresh,
  });

  final String clientId;
  final String projectId;
  final String clientName;
  final int? engineerBasisPoints;
  final SheetFooterRefresh footerRefresh;

  @override
  ConsumerState<ProfitPercentageSheet> createState() => _ProfitPercentageSheetState();
}

class _ProfitPercentageSheetState extends ConsumerState<ProfitPercentageSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _percentCtrl = TextEditingController(
    text: widget.engineerBasisPoints == null
        ? ''
        : BasisPoints.formatPercent(widget.engineerBasisPoints).replaceAll('%', ''),
  );
  var _attemptedSubmit = false;
  var _saving = false;

  @override
  void dispose() {
    _percentCtrl.dispose();
    super.dispose();
  }

  void _bumpFooter() => widget.footerRefresh.bump();

  Future<void> _save() async {
    setState(() => _attemptedSubmit = true);
    _bumpFooter();
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    _bumpFooter();
    try {
      final raw = _percentCtrl.text.trim();
      final bp = raw.isEmpty ? null : BasisPoints.parsePercentInput(raw);
      if (raw.isNotEmpty && bp == null) return;
      await ref.read(clientsRepositoryProvider).updateClient(
            id: widget.clientId,
            engineerBasisPoints: bp?.value,
            clearEngineerBasisPoints: raw.isEmpty,
          );
      refreshAfterClientMutation(ref, clientId: widget.clientId);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        _bumpFooter();
      }
    }
  }

  String? _validatePercent(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;
    if (BasisPoints.parsePercentInput(raw) == null) {
      return AppLocalizations.of(context).engineerFeePercentInvalid;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.clientName, style: context.text.supporting.copyWith(color: colors.onSurfaceMuted)),
          AppSize.spaceMD.gap,
          Form(
            key: _formKey,
            autovalidateMode:
                _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: CustomTextField(
              controller: _percentCtrl,
              label: l10n.engineerFeePercentFieldLabel,
              placeholder: l10n.engineerFeePercentPlaceholder,
              fieldHeight: AppSize.fieldHeightComfortable,
              type: AppInputType.percentage,
              allowNegative: false,
              maxDecimalPlaces: 2,
              ltrValue: true,
              suffix: Text('%', style: context.text.body),
              validator: _validatePercent,
            ),
          ),
          AppSize.spaceSM.gap,
          Text(
            l10n.engineerFeeSheetCaption,
            style: context.text.caption.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}