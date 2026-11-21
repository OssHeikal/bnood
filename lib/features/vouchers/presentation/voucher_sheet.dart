import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/formatting/display_digits.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/extensions/text_style_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/api/api_error_user_message.dart';
import '../../../core/api/auth_api_exception.dart';
import '../../clients/data/clients_providers.dart';
import '../../../core/money/money_format.dart';
import '../../../core/money/remote_money_format.dart';
import '../../items/data/items_providers.dart';
import '../../items/data/items_repository.dart';
import '../../../features/providers/data/providers_riverpod.dart';
import '../../clients/data/client_list_archive_filter.dart';
import '../data/vouchers_error_handler.dart';
import '../data/vouchers_riverpod.dart';
import '../../subscription/subscription_error_handler.dart';
import '../../subscription/subscription_gates.dart';
import '../../../core/widgets/app_toaster.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/custom_list_tile.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../features/providers/data/agreements_riverpod.dart';
import '../../../features/providers/data/app_provider_record.dart';
import '../../../core/widgets/entity_picker_load_page.dart';
import '../../../core/widgets/text_field/app_input_formatters.dart';
import 'voucher_picker_agreements.dart';
import '../../../core/widgets/overlay_form_presentation.dart';
import '../../../core/widgets/sheet_drag_handle.dart';
import '../../../core/widgets/dashed_border_frame.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/app_decision.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../core/widgets/toast/app_tone.dart';
import 'inline_create_routes.dart';
import 'receipt_image_codec.dart';
import 'voucher_item_create_page.dart';
import 'voucher_provider_link.dart';
import 'voucher_screen.dart';
import 'voucher_date_sheet.dart';
import 'voucher_draft.dart';
import 'voucher_form_chrome.dart';
import 'voucher_launcher.dart';
import 'voucher_picker_cards.dart';
import 'voucher_selector_field.dart';
import 'voucher_camera_pick_route.dart';
import 'voucher_receipt_source_sheet.dart';
import 'voucher_picker_resolution.dart';
import 'voucher_receipt_picker.dart';
import 'voucher_transaction_date_bounds.dart';
import 'voucher_remote_mutation.dart';
import 'voucher_remote_receipts.dart';
import 'voucher_receipt_upload_errors.dart';
import 'voucher_sheet_receipt.dart';

enum VoucherSheetPresentation { modal, fullScreen }

final GlobalKey<VoucherSheetState> voucherSheetStateKey = GlobalKey<VoucherSheetState>();

class VoucherSheet extends ConsumerStatefulWidget {
  const VoucherSheet({super.key, this.presentation = VoucherSheetPresentation.modal});

  final VoucherSheetPresentation presentation;

  @override
  ConsumerState<VoucherSheet> createState() => VoucherSheetState();
}

class VoucherSheetState extends ConsumerState<VoucherSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkAmountCtrl = TextEditingController();
  late VoucherDraft _baselineDraft;
  var _baselineAmountText = '';
  var _baselineDescText = '';
  var _baselineReceiptPaths = <String>[];
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

  OverlayFormPresentation get _nestedPresentation => widget.presentation == VoucherSheetPresentation.fullScreen
      ? OverlayFormPresentation.fullScreen
      : OverlayFormPresentation.inSheet;

  bool get hasNestedRouteToPop {
    final nav = Navigator.maybeOf(context);
    return nav != null && nav.canPop();
  }

  bool hasUnsavedChanges() {
    final draft = ref.read(voucherDraftProvider);
    if (!voucherDraftsEqual(draft, _baselineDraft)) return true;
    if (_amountCtrl.text.trim() != _baselineAmountText) return true;
    if (_descCtrl.text.trim() != _baselineDescText) return true;
    if (_linkAmountCtrl.text.trim().isNotEmpty) return true;
    final paths = _receiptRows.map((r) => r.localPath).toList();
    if (paths.length != _baselineReceiptPaths.length) return true;
    for (var i = 0; i < paths.length; i++) {
      if (paths[i] != _baselineReceiptPaths[i]) return true;
    }
    if (_pendingReceiptDeletes.isNotEmpty) return true;
    return false;
  }

  void _closeVoucherRoute() {
    if (widget.presentation == VoucherSheetPresentation.fullScreen) {
      if (context.mounted) Navigator.of(context).pop();
    } else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<int?> _inlineAgreementAmountPiastres() async {
    final raw = _linkAmountCtrl.text.trim();
    if (raw.isEmpty) return null;
    return RemoteMoneyFormat.parseMajorInput(raw);
  }

  @override
  void initState() {
    super.initState();
    final draft = ref.read(voucherDraftProvider);
    _baselineDraft = draft;
    if (draft.amountPiastres != null) {
      final raw = RemoteMoneyFormat.majorInputTextFromMinor(draft.amountPiastres!);
      _amountCtrl.text = ThousandsGroupingFormatter.formatDisplay(raw, allowDecimal: true);
    }
    _descCtrl.text = draft.description ?? '';
    _baselineAmountText = _amountCtrl.text;
    _baselineDescText = _descCtrl.text;
    _receiptRows.addAll(
      ReceiptImageCodec.decode(draft.receiptImagePath).map((path) => VoucherSheetReceipt(localPath: path)),
    );
    _baselineReceiptPaths = _receiptRows.map((r) => r.localPath).toList();
    if (draft.editingTransactionId != null) {
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
    _linkAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickClient() async {
    if (_isEditing) return;
    await _pickClientRemote();
  }

  Future<void> _pickClientRemote() async {
    final clientsRepo = ref.read(clientsRepositoryProvider);
    final draft = ref.read(voucherDraftProvider);
    final l10n = AppLocalizations.of(context);
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerLoadPage(
          title: l10n.navClients,
          presentation: _nestedPresentation,
          selectedId: draft.clientId,
          onBeforeCreate: (ctx) => guardCreateActiveProject(ctx, ref),
          onCreateRoute: () => InlineCreateClientPage(presentation: _nestedPresentation),
          load: () async {
            final clientsPage = await clientsRepo.listClients(status: ClientListArchiveFilter.active);
            final clients = clientsPage.items;
            final balances = <String, int>{
              for (final record in clients) record.client.id: record.balances?.remainingPiastres ?? 0,
            };
            return EntityPickerLoadedBundle(
              entries: clients.map((c) => (c.client.id, c.client.name)).toList(),
              emptyTitle: l10n.homeNoActiveClientsTitle,
              emptyDescription: l10n.homeNoActiveClientsDescription,
              tileBuilder: (ctx, id, selected, onSelect, showDivider) {
                final localeCode = Localizations.localeOf(ctx).languageCode;
                return VoucherPickerClientCard(
                  name: clients.firstWhere((c) => c.client.id == id).client.name,
                  clientId: id,
                  remainingPiastres: balances[id] ?? 0,
                  localeCode: localeCode,
                  selected: selected,
                  onTap: onSelect,
                  showDivider: showDivider,
                );
              },
            );
          },
        ),
      ),
    );
    if (picked == null || !mounted) return;
    final record = await resolveRemoteClient(ref.read, picked);
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(
          clientId: picked,
          clientLabel: record.client.name,
          projectId: record.project.id,
          clearCraftsman: true,
          clearSupplier: true,
          clearProviderLink: true,
        );
    setState(() {
      _clientPickerError = null;
      _linkAmountCtrl.clear();
    });
  }

  Future<void> _pickItem() async {
    final draft = ref.read(voucherDraftProvider);
    final l10n = AppLocalizations.of(context);
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerLoadPage(
          title: l10n.item,
          presentation: _nestedPresentation,
          selectedId: draft.itemId,
          onCreateRoute: () => const VoucherItemCreatePage(),
          load: () async {
            final List<({String id, String name, String colorKey, String iconKey})> items;
            final catalogItems = await fetchAllCatalogItems(
                ref.read(itemsRepositoryProvider),
                status: ItemCatalogListStatus.active,
              );
              items = catalogItems
                  .map((i) => (id: i.id, name: i.name, colorKey: i.colorKey, iconKey: i.iconKey))
                  .toList();
            return EntityPickerLoadedBundle(
              entries: items.map((i) => (i.id, i.name)).toList(),
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
            );
          },
        ),
      ),
    );
    if (picked == null || !mounted) return;
    final label = await resolveItemLabel(ref.read, picked);
    ref.read(voucherDraftProvider.notifier).state = ref.read(voucherDraftProvider).copyWith(itemId: picked, itemLabel: label);
    setState(() => _itemPickerError = null);
  }

  Future<void> _pickSupplier() async {
    await _pickSupplierRemote();
  }

  Future<void> _pickSupplierRemote() async {
    final draft = ref.read(voucherDraftProvider);
    final clientId = draft.clientId;
    final l10n = AppLocalizations.of(context);
    var linkedForPick = const <String>{};
    final remainingForPick = <String, int>{};
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerLoadPage(
          title: l10n.supplier,
          presentation: _nestedPresentation,
          selectedId: draft.supplierId,
          onCreateRoute: () => InlineCreateSupplierPage(presentation: _nestedPresentation),
          load: () async {
            final suppliers = await ref.read(appProvidersRepositoryProvider).listAllSuppliers();
            if (clientId != null) {
              final agreements = await ref.read(appAgreementsRepositoryProvider).listAllClientAgreements(clientId);
              final ctx = remoteAgreementContext(agreements, AppProviderType.supplier);
              linkedForPick = ctx.linkedIds;
              remainingForPick
                ..clear()
                ..addAll(ctx.remainingByProviderId);
            } else {
              linkedForPick = const {};
              remainingForPick.clear();
            }
            return EntityPickerLoadedBundle(
              entries: suppliers.map((s) => (s.id, s.name)).toList(),
              searchKeys: suppliers.map((s) => s.phone ?? '').toList(),
              tileBuilder: (ctx, id, selected, onSelect, showDivider) {
                final s = suppliers.firstWhere((e) => e.id == id);
                final localeCode = Localizations.localeOf(ctx).languageCode;
                return VoucherPickerSupplierCard(
                  providerId: id,
                  name: s.name,
                  phone: s.phone,
                  localeCode: localeCode,
                  linkedToClient: linkedForPick.contains(s.id),
                  remainingPiastres: remainingForPick[id],
                  selected: selected,
                  onTap: onSelect,
                  showDivider: showDivider,
                );
              },
            );
          },
        ),
      ),
    );
    if (picked == null || !mounted) return;
    final suppliers = await ref.read(appProvidersRepositoryProvider).listAllSuppliers();
    final label = await resolveRemoteProviderLabel(ref.read, picked, cached: suppliers);
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(supplierId: picked, supplierLabel: label, providerLinkedToClient: linkedForPick.contains(picked));
    setState(() => _linkAmountCtrl.clear());
  }

  Future<void> _pickCraftsman() async {
    await _pickCraftsmanRemote();
  }

  Future<void> _pickCraftsmanRemote() async {
    final draft = ref.read(voucherDraftProvider);
    final clientId = draft.clientId;
    final l10n = AppLocalizations.of(context);
    var linkedForPick = const <String>{};
    final remainingForPick = <String, int>{};
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntityPickerLoadPage(
          title: l10n.craftsman,
          presentation: _nestedPresentation,
          selectedId: draft.craftsmanId,
          onCreateRoute: () => InlineCreateCraftsmanPage(presentation: _nestedPresentation),
          load: () async {
            final craftsmen = await ref.read(appProvidersRepositoryProvider).listAllCraftsmen();
            if (clientId != null) {
              final agreements = await ref.read(appAgreementsRepositoryProvider).listAllClientAgreements(clientId);
              final agreementCtx = remoteAgreementContext(agreements, AppProviderType.craftsman);
              linkedForPick = agreementCtx.linkedIds;
              remainingForPick
                ..clear()
                ..addAll(agreementCtx.remainingByProviderId);
            } else {
              linkedForPick = const {};
              remainingForPick.clear();
            }
            return EntityPickerLoadedBundle(
              entries: craftsmen.map((c) => (c.id, c.name)).toList(),
              searchKeys: craftsmen.map((c) => '').toList(),
              tileBuilder: (ctx, id, selected, onSelect, showDivider) {
                final c = craftsmen.firstWhere((e) => e.id == id);
                final localeCode = Localizations.localeOf(ctx).languageCode;
                return VoucherPickerCraftsmanCard(
                  providerId: id,
                  name: c.name,
                  trade: null,
                  localeCode: localeCode,
                  linkedToClient: linkedForPick.contains(c.id),
                  remainingPiastres: remainingForPick[id],
                  selected: selected,
                  onTap: onSelect,
                  showDivider: showDivider,
                );
              },
            );
          },
        ),
      ),
    );
    if (picked == null || !mounted) return;
    final craftsmen = await ref.read(appProvidersRepositoryProvider).listAllCraftsmen();
    final label = await resolveRemoteProviderLabel(ref.read, picked, cached: craftsmen);
    ref.read(voucherDraftProvider.notifier).state = ref
        .read(voucherDraftProvider)
        .copyWith(craftsmanId: picked, craftsmanLabel: label, providerLinkedToClient: linkedForPick.contains(picked));
    setState(() {
      _craftsmanPickerError = null;
      _linkAmountCtrl.clear();
    });
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
      final ok = await deleteRemoteVoucher(context: context, ref: ref, draft: draft);
      if (!ok) return;
      AppToaster.show(l10n.toastVoucherDeleted, kind: ToastKind.success);
      if (mounted) _closeVoucherRoute();
    } on AuthApiException catch (e) {
      if (!mounted) return;
      if (await handleVouchersApiAuthError(context: context, ref: ref, error: e)) return;
      if (!mounted) return;
      if (await handleSubscriptionApiError(context: context, ref: ref, error: e)) return;
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    } catch (e) {
      if (mounted) AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
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
    if (!await guardFinancialMutation(context, ref)) return;
    final amount = RemoteMoneyFormat.parseMajorInput(_amountCtrl.text);
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);
    final needsProviderLink = draft.kind == 'spend' && draft.providerLinkedToClient != true;
    final linkAmount = needsProviderLink ? await _inlineAgreementAmountPiastres() : null;
    try {
      if (needsProviderLink) {
        await ensureVoucherProviderAgreementBeforeSave(ref: ref, draft: draft, agreementAmountPiastres: linkAmount);
      }
      if (!mounted) return;
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
          ref.read(voucherDraftProvider.notifier).state = draft.copyWith(editingTransactionId: result.voucher!.id);
        }
        if (mounted) {
          _pendingReceiptDeletes.removeWhere((id) => result.deletedReceiptIds.contains(id));
          _pendingReceiptDeletes.addAll(result.failedDeleteReceiptIds);
          setState(
            () => _receiptRows
              ..clear()
              ..addAll(result.receipts),
          );
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
            AppToaster.show(voucherReceiptUploadErrorMessage(l10n, result.lastReceiptError), kind: ToastKind.warning);
            setState(() => _saving = false);
          }
          return;
        }
        final successMessage = draft.editingTransactionId != null
            ? l10n.toastVoucherUpdated
            : l10n.toastVoucherCreated;
        AppToaster.show(successMessage, kind: ToastKind.success);
        if (mounted) _closeVoucherRoute();
        return;
    } on AuthApiException catch (e) {
      if (!mounted) return;
      if (await handleVouchersApiAuthError(context: context, ref: ref, error: e)) return;
      if (!mounted) return;
      if (await handleSubscriptionApiError(context: context, ref: ref, error: e)) return;
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    } catch (e) {
      if (mounted) AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final draft = ref.read(voucherDraftProvider);
    final initial = draft.date ?? DateTime.now();
    final picked = await showVoucherDateSheet(
      context,
      initial: initial,
      firstDate: VoucherTransactionDateBounds.first,
      lastDate: VoucherTransactionDateBounds.last,
      presentation: _nestedPresentation,
      fullscreenDialog: false,
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
    const remote = true;
    setState(() {
      _receiptRows.addAll(paths.map((path) => VoucherSheetReceipt(localPath: path, needsUpload: remote)));
    });
  }

  Future<void> _attachFromCamera() async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await Navigator.of(context).push<VoucherCameraPickResult>(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.transparent,
          pageBuilder: (context, animation, secondaryAnimation) => VoucherCameraPickRoute(picker: _receiptPicker),
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

  Future<void> _openAttachChooser() async {
    final choice = await showVoucherReceiptSourceSheet(context);
    if (!mounted || choice == null) return;
    switch (choice) {
      case VoucherReceiptSource.camera:
        await _attachFromCamera();
      case VoucherReceiptSource.gallery:
        await _attachFromGallery();
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
    const remote = true;
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

    final footerBottom =
        AppSize.spaceMD + MediaQuery.viewPaddingOf(context).bottom;
    final fullScreen = widget.presentation == VoucherSheetPresentation.fullScreen;
    final showLinkAmount =
        isSpend &&
        draft.providerLinkedToClient != true &&
        ((draft.expenseType == 'labor' && draft.craftsmanId != null) ||
            (draft.expenseType == 'materials' && draft.supplierId != null));

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!fullScreen)
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
                      onPressed: _closeVoucherRoute,
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
                              clearProviderLink: true,
                            );
                            setState(() {
                              _craftsmanPickerError = null;
                              _itemPickerError = null;
                              _linkAmountCtrl.clear();
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
                        if (showLinkAmount)
                          CustomTextField(
                            controller: _linkAmountCtrl,
                            label: l10n.voucherLinkAgreementAmountOptional,
                            placeholder: l10n.amountHint,
                            type: AppInputType.currency,
                            ltrValue: true,
                            suffix: Text(MoneyFormat.currencyLabel),
                            fieldHeight: AppSize.fieldHeightComfortable,
                            textInputAction: TextInputAction.next,
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
                          trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => _removeReceiptAt(i)),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                appBar: const CustomAppBar(),
                                body: Center(child: Image.file(File(_receiptRows[i].localPath))),
                              ),
                            ),
                          ),
                        ),
                      AppPressable(
                        onPressed: _openAttachChooser,
                        child: DashedBorderFrame(
                          color: context.colors.outline,
                          radius: AppSize.radius,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSize.spaceLG,
                            horizontal: AppSize.spaceMD,
                          ),
                          child: Column(
                            spacing: AppSize.spaceSM,
                            children: [
                              Icon(Icons.cloud_upload_outlined, color: context.colors.primary, size: 28),
                              Text(
                                l10n.voucherAttachUploadPrompt,
                                style: context.text.caption.copyWith(color: context.colors.onSurfaceMuted),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
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
    );

    if (fullScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Expanded(child: body)],
      );
    }

    return Material(color: context.colors.surface, child: body);
  }
}
