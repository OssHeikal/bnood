# Shared UI components

**Status:** V1 app has partial `lib/core/widgets` implementations. Contracts below define the **target** aligned with SmartRx portability and the owner index. Convergence is tracked in [ui-acceptance.md](ui-acceptance.md).

## Principles

- One widget per job — no duplicate buttons, search fields, toasts, or dialogs.
- Sheets: content-sized, drag handle, root navigator from shell.
- Hierarchy via typography roles in [design.md](design.md) — not ad-hoc `TextStyle` in features.
- Port **existing SmartRx code** where noted; adapt theme/l10n/routing only.

## SmartRx portable (confirmed handoff)

| Widget | SmartRx behavior | Bnood adaptation |
|--------|------------------|------------------|
| `AppButton` | Variants: primary, secondary, destructive, outlined, text, success, warning, icon | Bnood colors/Cairo |
| `AppPressable` | Row/card tap affordance | Same |
| `CustomTextField` | `AppInputType` including search, amount, phone | Bnood validators/l10n |
| `Toaster` | Root navigator; above bottom dock | Dock = floating pill layout |
| `AppDecision.show` | Confirm/cancel pattern | Bnood copy |
| `CustomBottomSheet` | Shell, handle, content height; **`.actions` / `.choices`** | **No** nested navigator in SmartRx |

**Bnood-only extension:** `CustomBottomSheet` hosts a **local `Navigator`** for inline-create wizards ([ux-flows.md](ux-flows.md)).

## Bnood components (to implement or converge)

### AppCard

Composable card: padding, radius (8/16/24), optional gradient, border, shadow, background token. Tap wraps **`AppPressable`**. Semantic presets: stat receive/spend/remain, list row, engineer fee card — prefer presets over 50 optional parameters.

### AppAmount

- Integer **piastres** in; formatted string out.
- Variants: receive (green), spend (red), remaining (teal), neutral.
- Controls: size role, show/hide currency, sign policy.
- Single implementation for lists, home, sheets, client header.

### AppFallback

Empty or recoverable error: icon, title, optional description, optional action (add entity, retry). Fills a section (`SliverFillRemaining` / card body) or full screen. No raw exceptions.

### CustomBottomSheet (Bnood behavior)

- `SheetDragHandle`
- Fit content; keyboard insets
- Root navigator when opened from shell
- **Nested** `Navigator` for picker → inline create → back preserves voucher draft

## Anti-patterns

| Do not | Do instead |
|--------|------------|
| Stack multiple bottom sheets | Push route inside sheet navigator |
| Duplicate toast/dialog/button types | Extend App* family |
| Use go_router inside sheet wizard | Local `Navigator` only |
| Format money in each screen | `AppAmount` |
| Leave blank space under section headers | `AppFallback` |
| Reimplement SmartRx widgets from scratch | Port and adapt |

## Cross-references

- [Architecture](architecture.md) — `lib/core/widgets` location
- [UI acceptance](ui-acceptance.md) — UI-02 … UI-05
- [Design system](design.md)
- `.cursor/rules/bnood-ui-components.mdc`
