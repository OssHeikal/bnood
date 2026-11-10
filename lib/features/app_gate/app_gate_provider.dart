import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/api/app_config_api.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/app_gate/app_config_record.dart';
import '../../core/providers/settings_provider.dart';
import 'app_gate_cold_start.dart';
import 'app_gate_paths.dart';

final appConfigApiProvider = Provider<AppConfigApi>((ref) {
  final api = AppConfigApi();
  ref.onDispose(api.close);
  return api;
});

class AppGateMemory {
  AppGateMemory({this.lastSuccess});

  AppConfigData? lastSuccess;
}

final appGateMemoryProvider = Provider<AppGateMemory>((ref) => AppGateMemory());

/// Latest config fetch for this process. Fail-open sets [AppConfigData.failOpen].
final appGateProvider =
    AsyncNotifierProvider<AppGateNotifier, AppConfigData>(AppGateNotifier.new);

class AppGateNotifier extends AsyncNotifier<AppConfigData> {
  @override
  Future<AppConfigData> build() => Future.value(AppConfigData.failOpen());

  Future<AppConfigData> fetchConfig({bool failOpen = true}) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final platform = _platformKey();
      final locale = ref.read(localeProvider).languageCode;
      final data = await ref.read(appConfigApiProvider).fetchConfig(
            platform: platform,
            version: packageInfo.version,
            locale: locale,
          );
      ref.read(appGateMemoryProvider).lastSuccess = data;
      state = AsyncData(data);
      return data;
    } catch (e) {
      if (!failOpen) rethrow;
      final open = AppConfigData.failOpen();
      state = AsyncData(open);
      return open;
    }
  }

  static String _platformKey() {
    if (kIsWeb) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  static bool shouldFailOpen(Object error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      if (code != null && code >= 500) return true;
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        return true;
      }
    }
    if (error is AuthApiException) {
      final code = error.statusCode;
      if (code >= 500) return true;
    }
    return false;
  }
}

String splashRouteForGate(AppConfigData config, String postAuthDestination) {
  if (config.status == AppGateStatus.optionalUpdate) {
    if (AppGateColdStart.optionalDismissed) {
      return postAuthDestination;
    }
    return AppGatePaths.optionalUpdate;
  }
  return switch (config.status) {
    AppGateStatus.maintenance => AppGatePaths.maintenance,
    AppGateStatus.forceUpdate => AppGatePaths.forceUpdate,
    AppGateStatus.ok => postAuthDestination,
    AppGateStatus.optionalUpdate => AppGatePaths.optionalUpdate,
  };
}
