# Shared UI components (planned)

**Status:** Contracts for future Flutter implementation. **No widgets exist in this repository.** Names and APIs are **proposals** derived from internal Dog/SmartRx patterns — not copies of code from other repos.

## Principles

- One widget per job — avoid duplicate `CustomButton`, `CustomSearchField`, `CustomDialog`, `CustomToast`.
- Sheets: size to content, drag handle, `useRootNavigator` from shell; nested navigator for wizards only.

## Planned components

### AppButton

Variants: `primary`, `secondary`, `destructive`, `outlined`, `text`, `success`, `warning`, `icon`.

### AppPressable

Tappable rows and cards (ripple/scale policy TBD at implementation).

### CustomTextField

Single constructor with `AppInputType` (text, phone, search, amount, multiline, …). **One** search field implementation — no parallel search widgets.

### Toaster

Bound to `rootNavigatorKey`; variants: success, failure, warning, info, loading; appears above bottom dock.

### AppDecision.show

Confirmation helper — neutral cancel, primary confirm; **no raw `showDialog`** for standard decisions.

### CustomBottomSheet

- `SheetDragHandle`
- Height: fit content
- Called with root navigator from app shell
- Hosts **nested local `Navigator`** for inline-create subflows ([UX flows](ux-flows.md))

## Anti-patterns

| Do not | Do instead |
|--------|------------|
| Stack multiple bottom sheets | Push route inside sheet navigator |
| Duplicate toast/dialog/button types | Extend App* family |
| Use go_router inside sheet wizard | Local `Navigator` only |

## Cross-references

- [Architecture](architecture.md) — where components live (`lib/core/widgets` proposal)
- [Implementation plan](implementation-plan.md) — phase 1 widget shell
