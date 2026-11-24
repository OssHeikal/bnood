import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'push_log.dart';

/// Shows FCM messages that arrive while the app is open as system notifications.
class LocalNotifications {
  LocalNotifications._();

  static final LocalNotifications instance = LocalNotifications._();

  static const _channel = AndroidNotificationChannel(
    'bnood_default',
    'Bnood',
    importance: Importance.high,
  );

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _launchDetailsRead = false;
  void Function(Map<String, String> data)? _onTap;

  Future<void> init({
    required void Function(Map<String, String> data) onTap,
  }) async {
    _onTap = onTap;
    if (_initialized) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _handleResponse,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
    _initialized = true;
    PushLog.info('local notifications: ready');
  }

  Future<void> showRemote(RemoteMessage message) async {
    final n = message.notification;
    final title = n?.title;
    final body = n?.body;
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      id:
          (message.messageId ?? DateTime.now().toIso8601String()).hashCode &
          0x7fffffff,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
    PushLog.info('local notification shown');
  }

  /// Cold-start tap from a foreground-shown local notification (read once per process).
  Future<Map<String, String>?> readLaunchTapData() async {
    if (_launchDetailsRead) return null;
    _launchDetailsRead = true;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp != true) return null;
      return _parsePayload(details!.notificationResponse?.payload);
    } catch (e, st) {
      PushLog.error('local notification launch details failed', e, st);
      return null;
    }
  }

  Map<String, String>? _parsePayload(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (e, st) {
      PushLog.error('local notification payload invalid', e, st);
      return null;
    }
  }

  void _handleResponse(NotificationResponse response) {
    final data = _parsePayload(response.payload) ?? <String, String>{};
    PushLog.info('local notification tapped: $data');
    _onTap?.call(data);
  }
}
