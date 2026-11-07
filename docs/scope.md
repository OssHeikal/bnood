# Scope: V1 and V2

## V1 (local-only)

**Confirmed:** Single engineer, single device, SQLite via Drift, no network dependency for core workflows.

### In scope

- Auto workspace; clients with auto-created initial project ([Decisions](decisions.md))
- Global catalogs: items, suppliers, craftsmen; project-scoped transactions and agreements
- Home totals (all-time, **active projects only** — no today/month KPIs)
- Client/project detail: balance, totals, engineer card, craftsman previews, top expense items, latest movements
- Vouchers: receive and spend (materials/labor), cash/transfer, notes/photos
- Transaction edit and delete (local only)
- Client statement (in-app + PDF share) for a selected period; supplier statement/history
- Archive semantics for linked entities
- Arabic-first UI with English l10n foundation; light/dark themes

### Out of scope for V1

| Item | Notes |
|------|--------|
| Login / accounts | — |
| Server / API / sync | Repository abstraction only; no backend scaffold |
| Subscription / paywall UI | — |
| Team / company / permissions UI | — |
| PIN / app lock | — |
| Backup / restore | — |
| Overspend alerts | — |
| Budget vs actual | — |
| Wallet payment type | Cash and transfer only |
| Engineer fee on default client PDF | Internal / informational only |
| Shared project funding vs custody ledger | Deferred; see [Open questions](open-questions.md) |

### V1 success criteria (documentation level)

Implementation phases in [Implementation plan](implementation-plan.md) define executable acceptance checks. At product level, V1 is done when an engineer can track client money, suppliers, craftsmen, and items offline, produce a reconciled Arabic RTL client PDF, and archive entities without breaking history.

---

## V2 (deferred SaaS)

**Confirmed direction only** — not licensed for implementation in the current documentation pass.

### V2-only capabilities (planned)

- **SaaS** with Personal and Enterprise tiers; monthly and annual billing (prices **open**)
- **Free Personal:** 1 client + 1 project ([limits configurable in future policy — not hardcoded arbitrarily](open-questions.md))
- **Enterprise:** company / team / project permissions
- Permitted members’ transactions immediately affect balance (**no manager approval**)
- Backend, auth, sync, conflict handling, role matrix (**open** design)

### Open after reconsideration

- Shared project funding versus engineer custody; recording author ≠ payer/custodian — do not lock a ledger design in V1 docs or code.

### Relationship to V1

V1 uses an abstract repository layer and workspace IDs to **prepare** for scale. That is not a guarantee of zero migrations when sync ships.

---

## Localization

| Aspect | V1 |
|--------|-----|
| Primary UX copy | Arabic, Egyptian-friendly |
| Technical docs & rules | English |
| Product strings in docs | Arabic labels may appear **quoted** for UI reference only |
| Themes | Light and dark |

See [Design system](design.md) for visual tokens.

---

## Cross-references

- [Architecture](architecture.md) — stack and modules
- [Data schema](data-schema.md) — entities and money rules
- [UX flows](ux-flows.md) — screens and navigation
- [Open questions](open-questions.md) — unresolved items
