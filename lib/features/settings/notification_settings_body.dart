import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_error_user_message.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/money/remote_money_format.dart';
import '../../core/push/notification_settings_record.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/grouped_list_divider.dart';
import 'notification_settings_provider.dart';
import 'settings_list_widgets.dart';

class NotificationSettingsBody extends ConsumerStatefulWidget {
  const NotificationSettingsBody({super.key, required this.settings});

  final NotificationSettingsRecord settings;

  @override
  ConsumerState<NotificationSettingsBody> createState() => _NotificationSettingsBodyState();
}

class _NotificationSettingsBodyState extends ConsumerState<NotificationSettingsBody> {
  late final TextEditingController _amountCtrl;
  late bool _enabled;
  bool _savingAmount = false;

  @override
  void initState() {
    super.initState();
    _enabled = widget.settings.lowBalanceEnabled;
    _amountCtrl = TextEditingController(
      text: RemoteMoneyFormat.majorInputTextFromMinor(widget.settings.lowBalanceAmountMinor),
    );
  }

  @override
  void didUpdateWidget(covariant NotificationSettingsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.lowBalanceEnabled != widget.settings.lowBalanceEnabled) {
      _enabled = widget.settings.lowBalanceEnabled;
    }
    if (oldWidget.settings.lowBalanceAmountMinor != widget.settings.lowBalanceAmountMinor && !_savingAmount) {
      _amountCtrl.text = RemoteMoneyFormat.majorInputTextFromMinor(widget.settings.lowBalanceAmountMinor);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _onToggle(bool value) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _enabled = value);
    try {
      await ref.read(notificationSettingsProvider.notifier).setLowBalanceEnabled(value);
    } catch (e) {
      if (!mounted) return;
      setState(() => _enabled = !value);
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    }
  }

  Future<void> _saveAmount() async {
    if (!_enabled) return;
    final l10n = AppLocalizations.of(context);
    final minor = RemoteMoneyFormat.parseMajorInput(_amountCtrl.text);
    if (minor == null || minor <= 0) {
      AppToaster.show(l10n.notificationSettingsAmountInvalid, kind: ToastKind.warning);
      return;
    }
    setState(() => _savingAmount = true);
    try {
      await ref.read(notificationSettingsProvider.notifier).saveLowBalanceAmount(minor);
      if (mounted) {
        AppToaster.show(l10n.notificationSettingsSaved, kind: ToastKind.success);
      }
    } catch (e) {
      if (mounted) {
        AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
      }
    } finally {
      if (mounted) setState(() => _savingAmount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(AppSize.spaceLG, 0, AppSize.spaceLG, AppSize.spaceSM),
          child: Text(
            l10n.notificationSettingsDescription,
            style: context.text.body.copyWith(color: colors.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ),
        SettingsListSection(
          title: l10n.notificationSettingsAlertsSection,
          dividerKind: GroupedListDividerKind.insetStart,
          children: [
            _SettingsToggleRow(
              label: l10n.notificationSettingsLowBalanceToggle,
              value: _enabled,
              onChanged: _savingAmount ? null : _onToggle,
            ),
          ],
        ),
        if (_enabled) ...[
          AppSize.spaceLG.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: CustomTextField(
              controller: _amountCtrl,
              label: l10n.notificationSettingsLowBalanceAmountLabel,
              type: AppInputType.currency,
              textInputAction: TextInputAction.done,
            ),
          ),
          AppSize.spaceSM.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Text(
              l10n.notificationSettingsLowBalanceAmountHint,
              style: context.text.caption.copyWith(color: colors.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ),
          AppSize.spaceMD.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton(
                onPressed: _savingAmount ? null : _saveAmount,
                child: Text(l10n.save),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Semantics(
      toggled: value,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSize.hitMin),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSize.spaceMD,
            AppSize.spaceSM + 2,
            AppSize.spaceMD,
            AppSize.spaceSM + 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: text.body,
                  textAlign: TextAlign.start,
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged == null ? null : (v) => onChanged!(v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}