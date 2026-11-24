import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/app_splash_session.dart';
import '../../../app/app_startup_splash.dart';
import '../../../app/router.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/subscription/presentation/actions/paywall_launcher.dart';
import '../../services/config/navigation/root_navigator_key.dart';
import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/features/subscription/data/subscription_riverpod.dart';
import 'local_notifications.dart';
import 'push_cold_start_navigation.dart';
import 'push_payload_routing.dart';
import 'push_log.dart';
import 'push_permission_store.dart';
import 'push_platform.dart';
import 'push_providers.dart';
import 'push_repository.dart';

class PushCoordinator {
  PushCoordinator({
    required Ref ref,
    required PushRepository repository,
    required PushPermissionStore permissionStore,
  }) : _ref = ref,
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

  final PushColdStartNavigation _coldStart = PushColdStartNavigation();
  Map<String, String>? _deferredUntilReady;
  Future<void>? _flushInFlight;

  Future<void> bindAuthenticated(AuthState auth) async {
    if (!pushMessagingSupported || !auth.isAuthenticated) return;
    PushLog.info('bind: user=${auth.user?.id}');
    await _requestOsPermissionOnce();
    await _listen();
    await _stageColdStartTap();
    await _register();
    _scheduleFlushPending();
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
    _deferredUntilReady = null;
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
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        !await _waitForApnsToken()) {
      PushLog.info(
        'register skipped: no APNs token (simulator or push not configured)',
      );
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
    for (var attempt = 0; attempt < 15; attempt++) {
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
        PushLog.info(
          'removed previous id ${PushLog.id(previous)} from backend',
        );
      } catch (e, st) {
        PushLog.error('remove previous id failed', e, st);
      }
    }
    final locale = _ref.read(localeProvider).languageCode;
    try {
      await _repository.registerDeviceToken(
        token: fid,
        platform: pushDevicePlatformValue(),
        locale: locale,
      );
      PushLog.info(
        'uploaded id to backend (platform=${pushDevicePlatformValue()}, locale=$locale)',
      );
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

    await LocalNotifications.instance.init(onTap: _navigateForData);
    _foregroundSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedMessage);
    _registeredSub = FirebaseMessaging.instance.onRegistered.listen(
      _onRegistered,
    );
    PushLog.info('listening: onMessage, onMessageOpenedApp, onRegistered');
  }

  Future<void> _stageColdStartTap() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    final fcm = message?.data.map((k, v) => MapEntry(k, v.toString()));
    PushLog.info(
      message == null
          ? 'initial message: none'
          : 'initial message: ${PushLog.message(message)}',
    );
    final local = await LocalNotifications.instance.readLaunchTapData();
    if (local != null) {
      PushLog.info('local launch tap: $local');
    }
    _coldStart.stage(fcm: fcm, local: local);
  }

  void _scheduleFlushPending() {
    _flushInFlight ??= _flushPendingWhenReady().whenComplete(
      () => _flushInFlight = null,
    );
  }

  Future<void> _flushPendingWhenReady() async {
    for (var attempt = 0; attempt < 80; attempt++) {
      if (!_isNavigationReady()) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        continue;
      }
      final coldStart = _coldStart.takePending();
      final deferred = _deferredUntilReady;
      _deferredUntilReady = null;
      final data = coldStart ?? deferred;
      if (data == null) return;
      await _performNavigation(data);
      return;
    }
    PushLog.info('pending push navigation: timed out waiting for navigator');
  }

  bool _isNavigationReady() {
    if (!AppSplashSession.completed) return false;
    final auth = _ref.read(authControllerProvider);
    if (!auth.isAuthenticated) return false;
    final context = rootNavigatorKey.currentContext;
    if (context == null) return false;
    final router = _ref.read(goRouterProvider);
    final loc = router.routerDelegate.currentConfiguration.uri.path;
    if (loc == AppStartupSplashPage.path || loc == AuthPaths.bootstrap) {
      return false;
    }
    if (isAuthFlowLocation(loc) &&
        loc != AuthPaths.changePassword &&
        loc != AuthPaths.completeProfile) {
      return false;
    }
    return true;
  }

  void _onForegroundMessage(RemoteMessage message) {
    PushLog.info('foreground message: ${PushLog.message(message)}');
    LocalNotifications.instance.showRemote(message);
  }

  void _onOpenedMessage(RemoteMessage message) {
    PushLog.info('opened from notification: ${PushLog.message(message)}');
    final data = message.data.map((k, v) => MapEntry(k, v.toString()));
    if (_coldStart.shouldIgnoreOpenedApp(data)) {
      PushLog.info(
        'opened from notification: skipped (cold start already handled)',
      );
      return;
    }
    _navigateForData(data);
  }

  void _navigateForData(Map<String, String> data) {
    if (!_isNavigationReady()) {
      _deferredUntilReady = Map<String, String>.from(data);
      PushLog.info('navigate deferred until app ready');
      _scheduleFlushPending();
      return;
    }
    unawaited(_performNavigation(data));
  }

  Future<void> _performNavigation(Map<String, String> data) async {
    final location = resolvePushNavigationLocation(data);
    PushLog.info('navigate: type=${data['type']} -> $location');
    if (isPushSubscriptionLocation(location)) {
      await _presentSubscriptionPaywall();
      return;
    }
    _ref.read(goRouterProvider).go(location);
  }

  Future<void> _presentSubscriptionPaywall() async {
    final router = _ref.read(goRouterProvider);
    final shellHome = authenticatedHomeForPath();
    if (router.routerDelegate.currentConfiguration.uri.path != shellHome) {
      router.go(shellHome);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    for (var attempt = 0; attempt < 40; attempt++) {
      final snap = _ref.read(subscriptionProvider).valueOrNull;
      if (snap != null && snap.showSurfaces && snap.paywall != null) {
        if (!context.mounted) return;
        await PaywallLauncher.present(context);
        return;
      }
      if (_ref.read(subscriptionProvider).hasError) {
        PushLog.info('subscription paywall: load failed, skipping present');
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    PushLog.info('subscription paywall: subscription data not ready');
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
    final prevId = previous?.isAuthenticated == true
        ? previous?.user?.id
        : null;
    final nextId = next.isAuthenticated ? next.user?.id : null;
    if (prevId == nextId && previous?.isAuthenticated == next.isAuthenticated) {
      return;
    }
    Future.microtask(() => sync(next));
  });
});
