import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'push_log.dart';

/// Shows FCM messages that arrive while the app is open as system notifications.
class LocalNotifications {
  LocalNotifications._();

  static final LocalNotifications instance = LocalNotifications._();

  static const _channel = AndroidNotificationChannel('bnood_default', 'Bnood', importance: Importance.high);

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  void Function(Map<String, String> data)? _onTap;

  Future<void> init({required void Function(Map<String, String> data) onTap}) async {
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
    await _plugin.initialize(settings: settings, onDidReceiveNotificationResponse: _handleResponse);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    _initialized = true;
    PushLog.info('local notifications: ready');
  }

  Future<void> showRemote(RemoteMessage message) async {
    final n = message.notification;
    final title = n?.title;
    final body = n?.body;
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) return;

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
      id: (message.messageId ?? DateTime.now().toIso8601String()).hashCode & 0x7fffffff,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
    PushLog.info('local notification shown');
  }

  void _handleResponse(NotificationResponse response) {
    final raw = response.payload;
    var data = <String, String>{};
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        data = decoded.map((k, v) => MapEntry(k, v.toString()));
      } catch (e, st) {
        PushLog.error('local notification payload invalid', e, st);
      }
    }
    PushLog.info('local notification tapped: $data');
    _onTap?.call(data);
  }
}
