import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/basis_points.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_button.dart';

Future<void> showEngineerEditSheet({
  required BuildContext context,
  required String clientId,
  required String projectId,
  required String clientName,
  String? phone,
  String? unitAddress,
  int? engineerBasisPoints,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: EngineerEditSheet(
        clientId: clientId,
        projectId: projectId,
        clientName: clientName,
        phone: phone,
        unitAddress: unitAddress,
        engineerBasisPoints: engineerBasisPoints,
      ),
    ),
  );
}

class EngineerEditSheet extends ConsumerStatefulWidget {
  const EngineerEditSheet({
    super.key,
    required this.clientId,
    required this.projectId,
    required this.clientName,
    this.phone,
    this.unitAddress,
    this.engineerBasisPoints,
  });

  final String clientId;
  final String projectId;
  final String clientName;
  final String? phone;
  final String? unitAddress;
  final int? engineerBasisPoints;

  @override
  ConsumerState<EngineerEditSheet> createState() => _EngineerEditSheetState();
}

class _EngineerEditSheetState extends ConsumerState<EngineerEditSheet> {
  late final _nameCtrl = TextEditingController(text: widget.clientName);
  late final _phoneCtrl = TextEditingController(text: widget.phone ?? '');
  late final _addressCtrl =
      TextEditingController(text: widget.unitAddress ?? '');
  late final _percentCtrl = TextEditingController(
    text: widget.engineerBasisPoints == null
        ? ''
        : BasisPoints.formatPercent(widget.engineerBasisPoints)
            .replaceAll('%', ''),
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _percentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.engineerFee, style: Theme.of(context).textTheme.titleLarge),
          TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: l10n.clientName)),
          TextField(
              controller: _phoneCtrl,
              decoration: InputDecoration(labelText: l10n.phoneOptional)),
          TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Unit address')),
          TextField(
            controller: _percentCtrl,
            decoration: InputDecoration(labelText: '${l10n.engineerFee} %'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: l10n.save,
            onPressed: () async {
              final repo = ref.read(repositoryProvider);
              await repo.updateClient(
                clientId: widget.clientId,
                name: _nameCtrl.text.trim(),
                phone: _phoneCtrl.text.trim().isEmpty
                    ? ''
                    : _phoneCtrl.text.trim(),
              );
              final bp = _percentCtrl.text.trim().isEmpty
                  ? null
                  : BasisPoints.parsePercentInput(_percentCtrl.text.trim());
              if (_percentCtrl.text.trim().isNotEmpty && bp == null) return;
              await repo.updateProject(
                projectId: widget.projectId,
                unitAddress: _addressCtrl.text.trim().isEmpty
                    ? ''
                    : _addressCtrl.text.trim(),
                engineerBasisPoints: bp?.value,
                clearEngineerRate: _percentCtrl.text.trim().isEmpty,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
