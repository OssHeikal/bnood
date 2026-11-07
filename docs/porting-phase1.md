# UI foundation phase 1 — provenance

**Source revision (verified):** SmartRx patient `2958558f3eb33e29f31c30e329f80a2ada1a8ee0` (`aldefrawy/SmartRx_Patient_Mobile`, branch `dev` at read time).

**Method:** Read-only copy from local checkout at that SHA; files adapted under `lib/core/` with Bnood package imports. **No** edits to `smartrx-patient`.

## Boundaries

| Kept from SmartRx | Bnood-specific |
|-------------------|----------------|
| Widget interaction patterns (press scale, button phases, input frame) | Cairo + index colors (`AppColors` extension) |
| `AppSheet.actions` / `.choices` only | `FoundationIcon` (Material) until owner SVGs |
| Sheet drag handle, grouped divider | `FieldPlaceholders` instead of `LocaleKeys` |
| Toaster layout / `AppToast` | `FoundationToaster` + `rootNavigatorKey` |
| AppDecision flows | `BnoodFailure` instead of `Failure` |
| | Legacy `lib/core/widgets/app_button.dart` (enum) for production features |
| | Legacy `CustomBottomSheet` + nested navigator untouched |
| | Production `main.dart` / `BnoodApp` theme unchanged |
| | `core/pdf/pdf_fonts.dart` unchanged |

## Preview (debug only)

```bash
cd "/Users/macbook/Developer/flutter projects/bnood"
fvm flutter run -t lib/preview/ui_foundation_main.dart
```

Does not alter production launch or simulator app already running.

## Not in phase 1

- Home / shell nav migration (UI-06)
- Voucher nested sheet migration to `AppSheet`
- Owner SVG icon set
- PDF artifact test path fix
