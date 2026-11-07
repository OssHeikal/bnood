import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/database/database.dart' show TransactionsCompanion;
import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/entity_picker_page.dart';
import 'inline_create_routes.dart';
import 'voucher_launcher.dart';

class VoucherSheet extends ConsumerStatefulWidget {
  const VoucherSheet({super.key});

  @override
  ConsumerState<VoucherSheet> createState() => _VoucherSheetState();
}

class _VoucherSheetState extends ConsumerState<VoucherSheet> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(voucherDraftProvider);
    if (draft.amountPiastres != null) {
      _amountCtrl.text = (draft.amountPiastres! / 100).toString();
    }
    _descCtrl.text = draft.description ?? '';
    _receiptPath = draft.receiptImagePath;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickClient() async {
    final repo = ref.read(repositoryProvider);
    final clients = await repo.watchActiveClients();
    if (!mounted) return;
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerPage(
          title: AppLocalizations.of(context).navClients,
          entries: clients.map((c) => (c.id, c.name)).toList(),
          onCreateRoute: () => const InlineCreateClientPage(),
        ),
      ),
    );
    if (picked == null) return;
    final client = clients.firstWhere((c) => c.id == picked);
    final project = await repo.primaryActiveProject(picked);
    ref.read(voucherDraftProvider.notifier).state =
        ref.read(voucherDraftProvider).copyWith(
              clientId: picked,
              clientLabel: client.name,
              projectId: project?.id,
              clearCraftsman: true,
            );
    setState(() {});
  }

  Future<void> _pickItem() async {
    final items = await ref.read(repositoryProvider).watchActiveItems().first;
    if (!mounted) return;
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerPage(
          title: AppLocalizations.of(context).item,
          entries: items.map((i) => (i.id, i.name)).toList(),
          onCreateRoute: () => const InlineCreateItemPage(),
        ),
      ),
    );
    if (picked == null) return;
    final label = items.firstWhere((i) => i.id == picked).name;
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(itemId: picked, itemLabel: label);
    setState(() {});
  }

  Future<void> _pickSupplier() async {
    final suppliers =
        await ref.read(repositoryProvider).watchActiveSuppliers().first;
    if (!mounted) return;
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerPage(
          title: AppLocalizations.of(context).supplier,
          entries: suppliers.map((s) => (s.id, s.name)).toList(),
          onCreateRoute: () => const InlineCreateSupplierPage(),
        ),
      ),
    );
    if (picked == null) return;
    final label = suppliers.firstWhere((s) => s.id == picked).name;
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(supplierId: picked, supplierLabel: label);
    setState(() {});
  }

  Future<void> _pickCraftsman() async {
    final draft = ref.read(voucherDraftProvider);
    final projectId = draft.projectId;
    if (projectId == null) return;
    final craftsmen = await ref
        .read(repositoryProvider)
        .craftsmenAssignedToProject(projectId);
    if (!mounted) return;
    if (craftsmen.isEmpty) {
      AppToaster.show('Assign craftsmen to project first',
          kind: ToastKind.warning);
      return;
    }
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerPage(
          title: AppLocalizations.of(context).craftsman,
          entries: craftsmen.map((c) => (c.id, c.name)).toList(),
          onCreateRoute: () => const InlineCreateCraftsmanPage(),
        ),
      ),
    );
    if (picked == null) return;
    await ref
        .read(repositoryProvider)
        .upsertAgreement(projectId: projectId, craftsmanId: picked);
    final c = await ref.read(repositoryProvider).getCraftsman(picked);
    final label = c?.name ?? picked;
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(craftsmanId: picked, craftsmanLabel: label);
    setState(() {});
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final draft = ref.read(voucherDraftProvider);
    final amount = MoneyFormat.parseEgpInput(_amountCtrl.text);
    if (draft.projectId == null || amount == null || amount <= 0) {
      AppToaster.show('Complete required fields', kind: ToastKind.failure);
      return;
    }
    final repo = ref.read(repositoryProvider);
    final date = draft.date ?? DateTime.now();
    if (draft.kind == 'spend' && draft.itemId == null) {
      AppToaster.show('Select item', kind: ToastKind.failure);
      return;
    }
    if (draft.kind == 'spend' &&
        draft.expenseType == 'labor' &&
        draft.craftsmanId == null) {
      AppToaster.show('Select craftsman', kind: ToastKind.failure);
      return;
    }
    try {
      if (draft.editingTransactionId != null) {
        await repo.updateTransaction(
          draft.editingTransactionId!,
          TransactionsCompanion(
            kind: Value(draft.kind),
            amountPiastres: Value(amount),
            date: Value(date),
            method: Value(draft.method),
            description: Value(_descCtrl.text.isEmpty ? null : _descCtrl.text),
            receiptImagePath: Value(_receiptPath),
            itemId: Value(draft.kind == 'spend' ? draft.itemId : null),
            expenseType:
                Value(draft.kind == 'spend' ? draft.expenseType : null),
            supplierId: Value(
                draft.expenseType == 'materials' ? draft.supplierId : null),
            craftsmanId:
                Value(draft.expenseType == 'labor' ? draft.craftsmanId : null),
          ),
        );
      } else {
        await repo.insertTransaction(
          projectId: draft.projectId!,
          kind: draft.kind,
          amountPiastres: amount,
          date: date,
          method: draft.method,
          description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
          receiptImagePath: _receiptPath,
          itemId: draft.kind == 'spend' ? draft.itemId : null,
          expenseType: draft.kind == 'spend' ? draft.expenseType : null,
          supplierId:
              draft.expenseType == 'materials' ? draft.supplierId : null,
          craftsmanId: draft.expenseType == 'labor' ? draft.craftsmanId : null,
        );
      }
      ref.invalidate(homeTotalsProvider);
      AppToaster.show(l10n.save, kind: ToastKind.success);
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      AppToaster.show('$e', kind: ToastKind.failure);
    }
  }

  Future<void> _attachPhoto() async {
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'receipts'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final name =
        '${DateTime.now().microsecondsSinceEpoch}${p.extension(file.path)}';
    final saved = await File(file.path).copy(p.join(dir.path, name));
    setState(() => _receiptPath = saved.path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(voucherDraftProvider);
    final isSpend = draft.kind == 'spend';
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navAdd),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'receive',
                  label: Text(l10n.receive),
                  icon: const Icon(Icons.south_west, color: Colors.green),
                ),
                ButtonSegment(
                  value: 'spend',
                  label: Text(l10n.spend),
                  icon: const Icon(Icons.north_east, color: Colors.red),
                ),
              ],
              selected: {draft.kind},
              onSelectionChanged: (s) {
                ref.read(voucherDraftProvider.notifier).state =
                    draft.copyWith(kind: s.first);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text(l10n.navClients),
              subtitle: Text(draft.clientLabel ?? '—'),
              trailing: const Icon(Icons.chevron_left),
              onTap: _pickClient,
            ),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.amount),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'cash', label: Text(l10n.cash)),
                ButtonSegment(value: 'transfer', label: Text(l10n.transfer)),
              ],
              selected: {draft.method},
              onSelectionChanged: (s) {
                ref.read(voucherDraftProvider.notifier).state =
                    draft.copyWith(method: s.first);
              },
            ),
            if (isSpend) ...[
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                      value: 'materials', label: Text(l10n.materials)),
                  ButtonSegment(value: 'labor', label: Text(l10n.labor)),
                ],
                selected: {draft.expenseType},
                onSelectionChanged: (s) {
                  ref.read(voucherDraftProvider.notifier).state =
                      draft.copyWith(
                    expenseType: s.first,
                    clearCraftsman: true,
                    clearSupplier: true,
                  );
                },
              ),
              ListTile(
                title: Text(l10n.item),
                subtitle: Text(draft.itemLabel ?? '—'),
                onTap: _pickItem,
              ),
              if (draft.expenseType == 'materials')
                ListTile(
                  title: Text(l10n.supplier),
                  subtitle: Text(draft.supplierLabel ?? '—'),
                  onTap: _pickSupplier,
                ),
              if (draft.expenseType == 'labor')
                ListTile(
                  title: Text(l10n.craftsman),
                  subtitle: Text(draft.craftsmanLabel ?? '—'),
                  onTap: _pickCraftsman,
                ),
            ],
            TextField(
              controller: _descCtrl,
              decoration: InputDecoration(labelText: l10n.descriptionOptional),
            ),
            if (_receiptPath != null)
              ListTile(
                leading: const Icon(Icons.photo),
                title: Text(p.basename(_receiptPath!)),
                trailing: IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(),
                        body: Center(child: Image.file(File(_receiptPath!))),
                      ),
                    ),
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: _attachPhoto,
              icon: const Icon(Icons.photo),
              label: const Text('Receipt photo'),
            ),
            const SizedBox(height: 12),
            AppButton(label: l10n.save, onPressed: _save),
            AppButton(
              label: l10n.cancel,
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
