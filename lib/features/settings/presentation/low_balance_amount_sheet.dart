import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error_user_message.dart';
import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/money/money_format.dart';
import '../../../core/money/remote_money_format.dart';
import '../../../core/widgets/app_modal_sheet.dart';
import '../../../core/widgets/app_toaster.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/text_field/app_input_formatters.dart';
import '../../../core/widgets/sheet_footer_refresh.dart';
import '../../../core/widgets/sheet_form_header.dart';
import '../../home/presentation/home_foundation_scope.dart';
import '../data/notification_settings_provider.dart';

/// Edits the fixed low-balance alert threshold (minor units).
Future<void> showLowBalanceAmountSheet({required BuildContext context, required int initialAmountMinor}) {
  final formKey = GlobalKey<_LowBalanceAmountSheetState>();
  final footerRefresh = SheetFooterRefresh();
  final l10n = AppLocalizations.of(context);
  return AppModalSheet.show<void>(
    context: context,
    scrollable: false,
    header: SheetFormHeader(title: l10n.notificationSettingsLowBalanceAmountLabel),
    body: HomeFoundationScope(
      child: LowBalanceAmountSheet(key: formKey, initialAmountMinor: initialAmountMinor, footerRefresh: footerRefresh),
    ),
    footer: ListenableBuilder(
      listenable: footerRefresh,
      builder: (context, _) {
        final state = formKey.currentState;
        if (state == null) return const SizedBox.shrink();
        return AppButton.primary(
          text: l10n.save,
          isLoading: state._saving,
          onPressed: state._saving || !state._dirty ? null : state._save,
        );
      },
    ),
  );
}

class LowBalanceAmountSheet extends ConsumerStatefulWidget {
  const LowBalanceAmountSheet({super.key, required this.initialAmountMinor, required this.footerRefresh});

  final int initialAmountMinor;
  final SheetFooterRefresh footerRefresh;

  @override
  ConsumerState<LowBalanceAmountSheet> createState() => _LowBalanceAmountSheetState();
}

class _LowBalanceAmountSheetState extends ConsumerState<LowBalanceAmountSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _amountCtrl = TextEditingController(
    text: ThousandsGroupingFormatter.formatDisplay(
      RemoteMoneyFormat.majorInputTextFromMinor(widget.initialAmountMinor),
      allowDecimal: false,
    ),
  )..addListener(widget.footerRefresh.bump);
  var _attemptedSubmit = false;
  var _saving = false;

  bool get _dirty => RemoteMoneyFormat.parseMajorInput(_amountCtrl.text) != widget.initialAmountMinor;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final minor = RemoteMoneyFormat.parseMajorInput(value ?? '');
    if (minor == null || minor <= 0) return AppLocalizations.of(context).notificationSettingsAmountInvalid;
    return null;
  }

  Future<void> _save() async {
    setState(() => _attemptedSubmit = true);
    widget.footerRefresh.bump();
    if (_formKey.currentState?.validate() != true || _saving) return;
    final minor = RemoteMoneyFormat.parseMajorInput(_amountCtrl.text)!;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    widget.footerRefresh.bump();
    try {
      await ref.read(notificationSettingsProvider.notifier).saveLowBalanceAmount(minor);
      AppToaster.show(l10n.notificationSettingsSaved, kind: ToastKind.success);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        widget.footerRefresh.bump();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Form(
            key: _formKey,
            autovalidateMode: _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: CustomTextField(
              controller: _amountCtrl,
              label: l10n.notificationSettingsLowBalanceToggle,
              type: AppInputType.integer,
              ltrValue: true,
              groupThousands: true,
              autofocus: true,
              fieldHeight: AppSize.fieldHeightComfortable,
              suffix: Text(MoneyFormat.currencyLabel),
              textInputAction: TextInputAction.done,
              validator: _validate,
            ),
          ),
          AppSize.spaceSM.gap,
          Text(
            l10n.notificationSettingsLowBalanceAmountHint,
            style: context.text.caption.copyWith(color: context.colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}
