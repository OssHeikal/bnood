import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bnood_app_root.dart';
import 'core/prefs/app_settings_store.dart';
import 'core/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await AppSettingsStore.load();
  runApp(
    ProviderScope(
      overrides: [
        appSettingsBootstrapProvider.overrideWithValue(bootstrap),
      ],
      child: const BnoodAppRoot(),
    ),
  );
}
