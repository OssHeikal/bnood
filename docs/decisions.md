# Confirmed decisions vs proposals

Use this page with [Open questions](open-questions.md) and domain-specific docs. **Confirmed** items are inputs for implementation unless superseded by an explicit change.

## Confirmed — product

| Area | Decision |
|------|----------|
| Audience | Finishing/site engineers and contractors managing client funds, items, suppliers, craftsmen |
| V1 connectivity | Local-only; no login, server, sync, subscription, or team UI |
| Security V1 | No PIN |
| Data safety V1 | No backup/restore in V1 |
| Alerts V1 | No overspend alerts; no budget vs actual |
| Localization | Arabic-first, Egyptian-friendly copy; English localization foundation; light and dark themes |
| Workspace | Single invisible auto-created workspace (user never manages it) |
| Client vs project | Client is separate from Project; adding a client auto-creates an initial project with no extra steps; current client page acts as project UI |
| Archives | Linked clients/projects/items/suppliers/craftsmen are archived, not deleted; excluded from new selections; history retained |
| IDs & audit fields | Every record: locally generated unique ID; `createdAt` / `updatedAt` timestamps |
| Money | EGP integer **piastres** (minor units); no floats |
| Payment methods | Cash or transfer only (no wallet) |
| Engineer fee | Optional percentage on project; informational estimated profit only; not deducted; not on default client PDF |
| Statements V1 | Client in-app + shareable PDF; supplier statement/history in V1 |
| Navigation | ≤5 tabs: Home, Clients, center +, supplier/craftsman directory, Items; no summary tab |

## Confirmed — data model

See [Data schema](data-schema.md) for full field lists. Confirmed relationship rules:

- Shared workspace catalog: **Item**, **Supplier**, **Craftsman** (suppliers and craftsmen are separate entities).
- **ProjectCraftsmanAgreement**: per project + craftsman; nullable initial amount; independent across projects; blank amount distinct from `0`.
- **Transaction**: project, receive/spend, integer amount, date, cash/transfer; optional description and receipt image.
- **Expense** transactions: also item, materials/labor type; optional supplier (materials) OR craftsman (labor). Receive has no expense-specific fields.
- Craftsman picker on a project uses assignments from global roster.
- Edit and delete transactions supported in V1 (deletion/conflict semantics **open**).
- All FK relationships must stay workspace-consistent.

## Confirmed — UX patterns

| Pattern | Rule |
|---------|------|
| Inline create | One `CustomBottomSheet` with nested local `Navigator`; never stacked sheets/dialogs; preserve form; save returns entity; cancel restores; Back pops inner route |
| Voucher entry | Contextual: Home + client/type resets stale state; client actions preselect project/type; receive hides expense fields; client change clears incompatible craftsman |
| Expense type UI | Materials / labor **segmented toggle**, not dropdown |
| Movement styling | Incoming green / outgoing red arrows; clear amount, type, item, payee, date, description |

## Proposal — organization (not locked)

- Additional **project** and **craftsman** module split under `lib/features/` beyond the baseline feature map in [Architecture](architecture.md).
- Workspace ID abstraction to ease future scale (does not guarantee zero migrations).

## Not in V1 (explicit)

SaaS billing, auth, sync, conflicts, role matrix, enterprise team permissions, manager approval flows — see [Scope V2](scope.md#v2-deferred-saas).
