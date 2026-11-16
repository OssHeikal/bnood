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
  StreamSubscription<String>? _tokenRefreshSub;
  String? _registeredToken;

  Future<void> bindAuthenticated(AuthState auth) async {
    if (!pushMessagingSupported || !auth.isAuthenticated) return;
    await _requestOsPermissionOnce();
    await _syncToken();
    await _listen();
    await _handleInitialMessage();
  }

  Future<void> unbind() async {
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    await _tokenRefreshSub?.cancel();
    _foregroundSub = null;
    _openedSub = null;
    _tokenRefreshSub = null;
    await _unregisterToken();
  }

  Future<void> _requestOsPermissionOnce() async {
    if (await _permissionStore.wasOsPermissionPrompted()) return;
    await _permissionStore.markOsPermissionPrompted();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await FirebaseMessaging.instance.requestPermission();
      return;
    }
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _syncToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      final locale = _ref.read(localeProvider).languageCode;
      await _repository.registerDeviceToken(
        token: token,
        platform: pushDevicePlatformValue(),
        locale: locale,
      );
      _registeredToken = token;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('FCM register failed: $e\n$st');
      }
    }
  }

  Future<void> _unregisterToken() async {
    final token = _registeredToken;
    _registeredToken = null;
    if (token == null || token.isEmpty) return;
    try {
      await _repository.deleteDeviceToken(token);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('FCM delete token failed: $e\n$st');
      }
    }
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }

  Future<void> _listen() async {
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    await _tokenRefreshSub?.cancel();

    _foregroundSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedMessage);
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final previous = _registeredToken;
      _registeredToken = token;
      if (previous != null && previous != token) {
        try {
          await _repository.deleteDeviceToken(previous);
        } catch (_) {}
      }
      final locale = _ref.read(localeProvider).languageCode;
      try {
        await _repository.registerDeviceToken(
          token: token,
          platform: pushDevicePlatformValue(),
          locale: locale,
        );
      } catch (e, st) {
        if (kDebugMode) debugPrint('FCM token refresh register failed: $e\n$st');
      }
    });
  }

  Future<void> _handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      _navigateForMessage(message);
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
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
      action: ToastAction(
        label: openLabel,
        onPressed: () => _navigateForMessage(message),
      ),
    );
  }

  void _onOpenedMessage(RemoteMessage message) => _navigateForMessage(message);

  void _navigateForMessage(RemoteMessage message) {
    final data = message.data.map((k, v) => MapEntry(k, v.toString()));
    final location = resolvePushNavigationLocation(data);
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