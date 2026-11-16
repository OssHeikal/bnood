import '../api/device_tokens_api.dart';
import '../api/notification_settings_api.dart';
import 'notification_settings_record.dart';

class PushRepository {
  PushRepository(this._settingsApi, this._deviceTokensApi);

  final NotificationSettingsApi _settingsApi;
  final DeviceTokensApi _deviceTokensApi;

  Future<NotificationSettingsRecord> fetchSettings() => _settingsApi.getSettings();

  Future<NotificationSettingsRecord> updateSettings({
    bool? lowBalanceEnabled,
    int? lowBalanceAmountMinor,
  }) =>
      _settingsApi.patchSettings(
        lowBalanceEnabled: lowBalanceEnabled,
        lowBalanceAmountMinor: lowBalanceAmountMinor,
      );

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
    required String locale,
  }) =>
      _deviceTokensApi.registerToken(token: token, platform: platform, locale: locale);

  Future<void> deleteDeviceToken(String token) => _deviceTokensApi.deleteToken(token: token);
}