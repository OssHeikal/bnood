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
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_toaster.dart';
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
    _receiptPath = null;
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
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => _PickerList(
        title: AppLocalizations.of(ctx).navClients,
        items: clients.map((c) => (c.id, c.name)).toList(),
        onCreate: () async {
          final created = await Navigator.of(ctx).push<String>(
            MaterialPageRoute(builder: (_) => const InlineCreateClientPage()),
          );
          if (created != null && ctx.mounted) Navigator.of(ctx).pop(created);
        },
      ),
    );
    if (picked == null) return;
    final project = await repo.primaryActiveProject(picked);
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(
            clientId: picked, projectId: project?.id, clearCraftsman: true);
    setState(() {});
  }

  Future<void> _pickItem() async {
    final items = await ref.read(repositoryProvider).watchActiveItems().first;
    if (!mounted) return;
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => _PickerList(
        title: AppLocalizations.of(ctx).item,
        items: items.map((i) => (i.id, i.name)).toList(),
        onCreate: () async {
          final id = await Navigator.of(ctx).push<String>(
            MaterialPageRoute(builder: (_) => const InlineCreateItemPage()),
          );
          if (id != null && ctx.mounted) Navigator.of(ctx).pop(id);
        },
      ),
    );
    if (picked != null) {
      ref.read(voucherDraftProvider.notifier).state =
          ref.read(voucherDraftProvider).copyWith(itemId: picked);
      setState(() {});
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final draft = ref.read(voucherDraftProvider);
    final amount = MoneyFormat.parseEgpInput(_amountCtrl.text);
    if (draft.projectId == null || amount == null || amount <= 0) {
      AppToaster.show('أكمل البيانات', kind: ToastKind.failure);
      return;
    }
    final repo = ref.read(repositoryProvider);
    final date = draft.date ?? DateTime.now();
    if (draft.kind == 'spend' && draft.itemId == null) {
      AppToaster.show('اختر البند', kind: ToastKind.failure);
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
      AppToaster.show(l10n.save, kind: ToastKind.success);
      if (mounted) Navigator.of(context).pop();
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.navAdd, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'receive',
                    label: Text(l10n.receive),
                    icon: const Icon(Icons.south_west, color: Colors.green)),
                ButtonSegment(
                    value: 'spend',
                    label: Text(l10n.spend),
                    icon: const Icon(Icons.north_east, color: Colors.red)),
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
              subtitle: Text(draft.clientId ?? '—'),
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
                          clearSupplier: true);
                },
              ),
              ListTile(
                  title: Text(l10n.item),
                  subtitle: Text(draft.itemId ?? '—'),
                  onTap: _pickItem),
            ],
            TextField(
              controller: _descCtrl,
              decoration: InputDecoration(labelText: l10n.descriptionOptional),
            ),
            TextButton.icon(
                onPressed: _attachPhoto,
                icon: const Icon(Icons.photo),
                label: const Text('Receipt photo')),
            const SizedBox(height: 12),
            AppButton(label: l10n.save, onPressed: _save),
            AppButton(
                label: l10n.cancel,
                variant: AppButtonVariant.text,
                onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class _PickerList extends StatelessWidget {
  const _PickerList(
      {required this.title, required this.items, required this.onCreate});

  final String title;
  final List<(String id, String label)> items;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(title)),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.createNew),
            onTap: onCreate,
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return ListTile(
                  title: Text(item.$2),
                  onTap: () => Navigator.pop(context, item.$1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
