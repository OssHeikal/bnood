# UI visual acceptance

Use before treating a UI milestone as done. Functional tests passing is **necessary**, not sufficient.

## Pre-checks

- [ ] Compared against owner **index.html** on ~390px logical width
- [ ] Light **and** dark theme smoke on primary surfaces
- [ ] Arabic RTL: home, client detail, voucher sheet (open → **cancel**, no fake saves)
- [ ] No DB seed/reset for screenshot convenience
- [ ] Typography uses role table in [design.md](design.md) — not uniform bold/black
- [ ] Spacing uses 4/8/12/16/24/32 scale only (no one-off 20, 22, 28 padding except mapped roles)
- [ ] Empty lists show **AppFallback**, not silent blank
- [ ] Money via **AppAmount** (or interim single formatter) — receive/spend/remaining colors
- [ ] Toaster above dock when shell visible
- [ ] Single **CustomBottomSheet**; nested local navigator only; no stacked sheets

## Navigation (owner override — not index center FAB)

- [x] Floating **pill** with **four** destinations: Home, Clients, Supplier/craftsman directory, Items (owner SVG — see [nav-icon-mapping.md](assets/nav-icon-mapping.md))
- [ ] **+** is circular **satellite** beside pill end — **not** center tab slot; side/size **open** (trailing in child order; **owner visual sign-off still required**)
- [x] Content scrolls behind dock; bottom gradient fade (theme-adaptive); `IgnorePointer` on fade; extra list bottom padding clears dock + satellite
- [x] Voucher entry still reachable from **+** (`VoucherLauncher.openFresh`) and contextual flows per [ux-flows.md](ux-flows.md)

## Typography & fonts (implementation gate)

- [ ] **500** and **600** Cairo roles render with real assets **or** verified `FontVariation` on Regular variable font — not faux-bold
- [ ] Muted text uses color tokens, not whole-widget opacity
- [ ] Arabic line height readable; no harmful letter-spacing
- [ ] Statement/PDF smoke separate from this mobile shell checklist

## Phase 1 foundation (2026-11) — done in code, not wired to production

| ID | Task | Status |
|----|------|--------|
| UI-01 | Cairo **400–700** via `FontVariation` on Regular + Bold 700 | **Done** in `AppFont` / `AppText` (preview theme) |
| UI-02 | Port SmartRx widgets under `lib/core/widgets/` | **Done** — see [porting-phase1.md](porting-phase1.md); legacy enum `app_button.dart` retained for features |
| UI-03 | **AppCard** | **Done** (`app_card.dart`) |
| UI-04 | **AppAmount** | **Done** (`app_amount.dart`) |
| UI-05 | **AppFallback** | **Done** (`app_fallback.dart`) |
| UI-P1 | Isolated preview `lib/preview/ui_foundation_main.dart` | **Done** — owner launch only |

## Phase 1.5 (2026-11) — components + production nav shell

| ID | Task | Status |
|----|------|--------|
| UI-F1 | `AppFallback` primary/secondary/tertiary actions | **Done** |
| UI-F2 | `AppButton.text` + destructive pressed tokens | **Done** |
| UI-F3 | `AppDecision` close `semanticLabel` + retry label + dialog scroll bounds | **Done** (regression tests) |
| UI-06 | Production **floating pill** (4 tabs) + satellite `+` | **Done** — voucher uses `VoucherLauncher`; **+ side is implementation choice (trailing), not owner-approved** |
| UI-06b | Owner SVG icons in shell nav | **Done** — FlutterGen + `ShellNavIcons`; mapping [nav-icon-mapping.md](assets/nav-icon-mapping.md); **runtime pixel review on owner Mac still required** |

## Outstanding implementation tasks (post–phase 1.5)

| ID | Task | Notes |
|----|------|--------|
| UI-01b | Wire foundation theme into production shell when approved | Nav uses legacy `AppColors` static tokens; minimal additive |
| UI-02b | Swap feature imports from legacy `app_button` → `buttons/app_button.dart` | After visual sign-off |
| UI-07 | Owner **SVG** icon set in **feature screens** | Nav wired only; home/clients/etc. still Material where present |
| UI-08 | Reconcile all screens to index visual hierarchy | See screenshot diff notes |
| UI-09 | Fix `sample_pdf_artifact_test.dart` output path for local Mac | Separate from UI phase |
| UI-10 | Update `README.md` status line | When owner approves doc pass |

## Current divergence (known — 2026-11 local verify)

From supervised simulator capture vs index:

- Legacy **5-slot** bottom nav with oversized center **+**
- Flat white home cards vs index **gradient stat cards**
- Typography mostly Regular/Bold only — hierarchy flatter than index weights 500–800 mix
- Placeholder icons vs index iconography

## Cross-references

- [Visual reference](visual-reference.md)
- [Design system](design.md)
- [Shared components](shared-components.md)
- [Impeccable rule](../.cursor/rules/bnood-impeccable.mdc)
