# Visual reference (index.html)

## Authority

The owner-maintained **`index.html`** interactive prototype is the **authoritative visual reference** for Bnood V1 UI — not loose inspiration.

**Owner override (2026-11):** Bottom navigation in the index still shows a **legacy 5-slot bar with center voucher FAB**. Product direction now requires the **floating pill (4 destinations) + independent satellite +** pattern documented in [decisions.md](decisions.md) and [ux-flows.md](ux-flows.md). Implement the override; keep all **other** index treatments (cards, money, sheets, typography, colors).

Store the HTML outside git or in a local-only path the owner controls. Extracted tokens live in [design.md](design.md). Do not commit multi-hundred-KB embedded font payloads unless the owner explicitly asks.

## What to extract from index

| Area | Use |
|------|-----|
| CSS variables (`--primary`, `--space-*`, `--radius-*`) | Theme tokens |
| `.money.*`, `.stat-card`, `.card`, `.mov-row` | Component shapes and hierarchy |
| Sheet/toast positioning | Overlay geometry |
| Typography sizes/weights in CSS | Role table in [design.md](design.md) |

## Verification

1. Run app on ~390px-wide simulator (e.g. iPhone class).
2. Screenshot home, client detail, voucher sheet (cancel without saving), statement if data exists.
3. Compare side-by-side with index screens — hierarchy, spacing, gradients, nav chrome.
4. Record pass/fail in [ui-acceptance.md](ui-acceptance.md).

Automated tests alone are insufficient for design sign-off.

## Cross-references

- [UI acceptance](ui-acceptance.md)
- [Design system](design.md)
- [Shared components](shared-components.md)
