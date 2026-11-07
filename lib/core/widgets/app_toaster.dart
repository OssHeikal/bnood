import 'package:flutter/material.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum ToastKind { success, failure, warning, info }

abstract final class AppToaster {
  static void show(String message, {ToastKind kind = ToastKind.info}) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    final color = switch (kind) {
      ToastKind.success => const Color(0xFF145C3A),
      ToastKind.failure => const Color(0xFF8B2E2E),
      ToastKind.warning => const Color(0xFF8B6914),
      ToastKind.info => const Color(0xFF1A2422),
    };
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
