# Phased implementation plan

**Not execution permission** — ordering and acceptance criteria for when implementation is approved. Aligns with [Scope](scope.md) and [Decisions](decisions.md).

Standing rules during build:

- Ask before heavy cloud-agent cost; one cloud agent at a time.
- Planning: Grok 4.7 / 4.6; implementation: Composer 2.5 (`fast: false`); no Auto.

## Phase 1 — Foundation

**Deliverables (proposal locations):**

- FVM + Flutter project skeleton
- Theme (light/dark), Cairo, l10n AR/EN foundation
- Planned shared widgets stubbed per [Shared components](shared-components.md)
- `CustomBottomSheet` + nested navigator pattern demo route
- Drift DB + auto workspace migration
- go_router shell with floating **pill** (four destinations) + voucher **satellite** (see [ux-flows.md](ux-flows.md); legacy ≤5-tab center-FAB is obsolete)

**Acceptance:**

- App launches offline; workspace row exists without user action.
- Nested sheet: push/pop inner route; cancel restores prior state.
- DB migrations run cleanly on fresh install.

## Phase 2 — Clients, catalogs, archive, inline create

**Deliverables:**

- Client CRUD + auto initial project
- Items, suppliers, craftsmen catalogs
- Archive flags; archived excluded from pickers
- Inline create from pickers (single sheet pattern)

**Acceptance:**

- New client → exactly one project visible on client page without extra steps.
- Archive supplier → still visible on old transactions, absent from new picker.
- Create item from voucher picker → returns selection; parent form intact.

## Phase 3 — Vouchers, edit/delete, home totals

**Deliverables:**

- Receive/spend with materials/labor, cash/transfer, photos
- Edit/delete transactions
- Home all-time totals (active projects only)

**Acceptance — financial fixture:**

| Event | Piastres |
|-------|----------|
| Receive | 2_000_000 (20,000 EGP) |
| Materials | 500_000 |
| Labor | 300_000 |

Expect project balance **1_200_000**; home totals match sum across active projects only.

## Phase 4 — Client detail, agreements, previews

**Deliverables:**

- Engineer % card (informational profit)
- Craftsman agreement nullable amount; previews (3) paid/remaining
- Top 3 items bars; latest 5 movements; See all routes

**Acceptance:**

- Agreement 800_000, labor paid 300_000 → remaining **500_000**; project balance still **1_200_000** from phase 3 fixture.
- Null agreement → paid shown, remaining hidden.

## Phase 5 — Statements, PDF, polish

**Deliverables:**

- Client statement period UI + PDF + share
- Supplier statement/history
- RTL tables, dark mode pass, mobile sanity checks

**Acceptance:**

- PDF totals match in-app statement for same period and fixture data.
- Receipts section separate from per-item expense groups.
- Default PDF excludes engineer fee line.

## Regression checklist (end of V1)

- [ ] No network calls required for core flows
- [ ] All money stored as integers
- [ ] Transaction delete updates balances
- [ ] Arabic RTL statement renders without clipped diacritics (smoke test)

## Cross-references

- [Data schema](data-schema.md) — invariants tested above
- [UX flows](ux-flows.md) — screen completeness
- [Open questions](open-questions.md) — blockers before phase 5 period logic
