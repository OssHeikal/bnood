# Static assets

## Icons (SVG)

- **Files:** `assets/icons/*.svg` (73 glyphs, semantic English snake_case names).
- **Rename audit:** `docs/assets/icon_name_mapping.csv` (original → new names; not used at runtime).
- **Codegen:** FlutterGen → `lib/core/resources/gen/assets.gen.dart`

### Usage (required for new UI)

Do **not** hardcode `assets/icons/...` strings in features or widgets.

```dart
import 'package:bnood/core/resources/gen/assets.gen.dart';

Assets.icons.homeOutline.svg(width: 24, height: 24);
// or via AppIcon when the SmartRx-style adapter lands:
// AppIcon(Assets.icons.homeOutline);
```

### Regenerate after adding/changing assets

From project root (FVM 3.41.1):

```bash
fvm flutter pub get
fvm dart run flutter_gen:flutter_gen_command
```

Drift codegen is separate (only when schema changes):

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

Do not hand-edit `assets.gen.dart`.

Shell navigation icon choices: [nav-icon-mapping.md](nav-icon-mapping.md).
