import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/router.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/auth_state.dart';
import '../../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_toaster.dart';
import 'push_payload_routing.dart';
import 'push_log.dart';
import 'push_permission_store.dart';
import 'push_platform.dart';
import 'push_providers.dart';
import 'push_repository.dart';

class PushCoordinator {
  PushCoordinator({required Ref ref, required PushRepository repository, required PushPermissionStore permissionStore})
    : _ref = ref,
      _repository = repository,
      _permissionStore = permissionStore;

  final Ref _ref;
  final PushRepository _repository;
  final PushPermissionStore _permissionStore;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<String>? _registeredSub;
  String? _registeredToken;
  bool _fcmRegistered = false;

  Future<void> bindAuthenticated(AuthState auth) async {
    if (!pushMessagingSupported || !auth.isAuthenticated) return;
    PushLog.info('bind: user=${auth.user?.id}');
    await _requestOsPermissionOnce();
    await _listen();
    await _register();
    await _handleInitialMessage();
  }

  Future<void> unbind() async {
    PushLog.info('unbind');
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    await _registeredSub?.cancel();
    _foregroundSub = null;
    _openedSub = null;
    _registeredSub = null;
    await _unregisterToken();
  }

  Future<void> _requestOsPermissionOnce() async {
    if (await _permissionStore.wasOsPermissionPrompted()) {
      PushLog.info('permission: already prompted, skipping');
      return;
    }
    await _permissionStore.markOsPermissionPrompted();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final settings = await FirebaseMessaging.instance.requestPermission();
      PushLog.info('permission (iOS): ${settings.authorizationStatus.name}');
      return;
    }
    final status = await Permission.notification.status;
    PushLog.info('permission (Android): current=${status.name}');
    if (status.isDenied) {
      final result = await Permission.notification.request();
      PushLog.info('permission (Android): requested -> ${result.name}');
    }
  }

  /// Registers this app instance with FCM. The Firebase Installation ID (FID)
  /// arrives on [FirebaseMessaging.onRegistered] and is uploaded there. The
  /// backend keeps sending to the HTTP v1 `token` field, which accepts FIDs.
  Future<void> _register() async {
    if (defaultTargetPlatform == TargetPlatform.iOS && !await _waitForApnsToken()) {
      PushLog.info('register skipped: no APNs token (simulator or push not configured)');
      return;
    }
    try {
      PushLog.info('register: requesting');
      await FirebaseMessaging.instance.register();
      _fcmRegistered = true;
      PushLog.info('register: requested, waiting for onRegistered');
    } catch (e, st) {
      PushLog.error('register failed', e, st);
    }
  }

  /// FCM on iOS needs the APNs token first; it can arrive a moment after launch.
  Future<bool> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns != null && apns.isNotEmpty) {
        PushLog.info('APNs token: ${PushLog.id(apns)}');
        return true;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  Future<void> _onRegistered(String fid) async {
    PushLog.info('onRegistered: fid=${PushLog.id(fid)}');
    if (fid.isEmpty) return;
    final previous = _registeredToken;
    _registeredToken = fid;
    if (previous != null && previous != fid) {
      try {
        await _repository.deleteDeviceToken(previous);
        PushLog.info('removed previous id ${PushLog.id(previous)} from backend');
      } catch (e, st) {
        PushLog.error('remove previous id failed', e, st);
      }
    }
    final locale = _ref.read(localeProvider).languageCode;
    try {
      await _repository.registerDeviceToken(token: fid, platform: pushDevicePlatformValue(), locale: locale);
      PushLog.info('uploaded id to backend (platform=${pushDevicePlatformValue()}, locale=$locale)');
    } catch (e, st) {
      PushLog.error('upload id to backend failed', e, st);
    }
  }

  Future<void> _unregisterToken() async {
    final token = _registeredToken;
    _registeredToken = null;
    if (token != null && token.isNotEmpty) {
      try {
        await _repository.deleteDeviceToken(token);
        PushLog.info('removed id ${PushLog.id(token)} from backend');
      } catch (e, st) {
        PushLog.error('remove id from backend failed', e, st);
      }
    }
    if (!_fcmRegistered) {
      PushLog.info('unregister: skipped, not registered');
      return;
    }
    _fcmRegistered = false;
    try {
      await FirebaseMessaging.instance.unregister();
      PushLog.info('unregister: done');
    } catch (e, st) {
      PushLog.error('unregister failed', e, st);
    }
  }

  Future<void> _listen() async {
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    await _registeredSub?.cancel();

    _foregroundSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedMessage);
    _registeredSub = FirebaseMessaging.instance.onRegistered.listen(_onRegistered);
    PushLog.info('listening: onMessage, onMessageOpenedApp, onRegistered');
  }

  Future<void> _handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    PushLog.info(message == null ? 'initial message: none' : 'initial message: ${PushLog.message(message)}');
    if (message != null) {
      _navigateForMessage(message);
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    PushLog.info('foreground message: ${PushLog.message(message)}');
    final notification = message.notification;
    final title = notification?.title;
    final body = notification?.body ?? '';
    if (body.isEmpty && (title == null || title.isEmpty)) return;

    final router = _ref.read(goRouterProvider);
    final ctx = router.routerDelegate.navigatorKey.currentContext;
    final openLabel = ctx != null ? AppLocalizations.of(ctx).pushNotificationOpenAction : 'Open';

    AppToaster.show(
      body.isEmpty ? (title ?? '') : body,
      title: body.isEmpty ? null : title,
      kind: ToastKind.info,
      action: ToastAction(label: openLabel, onPressed: () => _navigateForMessage(message)),
    );
  }

  void _onOpenedMessage(RemoteMessage message) {
    PushLog.info('opened from notification: ${PushLog.message(message)}');
    _navigateForMessage(message);
  }

  void _navigateForMessage(RemoteMessage message) {
    final data = message.data.map((k, v) => MapEntry(k, v.toString()));
    final location = resolvePushNavigationLocation(data);
    PushLog.info('navigate: type=${data['type']} -> $location');
    final router = _ref.read(goRouterProvider);
    router.go(location);
  }
}

final pushCoordinatorProvider = Provider<PushCoordinator>((ref) {
  final coordinator = PushCoordinator(
    ref: ref,
    repository: ref.watch(pushRepositoryProvider),
    permissionStore: ref.watch(pushPermissionStoreProvider),
  );
  ref.onDispose(coordinator.unbind);
  return coordinator;
});

/// Starts FCM when the user is authenticated; tears down on logout.
final pushLifecycleProvider = Provider<void>((ref) {
  if (!pushMessagingSupported) return;

  Future<void> sync(AuthState? auth) async {
    final coordinator = ref.read(pushCoordinatorProvider);
    if (auth != null && auth.isAuthenticated) {
      await coordinator.bindAuthenticated(auth);
    } else {
      await coordinator.unbind();
    }
  }

  final initial = ref.read(authControllerProvider);
  Future.microtask(() => sync(initial));

  ref.listen(authControllerProvider, (previous, next) {
    final prevId = previous?.isAuthenticated == true ? previous?.user?.id : null;
    final nextId = next.isAuthenticated ? next.user?.id : null;
    if (prevId == nextId && previous?.isAuthenticated == next.isAuthenticated) return;
    Future.microtask(() => sync(next));
  });
});
