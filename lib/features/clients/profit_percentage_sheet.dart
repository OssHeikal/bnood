import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/money/basis_points.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../home/home_foundation_scope.dart';

Future<void> showProfitPercentageSheet({
  required BuildContext context,
  required String clientId,
  required String projectId,
  required String clientName,
  int? engineerBasisPoints,
}) {
  return BnoodModalSheet.show<void>(
    context: context,
    builder: (_) => HomeFoundationScope(
      child: ProfitPercentageSheet(
        clientId: clientId,
        projectId: projectId,
        clientName: clientName,
        engineerBasisPoints: engineerBasisPoints,
      ),
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
  });

  final String clientId;
  final String projectId;
  final String clientName;
  final int? engineerBasisPoints;

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

  Future<void> _save() async {
    setState(() => _attemptedSubmit = true);
    if (_formKey.currentState?.validate() != true) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(repositoryProvider);
      final raw = _percentCtrl.text.trim();
      final bp = raw.isEmpty ? null : BasisPoints.parsePercentInput(raw);
      if (raw.isNotEmpty && bp == null) return;
      await repo.updateProject(
        projectId: widget.projectId,
        clearEngineerRate: raw.isEmpty,
        engineerBasisPoints: bp?.value,
      );
      refreshAfterClientMutation(ref, clientId: widget.clientId);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSize.screenPadding,
          AppSize.spaceSM,
          AppSize.screenPadding,
          AppSize.spaceMD,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetDragHandle(),
            AppSize.spaceMD.gap,
            Text(l10n.engineerFeeSheetTitle, style: context.text.title),
            AppSize.spaceSM.gap,
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
            AppSize.spaceLG.gap,
            AppButton.primary(text: l10n.save, isLoading: _saving, onPressed: _saving ? null : _save),
          ],
        ),
      ),
    );
  }
}
