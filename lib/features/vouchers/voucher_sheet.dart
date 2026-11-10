import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/formatting/display_digits.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/extensions/text_style_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/database/database.dart' show TransactionsCompanion;
import '../../core/api/auth_api_exception.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/money/money_format.dart';
import '../../core/money/remote_money_format.dart';
import '../../core/items/items_providers.dart';
import '../../core/items/items_repository.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers_api/providers_riverpod.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/vouchers/vouchers_riverpod.dart';
import '../subscription/subscription_gates.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_list_tile.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/entity_picker_page.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/toast/app_tone.dart';
import 'inline_create_routes.dart';
import 'receipt_image_codec.dart';
import 'voucher_date_sheet.dart';
import 'voucher_draft.dart';
import 'voucher_form_chrome.dart';
import 'voucher_launcher.dart';
import 'voucher_picker_cards.dart';
import 'voucher_selector_field.dart';
import 'voucher_camera_pick_route.dart';
import 'voucher_picker_resolution.dart';
import 'voucher_receipt_picker.dart';
import 'voucher_transaction_date_bounds.dart';
import '../../core/providers/transaction_mutation_refresh.dart';
import 'voucher_remote_mutation.dart';
import 'voucher_remote_receipts.dart';
import 'voucher_receipt_upload_errors.dart';
import 'voucher_sheet_receipt.dart';

class VoucherSheet extends ConsumerStatefulWidget {
  const VoucherSheet({super.key});

  @override
  ConsumerState<VoucherSheet> createState() => _VoucherSheetState();
}

class _VoucherSheetState extends ConsumerState<VoucherSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _receiptRows = <VoucherSheetReceipt>[];
  final _pendingReceiptDeletes = <String>{};
  final _receiptPicker = VoucherReceiptPicker();
  var _recoveringLostPick = false;
  var _attemptedSubmit = false;
  var _saving = false;
  var _deleting = false;
  String? _clientPickerError;
  String? _itemPickerError;
  String? _craftsmanPickerError;

  bool get _isEditing => ref.read(voucherDraftProvider).editingTransactionId != null;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(voucherDraftProvider);
    if (draft.amountPiastres != null) {
      final remote = ref.read(remoteVouchersEnabledProvider);
      _amountCtrl.text = remote
          ? RemoteMoneyFormat.majorInputTextFromMinor(draft.amountPiastres!)
          : _localAmountFieldText(draft.amountPiastres!);
    }
    _descCtrl.text = draft.description ?? '';
    _receiptRows.addAll(
      ReceiptImageCodec.decode(draft.receiptImagePath).map(
        (path) => VoucherSheetReceipt(localPath: path),
      ),
    );
    final remote = ref.read(remoteVouchersEnabledProvider);
    if (remote && draft.editingTransactionId != null) {
      _hydrateRemoteReceipts(draft.editingTransactionId!);
    }
    if (Platform.isAndroid) {
      _recoverAndroidLostPick();
    }
  }

  Future<void> _hydrateRemoteReceipts(String voucherId) async {
    try {
      final repo = ref.read(vouchersRepositoryProvider);
      final voucher = await repo.getVoucher(voucherId);
      if (!mounted) return;
      final rows = voucher.receipts.isEmpty
          ? <VoucherSheetReceipt>[]
          : await downloadRemoteReceipts(repo: repo, metadata: voucher.receipts);
      if (!mounted) return;
      setState(() {
        _receiptRows
          ..clear()
          ..addAll(rows);
      });
    } catch (_) {
      // Keep sheet usable; receipts section may stay empty until retry.
    }
  }

  Future<void> _refreshRemoteReceiptsKeepingPendingUploads(String voucherId) async {
    final pendingUploads = _receiptRows.where((r) => r.isPendingUpload).toList();
    await _hydrateRemoteReceipts(voucherId);
    if (!mounted) return;
    if (pendingUploads.isEmpty) return;
    setState(() => _receiptRows.addAll(pendingUploads));
  }

  Future<void> _recoverAndroidLostPick() async {
    if (_recoveringLostPick) {
      return;
    }
    _recoveringLostPick = true;
    try {
      final files = await _receiptPicker.recoverLostData();
      if (files.isEmpty || !mounted) {
        return;
      }
      final saved = <String>[];
      for (final file in files) {
        final path = await _persistPick(file);
        if (path != null) {
          saved.add(path);
        }
      }
      if (saved.isNotEmpty && mounted) {
        await _appendPaths(saved);
      }
    } on VoucherReceiptPickException {
      // Leave draft intact; user can re-attach.
    } finally {
      _recoveringLostPick = false;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _localAmountFieldText(int piastres) {
    final pounds = piastres / 100;
    final whole = pounds.truncateToDouble() == pounds ? pounds.toInt().toString() : pounds.toStringAsFixed(2);
    return whole;
  }

  Future<void> _pickClient() async {
    if (_isEditing) return;
    if (ref.read(remoteVouchersEnabledProvider)) {
      await _pickClientRemote();
      return;
    }
    final repo = ref.read(repositoryProvider);
    final clients = await repo.watchActiveClients();
    if (!mounted) return;
    final locale = Localizations.localeOf(context).languageCode;
    final balances = <String, int>{};
    for (final c in clients) {
      final project = await repo.primaryActiveProject(c.id);
      if (project == null) {
        balances[c.id] = 0;
      } else {
        final balance = await repo.projectBalance(project.id);
        balances[c.id] = balance.balancePiastres;
      }
    }
    if (!mounted) return;
    final draft = ref.read(voucherDraftProvider);
    final l10n = AppLocalizations.of(context);
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerPage(
          title: l10n.navClients,
          entries: clients.map((c) => (c.id, c.name)).toList(),
          selectedId: draft.clientId,
          emptyTitle: l10n.homeNoActiveClientsTitle,
          emptyDescription: l10n.homeNoActiveClientsDescription,
          tileBuilder: (ctx, id, selected, onSelect, showDivider) => VoucherPickerClientCard(
            name: clients.firstWhere((c) => c.id == id).name,
            clientId: id,
            remainingPiastres: balances[id] ?? 0,
            localeCode: locale,
            selected: selected,
            onTap: onSelect,
            showDivider: showDivider,
          ),
          onCreateRoute: () => const InlineCreateClientPage(),
          onBeforeCreate: (ctx) => guardCreateActiveProject(ctx, ref),
        ),
      ),
    );
    if (picked == null) return;
    final client = await resolveLocalClient(ref.read, picked, cached: clients);
    final project = await repo.primaryActiveProject(picked);
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(clientId: picked, clientLabel: client.name, projectId: project?.id, clearCraftsman: true);
    setState(() => _clientPickerError = null);
  }

  Future<void> _pickClientRemote() async {
    final clientsRepo = ref.read(clientsRepositoryProvider);
    final clientsPage = await clientsRepo.listClients(status: ClientListArchiveFilter.active);
    final clients = clientsPage.items;
    if (!mounted) return;
    final locale = Localizations.localeOf(context).languageCode;
    final balances = <String, int>{};
    for (final record in clients) {
      balances[record.client.id] = record.balances?.remainingPiastres ?? 0;
    }
    final draft = ref.read(voucherDraftProvider);
    final l10n = AppLocalizations.of(context);
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerPage(
          title: l10n.navClients,
          entries: clients.map((c) => (c.client.id, c.client.name)).toList(),
          selectedId: draft.clientId,
          emptyTitle: l10n.homeNoActiveClientsTitle,
          emptyDescription: l10n.homeNoActiveClientsDescription,
          tileBuilder: (ctx, id, selected, onSelect, showDivider) => VoucherPickerClientCard(
            name: clients.firstWhere((c) => c.client.id == id).client.name,
            clientId: id,
            remainingPiastres: balances[id] ?? 0,
            localeCode: locale,
            selected: selected,
            onTap: onSelect,
            showDivider: showDivider,
          ),
          onCreateRoute: () => const InlineCreateClientPage(),
          onBeforeCreate: (ctx) => guardCreateActiveProject(ctx, ref),
        ),
      ),
    );
    if (picked == null) return;
    final record = await resolveRemoteClient(ref.read, picked, cached: clients);
    ref.read(voucherDraftProvider.notifier).state = ref.read(voucherDraftProvider).copyWith(
          clientId: picked,
          clientLabel: record.client.name,
          projectId: record.project.id,
          clearCraftsman: true,
        );
    setState(() => _clientPickerError = null);
  }

  Future<void> _pickItem() async {
    final List<({String id, String name, String colorKey, String iconKey})> items;
    if (ref.read(remoteItemsEnabledProvider)) {
      final catalogItems = await fetchAllCatalogItems(ref.read(itemsRepositoryProvider));
      items = catalogItems
          .map((i) => (id: i.id, name: i.name, colorKey: i.colorKey, iconKey: i.iconKey))
          .toList();
    } else {
      final local = await ref.read(repositoryProvider).watchActiveItems().first;
      items = local
          .map((i) => (id: i.id, name: i.name, colorKey: i.colorKey, iconKey: i.iconName))
          .toList();
    }
    if (!mounted) return;
    final draft = ref.read(voucherDraftProvider);
    final l10n = AppLocalizations.of(context);
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerPage(
          title: l10n.item,
          entries: items.map((i) => (i.id, i.name)).toList(),
          selectedId: draft.itemId,
          tileBuilder: (ctx, id, selected, onSelect, showDivider) {
            final item = items.firstWhere((i) => i.id == id);
            return VoucherPickerItemCard(
              name: item.name,
              colorKey: item.colorKey,
              iconName: item.iconKey,
              selected: selected,
              onTap: onSelect,
              showDivider: showDivider,
            );
          },
          onCreateRoute: () => const InlineCreateItemPage(),
        ),
      ),
    );
    if (picked == null) return;
    final remoteItems = ref.read(remoteItemsEnabledProvider);
    final cachedLabel = labelFromPickerEntries(items.map((i) => (i.id, i.name)).toList(), picked);
    final label = await resolveItemLabel(ref.read, picked, remote: remoteItems, cachedLabel: cachedLabel);
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(itemId: picked, itemLabel: label);
    setState(() => _itemPickerError = null);
  }

  Future<void> _pickSupplier() async {
    if (ref.read(remoteVouchersEnabledProvider)) {
      await _pickSupplierRemote();
      return;
    }
    final suppliers = await ref.read(repositoryProvider).watchActiveSuppliers().first;
    if (!mounted) return;
    final draft = ref.read(voucherDraftProvider);
    final l10n = AppLocalizations.of(context);
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerPage(
          title: l10n.supplier,
          entries: suppliers.map((s) => (s.id, s.name)).toList(),
          selectedId: draft.supplierId,
          searchKeys: suppliers.map((s) => s.phone ?? '').toList(),
          tileBuilder: (ctx, id, selected, onSelect, showDivider) {
            final s = suppliers.firstWhere((e) => e.id == id);
            return VoucherPickerSupplierCard(
              name: s.name,
              phone: s.phone,
              selected: selected,
              onTap: onSelect,
              showDivider: showDivider,
            );
          },
          onCreateRoute: () => const InlineCreateSupplierPage(),
        ),
      ),
    );
    if (picked == null) return;
    final label = await resolveLocalSupplierLabel(ref.read, picked, cached: suppliers);
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(supplierId: picked, supplierLabel: label);
    setState(() {});
  }

  Future<void> _pickSupplierRemote() async {
    final suppliers = await ref.read(appProvidersRepositoryProvider).listAllSuppliers();
    if (!mounted) return;
    final draft = ref.read(voucherDraftProvider);
    final l10n = AppLocalizations.of(context);
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerPage(
          title: l10n.supplier,
          entries: suppliers.map((s) => (s.id, s.name)).toList(),
          selectedId: draft.supplierId,
          searchKeys: suppliers.map((s) => s.phone ?? '').toList(),
          tileBuilder: (ctx, id, selected, onSelect, showDivider) {
            final s = suppliers.firstWhere((e) => e.id == id);
            return VoucherPickerSupplierCard(
              name: s.name,
              phone: s.phone,
              selected: selected,
              onTap: onSelect,
              showDivider: showDivider,
            );
          },
          onCreateRoute: () => const InlineCreateSupplierPage(),
        ),
      ),
    );
    if (picked == null) return;
    final label = await resolveRemoteProviderLabel(ref.read, picked, cached: suppliers);
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(supplierId: picked, supplierLabel: label);
    setState(() {});
  }

  Future<void> _pickCraftsman() async {
    if (ref.read(remoteVouchersEnabledProvider)) {
      await _pickCraftsmanRemote();
      return;
    }
    final draft = ref.read(voucherDraftProvider);
    if (draft.projectId == null) {
      setState(() => _craftsmanPickerError = AppLocalizations.of(context).voucherSelectClient);
      return;
    }
    final craftsmen = await ref.read(repositoryProvider).watchActiveCraftsmen().first;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (craftsmen.isEmpty) {
      AppToaster.show(l10n.voucherSelectCraftsman, kind: ToastKind.warning);
      return;
    }
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerPage(
          title: l10n.craftsman,
          entries: craftsmen.map((c) => (c.id, c.name)).toList(),
          selectedId: draft.craftsmanId,
          searchKeys: craftsmen.map((c) => c.trade ?? '').toList(),
          tileBuilder: (ctx, id, selected, onSelect, showDivider) {
            final c = craftsmen.firstWhere((e) => e.id == id);
            return VoucherPickerCraftsmanCard(
              name: c.name,
              trade: c.trade,
              selected: selected,
              onTap: onSelect,
              showDivider: showDivider,
            );
          },
          onCreateRoute: () => const InlineCreateCraftsmanPage(),
        ),
      ),
    );
    if (picked == null) return;
    final label = await resolveLocalCraftsmanLabel(ref.read, picked, cached: craftsmen);
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(craftsmanId: picked, craftsmanLabel: label);
    setState(() => _craftsmanPickerError = null);
  }

  Future<void> _pickCraftsmanRemote() async {
    final draft = ref.read(voucherDraftProvider);
    if (draft.clientId == null) {
      setState(() => _craftsmanPickerError = AppLocalizations.of(context).voucherSelectClient);
      return;
    }
    final craftsmen = await ref.read(appProvidersRepositoryProvider).listAllCraftsmen();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (craftsmen.isEmpty) {
      AppToaster.show(l10n.voucherSelectCraftsman, kind: ToastKind.warning);
      return;
    }
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerPage(
          title: l10n.craftsman,
          entries: craftsmen.map((c) => (c.id, c.name)).toList(),
          selectedId: draft.craftsmanId,
          searchKeys: craftsmen.map((c) => '').toList(),
          tileBuilder: (ctx, id, selected, onSelect, showDivider) {
            final c = craftsmen.firstWhere((e) => e.id == id);
            return VoucherPickerCraftsmanCard(
              name: c.name,
              trade: null,
              selected: selected,
              onTap: onSelect,
              showDivider: showDivider,
            );
          },
          onCreateRoute: () => const InlineCreateCraftsmanPage(),
        ),
      ),
    );
    if (picked == null) return;
    final label = await resolveRemoteProviderLabel(ref.read, picked, cached: craftsmen);
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(craftsmanId: picked, craftsmanLabel: label);
    setState(() => _craftsmanPickerError = null);
  }

  bool _validatePickers(VoucherDraft draft, AppLocalizations l10n) {
    var valid = true;
    if (draft.projectId == null || draft.clientId == null) {
      _clientPickerError = l10n.voucherSelectClient;
      valid = false;
    }
    if (draft.kind == 'spend' && draft.itemId == null) {
      _itemPickerError = l10n.voucherSelectItem;
      valid = false;
    }
    if (draft.kind == 'spend' && draft.expenseType == 'labor' && draft.craftsmanId == null) {
      _craftsmanPickerError = l10n.voucherSelectCraftsman;
      valid = false;
    }
    return valid;
  }

  Future<void> _confirmDelete() async {
    if (_saving || _deleting) return;
    final draft = ref.read(voucherDraftProvider);
    final txId = draft.editingTransactionId;
    if (txId == null) return;
    final remote = ref.read(remoteVouchersEnabledProvider);

    final l10n = AppLocalizations.of(context);
    final answer = await AppDecision.show(
      context,
      title: l10n.deleteMovementTitle,
      description: l10n.deleteMovementBody,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      tone: AppTone.danger,
      iconWidget: AppDecision.archiveDangerIcon(context),
    );
    if (answer != OverlayAnswer.confirmed || !mounted) return;

    setState(() => _deleting = true);
    try {
      if (remote) {
        final ok = await deleteRemoteVoucher(context: context, ref: ref, draft: draft);
        if (!ok) return;
      } else {
        final repo = ref.read(repositoryProvider);
        final tx = await repo.getTransaction(txId);
        if (tx == null) return;
        await repo.deleteTransaction(txId);
        final project = await repo.projectById(tx.projectId);
        refreshAfterTransactionMutation(
          ref,
          clientId: draft.clientId ?? project?.clientId,
          supplierId: tx.supplierId,
          craftsmanId: tx.craftsmanId,
        );
      }
      AppToaster.show(l10n.delete, kind: ToastKind.success);
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    } on AuthApiException catch (e) {
      if (mounted) AppToaster.show(e.message, kind: ToastKind.failure);
    } catch (e) {
      if (mounted) AppToaster.show('$e', kind: ToastKind.failure);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _save() async {
    if (_saving || _deleting) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _attemptedSubmit = true);
    final draft = ref.read(voucherDraftProvider);
    final amountFieldValid = _formKey.currentState?.validate() == true;
    final pickersValid = _validatePickers(draft, l10n);
    if (!amountFieldValid || !pickersValid) {
      setState(() {});
      return;
    }
    final remote = ref.read(remoteVouchersEnabledProvider);
    if (remote && !await guardFinancialMutation(context, ref)) return;
    final amount = remote
        ? RemoteMoneyFormat.parseMajorInput(_amountCtrl.text)
        : MoneyFormat.parseEgpInput(_amountCtrl.text);
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);
    final repo = ref.read(repositoryProvider);
    final date = draft.date ?? DateTime.now();
    try {
      if (remote) {
        final result = await saveRemoteVoucher(
          context: context,
          ref: ref,
          draft: draft,
          amountMinor: amount,
          description: _descCtrl.text,
          receipts: _receiptRows,
          pendingReceiptDeletes: _pendingReceiptDeletes.toList(),
        );
        if (!result.voucherSaved) {
          if (mounted) setState(() => _saving = false);
          return;
        }
        if (result.voucher != null) {
          ref.read(voucherDraftProvider.notifier).state = draft.copyWith(
                editingTransactionId: result.voucher!.id,
              );
        }
        if (mounted) {
          _pendingReceiptDeletes.removeWhere((id) => result.deletedReceiptIds.contains(id));
          _pendingReceiptDeletes.addAll(result.failedDeleteReceiptIds);
          setState(() => _receiptRows
            ..clear()
            ..addAll(result.receipts));
        }
        if (result.failedReceiptDeletes > 0) {
          if (mounted && result.voucher != null) {
            await _refreshRemoteReceiptsKeepingPendingUploads(result.voucher!.id);
            AppToaster.show(l10n.voucherReceiptDeleteRetry, kind: ToastKind.warning);
            setState(() => _saving = false);
          }
          return;
        }
        if (result.failedReceiptUploads > 0) {
          if (mounted) {
            AppToaster.show(
              voucherReceiptUploadErrorMessage(l10n, result.lastReceiptError),
              kind: ToastKind.warning,
            );
            setState(() => _saving = false);
          }
          return;
        }
        AppToaster.show(l10n.save, kind: ToastKind.success);
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        return;
      }
      if (draft.editingTransactionId != null) {
        await repo.updateTransaction(
          draft.editingTransactionId!,
          TransactionsCompanion(
            kind: Value(draft.kind),
            amountPiastres: Value(amount),
            date: Value(date),
            method: Value(draft.method),
            description: Value(_descCtrl.text.isEmpty ? null : _descCtrl.text),
            receiptImagePath: Value(ReceiptImageCodec.encode(_receiptRows.map((e) => e.localPath).toList())),
            itemId: Value(draft.kind == 'spend' ? draft.itemId : null),
            expenseType: Value(draft.kind == 'spend' ? draft.expenseType : null),
            supplierId: Value(draft.expenseType == 'materials' ? draft.supplierId : null),
            craftsmanId: Value(draft.expenseType == 'labor' ? draft.craftsmanId : null),
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
          receiptImagePath: ReceiptImageCodec.encode(_receiptRows.map((e) => e.localPath).toList()),
          itemId: draft.kind == 'spend' ? draft.itemId : null,
          expenseType: draft.kind == 'spend' ? draft.expenseType : null,
          supplierId: draft.expenseType == 'materials' ? draft.supplierId : null,
          craftsmanId: draft.expenseType == 'labor' ? draft.craftsmanId : null,
        );
      }
      if (draft.kind == 'spend' &&
          draft.expenseType == 'labor' &&
          draft.craftsmanId != null &&
          draft.projectId != null) {
        await repo.ensureProjectCraftsmanLink(projectId: draft.projectId!, craftsmanId: draft.craftsmanId!);
      }
      refreshAfterTransactionMutation(
        ref,
        clientId: draft.clientId,
        supplierId: draft.expenseType == 'materials' ? draft.supplierId : null,
        craftsmanId: draft.expenseType == 'labor' ? draft.craftsmanId : null,
      );
      AppToaster.show(l10n.save, kind: ToastKind.success);
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      AppToaster.show('$e', kind: ToastKind.failure);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final draft = ref.read(voucherDraftProvider);
    final initial = draft.date ?? DateTime.now();
    final picked = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        builder: (_) => VoucherDateSheetPage(
          initial: initial,
          firstDate: VoucherTransactionDateBounds.first,
          lastDate: VoucherTransactionDateBounds.last,
        ),
      ),
    );
    if (picked == null || !mounted) return;
    ref.read(voucherDraftProvider.notifier).state = draft.copyWith(date: picked);
    setState(() {});
  }

  String _formattedDate(DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final raw = DateFormat.yMMMd(locale).format(date);
    return DisplayDigits.toWesternDigits(raw);
  }

  Future<String?> _persistPick(XFile file) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'receipts'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final name = '${DateTime.now().microsecondsSinceEpoch}${p.extension(file.path)}';
    final saved = await File(file.path).copy(p.join(dir.path, name));
    return saved.path;
  }

  Future<void> _appendPaths(List<String> paths) async {
    if (paths.isEmpty) return;
    final remote = ref.read(remoteVouchersEnabledProvider);
    setState(() {
      _receiptRows.addAll(
        paths.map((path) => VoucherSheetReceipt(localPath: path, needsUpload: remote)),
      );
    });
  }

  Future<void> _attachFromCamera() async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await Navigator.of(context).push<VoucherCameraPickResult>(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.transparent,
          pageBuilder: (context, animation, secondaryAnimation) =>
              VoucherCameraPickRoute(picker: _receiptPicker),
        ),
      );
      if (result == null || !mounted) {
        return;
      }
      if (result.error != null) {
        AppToaster.show(voucherReceiptPickUserMessage(l10n, result.error!), kind: ToastKind.warning);
        return;
      }
      final file = result.file;
      if (file == null) {
        return;
      }
      final saved = await _persistPick(file);
      if (saved != null) {
        await _appendPaths([saved]);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppToaster.show(l10n.voucherReceiptAttachFailed, kind: ToastKind.warning);
    }
  }

  Future<void> _attachFromGallery() async {
    final l10n = AppLocalizations.of(context);
    try {
      final files = await _receiptPicker.pickGallery();
      if (files.isEmpty) {
        return;
      }
      final saved = <String>[];
      for (final file in files) {
        final path = await _persistPick(file);
        if (path != null) {
          saved.add(path);
        }
      }
      await _appendPaths(saved);
    } on VoucherReceiptPickException catch (e) {
      if (!mounted) {
        return;
      }
      AppToaster.show(voucherReceiptPickUserMessage(l10n, e), kind: ToastKind.warning);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppToaster.show(l10n.voucherReceiptAttachFailed, kind: ToastKind.warning);
    }
  }

  Future<void> _removeReceiptAt(int index) async {
    final row = _receiptRows[index];
    final remote = ref.read(remoteVouchersEnabledProvider);
    if (remote && _isEditing && row.serverId != null) {
      setState(() {
        _pendingReceiptDeletes.add(row.serverId!);
        _receiptRows.removeAt(index);
      });
      return;
    }
    if (!mounted) return;
    setState(() => _receiptRows.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(voucherDraftProvider);
    final isSpend = draft.kind == 'spend';
    final isEditing = draft.editingTransactionId != null;
    final title = isEditing ? l10n.edit : (isSpend ? l10n.voucherSpendTitle : l10n.voucherReceiveTitle);
    final saveLabel = isEditing ? l10n.save : (isSpend ? l10n.voucherSaveSpend : l10n.voucherSaveReceive);
    final txDate = draft.date ?? DateTime.now();
    final contextLine = draft.clientLabel != null
        ? l10n.voucherContextClient(draft.clientLabel!)
        : l10n.voucherContextGeneric;

    Widget saveButton = isSpend && !isEditing
        ? AppButton.destructive(text: saveLabel, isLoading: _saving, onPressed: (_saving || _deleting) ? null : _save)
        : AppButton.primary(text: saveLabel, isLoading: _saving, onPressed: (_saving || _deleting) ? null : _save);

    final footerActions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSize.spaceSM,
      children: [
        saveButton,
        if (isEditing)
          AppButton.destructive(
            text: l10n.delete,
            isLoading: _deleting,
            onPressed: (_saving || _deleting) ? null : _confirmDelete,
          ),
      ],
    );

    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final safeBottom = viewPadding.bottom > 0 ? viewPadding.bottom : AppSize.spaceMD;
    final footerBottom = viewInsets.bottom > 0 ? AppSize.spaceMD : safeBottom;

    return Material(
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSize.screenPadding, AppSize.spaceSM, AppSize.screenPadding, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetDragHandle(),
                AppSize.spaceMD.gap,
                Row(
                  children: [
                    Expanded(child: Text(title, style: context.text.title)),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                AppSize.spaceSM,
                AppSize.screenPadding,
                AppSize.spaceLG,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSize.spaceLG,
                children: [
                  Text(contextLine, style: context.text.caption.setColor(context.colors.onSurfaceMuted)),
                  VoucherTogglePair(
                    receiveLabel: l10n.receive,
                    spendLabel: l10n.spend,
                    selectedKind: draft.kind,
                    enabled: !isEditing,
                    onKindChanged: (kind) {
                      ref.read(voucherDraftProvider.notifier).state = draft.copyWith(kind: kind);
                    },
                  ),
                  Form(
                    key: _formKey,
                    autovalidateMode: _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSize.spaceLG,
                      children: [
                        VoucherSelectorField(
                          label: l10n.navClients,
                          value: draft.clientLabel,
                          placeholder: l10n.voucherSelectClient,
                          enabled: !isEditing,
                          onTap: isEditing ? null : _pickClient,
                          errorMessage: _clientPickerError,
                        ),
                        if (isSpend) ...[
                          Text(l10n.expenseCategory, style: context.text.body.semiBold),
                          VoucherExpenseSegment(
                            materialsLabel: l10n.materials,
                            laborLabel: l10n.labor,
                            selected: draft.expenseType,
                            onChanged: (value) {
                              ref.read(voucherDraftProvider.notifier).state = draft.copyWith(
                                expenseType: value,
                                clearCraftsman: true,
                                clearSupplier: true,
                              );
                              setState(() {
                                _craftsmanPickerError = null;
                                _itemPickerError = null;
                              });
                            },
                          ),
                          VoucherSelectorField(
                            label: l10n.item,
                            value: draft.itemLabel,
                            placeholder: l10n.voucherSelectItem,
                            onTap: _pickItem,
                            errorMessage: _itemPickerError,
                          ),
                          if (draft.expenseType == 'materials')
                            VoucherSelectorField(
                              label: l10n.supplier,
                              value: draft.supplierLabel,
                              placeholder: l10n.supplier,
                              onTap: _pickSupplier,
                            ),
                          if (draft.expenseType == 'labor')
                            VoucherSelectorField(
                              label: l10n.craftsman,
                              value: draft.craftsmanLabel,
                              placeholder: l10n.voucherSelectCraftsman,
                              onTap: _pickCraftsman,
                              errorMessage: _craftsmanPickerError,
                            ),
                        ],
                        CustomTextField(
                          controller: _amountCtrl,
                          label: l10n.amount,
                          placeholder: l10n.amountHint,
                          type: AppInputType.currency,
                          ltrValue: true,
                          suffix: Text(MoneyFormat.currencyLabel),
                          fieldHeight: AppSize.fieldHeightComfortable,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final amount = MoneyFormat.parseEgpInput(value ?? '');
                            if (amount == null || amount <= 0) {
                              return l10n.voucherAmountRequired;
                            }
                            return null;
                          },
                        ),
                        VoucherSelectorField(
                          key: ValueKey(txDate.toIso8601String()),
                          label: l10n.date,
                          value: _formattedDate(txDate),
                          onTap: _pickDate,
                        ),
                        Text(l10n.paymentMethod, style: context.text.body.semiBold),
                        VoucherPayChips(
                          cashLabel: l10n.cash,
                          transferLabel: l10n.transfer,
                          selected: draft.method,
                          onChanged: (method) {
                            ref.read(voucherDraftProvider.notifier).state = draft.copyWith(method: method);
                          },
                        ),
                        CustomTextField(
                          controller: _descCtrl,
                          label: l10n.descriptionOptional,
                          placeholder: l10n.noteOptionalHint,
                          type: AppInputType.multiline,
                          multilineHeight: 96,
                          fieldHeight: AppSize.fieldHeightComfortable,
                          textInputAction: TextInputAction.done,
                        ),
                        Text(l10n.voucherReceiptPhoto, style: context.text.body.semiBold),
                        for (var i = 0; i < _receiptRows.length; i++)
                          CustomListTile(
                            leading: const Icon(Icons.photo_outlined),
                            title: l10n.voucherReceiptPhoto,
                            subtitle: p.basename(_receiptRows[i].localPath),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeReceiptAt(i),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  appBar: const CustomAppBar(),
                                  body: Center(child: Image.file(File(_receiptRows[i].localPath))),
                                ),
                              ),
                            ),
                          ),
                        Row(
                          spacing: AppSize.spaceSM,
                          children: [
                            Expanded(
                              child: AppPressable(
                                onPressed: _attachFromCamera,
                                child: AppCard(
                                  padding: const EdgeInsets.all(AppSize.spaceMD),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: AppSize.spaceSM,
                                    children: [
                                      Icon(Icons.photo_camera_outlined, color: context.colors.primary),
                                      Text(
                                        l10n.voucherAttachCamera,
                                        style: context.text.caption.semiBold.setColor(context.colors.primaryDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: AppPressable(
                                onPressed: _attachFromGallery,
                                child: AppCard(
                                  padding: const EdgeInsets.all(AppSize.spaceMD),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: AppSize.spaceSM,
                                    children: [
                                      Icon(Icons.photo_library_outlined, color: context.colors.primary),
                                      Text(
                                        l10n.voucherAttachGallery,
                                        style: context.text.caption.semiBold.setColor(context.colors.primaryDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.colors.outline)),
              color: context.colors.surface,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSize.screenPadding, AppSize.spaceMD, AppSize.screenPadding, footerBottom),
              child: footerActions,
            ),
          ),
        ],
      ),
    );
  }
}
