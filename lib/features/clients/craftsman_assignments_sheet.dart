import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/entity_picker_page.dart';
import '../vouchers/inline_create_routes.dart';

Future<void> showCraftsmanAssignmentsSheet({
  required BuildContext context,
  required String projectId,
}) {
  final navKey = GlobalKey<NavigatorState>();
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => SizedBox(
      height: MediaQuery.sizeOf(ctx).height * 0.75,
      child: Navigator(
        key: navKey,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => CraftsmanAssignmentsSheet(projectId: projectId),
        ),
      ),
    ),
  );
}

class CraftsmanAssignmentsSheet extends ConsumerStatefulWidget {
  const CraftsmanAssignmentsSheet({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<CraftsmanAssignmentsSheet> createState() =>
      _CraftsmanAssignmentsSheetState();
}

class _CraftsmanAssignmentsSheetState
    extends ConsumerState<CraftsmanAssignmentsSheet> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(repositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.craftsmen),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final roster = await repo.watchActiveCraftsmen().first;
              final agreements =
                  await repo.agreementsForProject(widget.projectId);
              final assigned = agreements.map((a) => a.craftsmanId).toSet();
              final available =
                  roster.where((c) => !assigned.contains(c.id)).toList();
              final picked = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => EntityPickerPage(
                    title: l10n.craftsmen,
                    entries: available.map((c) => (c.id, c.name)).toList(),
                    onCreateRoute: () => const InlineCreateCraftsmanPage(),
                  ),
                ),
              );
              if (picked != null) {
                await repo.upsertAgreement(
                    projectId: widget.projectId, craftsmanId: picked);
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: repo.agreementsForProject(widget.projectId),
        builder: (context, snap) {
          final agreements = snap.data ?? [];
          if (agreements.isEmpty) {
            return Center(child: Text(l10n.createNew));
          }
          return ListView.builder(
            itemCount: agreements.length,
            itemBuilder: (_, i) => _AgreementTile(
              projectId: widget.projectId,
              agreement: agreements[i],
              onChanged: () => setState(() {}),
            ),
          );
        },
      ),
    );
  }
}

class _AgreementTile extends ConsumerStatefulWidget {
  const _AgreementTile({
    required this.projectId,
    required this.agreement,
    required this.onChanged,
  });

  final String projectId;
  final ProjectCraftsmanAgreement agreement;
  final VoidCallback onChanged;

  @override
  ConsumerState<_AgreementTile> createState() => _AgreementTileState();
}

class _AgreementTileState extends ConsumerState<_AgreementTile> {
  late final _amountCtrl = TextEditingController(
    text: widget.agreement.initialAmountPiastres == null
        ? ''
        : (widget.agreement.initialAmountPiastres! / 100).toString(),
  );

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder(
      future: ref
          .read(repositoryProvider)
          .getCraftsman(widget.agreement.craftsmanId),
      builder: (context, snap) {
        final name = snap.data?.name ?? '—';
        return ListTile(
          title: Text(name),
          subtitle: TextField(
            controller: _amountCtrl,
            decoration: InputDecoration(
              labelText: 'Agreement (${l10n.remaining})',
              helperText: 'Empty = no agreement amount; 0 = zero agreed',
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _save(),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final repo = ref.read(repositoryProvider);
    final text = _amountCtrl.text.trim();
    if (text.isEmpty) {
      await repo.upsertAgreement(
        projectId: widget.projectId,
        craftsmanId: widget.agreement.craftsmanId,
        clearInitial: true,
      );
    } else {
      final piastres = MoneyFormat.parseEgpInput(text);
      if (piastres == null) return;
      await repo.upsertAgreement(
        projectId: widget.projectId,
        craftsmanId: widget.agreement.craftsmanId,
        initialAmountPiastres: piastres,
      );
    }
    widget.onChanged();
  }
}
