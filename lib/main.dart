import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bnood_app.dart';
import 'core/prefs/app_settings_store.dart';
import 'core/providers/settings_provider.dart';
import 'core/push/push_background.dart';
import 'core/push/push_platform.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (pushMessagingSupported) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  final bootstrap = await AppSettingsStore.load();
  runApp(
    ProviderScope(
      overrides: [appSettingsBootstrapProvider.overrideWithValue(bootstrap)],
      child: const BnoodApp(),
    ),
  );
}