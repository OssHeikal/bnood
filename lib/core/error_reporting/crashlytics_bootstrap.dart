import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'crashlytics_config.dart';

Future<void> bootstrapCrashlytics() async {
  if (!CrashlyticsConfig.isSupported) return;
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    kReleaseMode,
  );
}
