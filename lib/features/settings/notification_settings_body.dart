import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_error_user_message.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/money/remote_money_format.dart';
import '../../core/push/notification_settings_record.dart';
import '../../core/widgets/app_chevron.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/grouped_list_divider.dart';
import 'low_balance_amount_sheet.dart';
import 'notification_settings_provider.dart';
import 'settings_list_widgets.dart';

class NotificationSettingsBody extends ConsumerStatefulWidget {
  const NotificationSettingsBody({super.key, required this.settings});

  final NotificationSettingsRecord settings;

  @override
  ConsumerState<NotificationSettingsBody> createState() => _NotificationSettingsBodyState();
}

class _NotificationSettingsBodyState extends ConsumerState<NotificationSettingsBody> {
  late bool _pushEnabled = widget.settings.pushEnabled;
  late bool _enabled = widget.settings.lowBalanceEnabled;
  bool _toggling = false;

  @override
  void didUpdateWidget(covariant NotificationSettingsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.pushEnabled != widget.settings.pushEnabled) {
      _pushEnabled = widget.settings.pushEnabled;
    }
    if (oldWidget.settings.lowBalanceEnabled != widget.settings.lowBalanceEnabled) {
      _enabled = widget.settings.lowBalanceEnabled;
    }
  }

  Future<void> _onPushToggle(bool value) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _pushEnabled = value;
      _toggling = true;
    });
    try {
      await ref.read(notificationSettingsProvider.notifier).setPushEnabled(value);
    } catch (e) {
      if (!mounted) return;
      setState(() => _pushEnabled = !value);
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  Future<void> _onToggle(bool value) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _enabled = value;
      _toggling = true;
    });
    try {
      await ref.read(notificationSettingsProvider.notifier).setLowBalanceEnabled(value);
    } catch (e) {
      if (!mounted) return;
      setState(() => _enabled = !value);
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final amountMinor = widget.settings.lowBalanceAmountMinor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(AppSize.spaceLG, 0, AppSize.spaceLG, AppSize.spaceMD),
          child: Text(
            l10n.notificationSettingsDescription,
            style: context.text.body.copyWith(color: colors.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ),
        SettingsListSection(
          title: null,
          dividerKind: GroupedListDividerKind.insetBoth,
          children: [
            _SettingsToggleRow(
              label: l10n.notificationSettingsMasterToggle,
              caption: l10n.notificationSettingsMasterCaption,
              value: _pushEnabled,
              onChanged: _toggling ? null : _onPushToggle,
            ),
          ],
        ),
        AppSize.spaceLG.gap,
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _pushEnabled ? 1 : 0.45,
          child: IgnorePointer(
            ignoring: !_pushEnabled,
            child: SettingsListSection(
              title: null,
              dividerKind: GroupedListDividerKind.insetBoth,
              children: [
                _SettingsToggleRow(
                  label: l10n.notificationSettingsLowBalanceToggle,
                  caption: l10n.notificationSettingsLowBalanceAmountHint,
                  value: _enabled,
                  onChanged: _toggling ? null : _onToggle,
                ),
                if (_enabled)
                  _SettingsValueRow(
                    label: l10n.notificationSettingsLowBalanceAmountLabel,
                    value: RemoteMoneyFormat.formatMinor(amountMinor),
                    onTap: () => showLowBalanceAmountSheet(context: context, initialAmountMinor: amountMinor),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsValueRow extends StatelessWidget {
  const _SettingsValueRow({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Semantics(
      button: true,
      label: '$label $value',
      child: AppPressable(
        onPressed: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.hitMin),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSize.spaceMD,
              AppSize.spaceSM + 2,
              AppSize.spaceSM,
              AppSize.spaceSM + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(label, style: text.body, textAlign: TextAlign.start),
                ),
                AppSize.spaceSM.gap,
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(value, style: text.bodyEmphasis.copyWith(color: context.colors.primary)),
                ),
                const AppChevron.forward(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({required this.label, this.caption, required this.value, required this.onChanged});

  final String label;
  final String? caption;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: text.bodyEmphasis, textAlign: TextAlign.start),
                    if (caption != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        caption!,
                        style: text.caption.copyWith(color: context.colors.onSurfaceMuted),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ],
                ),
              ),
              AppSize.spaceSM.gap,
              Switch.adaptive(value: value, onChanged: onChanged == null ? null : (v) => onChanged!(v)),
            ],
          ),
        ),
      ),
    );
  }
}
