import 'package:flutter/material.dart';

import 'ui_foundation_preview_app.dart';

/// Debug entrypoint — does not change production [main.dart].
///
/// Launch (owner supervises; do not auto-run in agents):
/// ```bash
/// cd "/Users/macbook/Developer/flutter projects/bnood"
/// fvm flutter run -t lib/preview/ui_foundation_main.dart
/// ```
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UiFoundationPreviewApp());
}
