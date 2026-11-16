import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/push/notification_settings_record.dart';
import '../../core/push/push_providers.dart';

final notificationSettingsProvider = AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettingsRecord>(
  NotificationSettingsNotifier.new,
);

class NotificationSettingsNotifier extends AsyncNotifier<NotificationSettingsRecord> {
  @override
  Future<NotificationSettingsRecord> build() async {
    return ref.read(pushRepositoryProvider).fetchSettings();
  }

  Future<void> setPushEnabled(bool enabled) async {
    final previous = state.valueOrNull;
    if (previous == null) return;
    state = AsyncData(previous.copyWith(pushEnabled: enabled));
    try {
      final updated = await ref.read(pushRepositoryProvider).updateSettings(pushEnabled: enabled);
      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> setLowBalanceEnabled(bool enabled) async {
    final previous = state.valueOrNull;
    if (previous == null) return;
    state = AsyncData(previous.copyWith(lowBalanceEnabled: enabled));
    try {
      final updated = await ref.read(pushRepositoryProvider).updateSettings(lowBalanceEnabled: enabled);
      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> saveLowBalanceAmount(int amountMinor) async {
    final previous = state.valueOrNull;
    if (previous == null) return;
    state = AsyncData(previous.copyWith(lowBalanceAmountMinor: amountMinor));
    try {
      final updated = await ref.read(pushRepositoryProvider).updateSettings(lowBalanceAmountMinor: amountMinor);
      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(e, st);
    }
  }
}

extension _NotificationSettingsCopy on NotificationSettingsRecord {
  NotificationSettingsRecord copyWith({bool? pushEnabled, bool? lowBalanceEnabled, int? lowBalanceAmountMinor}) {
    return NotificationSettingsRecord(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      lowBalanceEnabled: lowBalanceEnabled ?? this.lowBalanceEnabled,
      lowBalanceAmountMinor: lowBalanceAmountMinor ?? this.lowBalanceAmountMinor,
    );
  }
}
