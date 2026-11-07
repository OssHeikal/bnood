# Bnood بنود

Foundation documentation for **Bnood** (formerly عهدة): a local-first mobile app for finishing/site engineers and contractors who manage client funds, work items, material suppliers, and labor craftsmen.

**Status:** V1 Flutter app (local-only) on branch `cursor/v1-implementation-edb5`. Foundation docs in PR #1.

## Documentation index

| Document | Summary |
|----------|---------|
| [Scope (V1 & V2)](docs/scope.md) | Product boundaries, in-scope vs deferred, localization |
| [Architecture](docs/architecture.md) | Flutter layout, modules, stack, repository pattern |
| [Data schema & invariants](docs/data-schema.md) | Entities, relationships, money rules, ER diagram |
| [UX & screen flows](docs/ux-flows.md) | Navigation, screens, vouchers, inline create, statements |
| [Design system](docs/design.md) | Theme, tokens, default catalog items (Arabic labels quoted) |
| [Shared components (planned)](docs/shared-components.md) | UI contracts inspired by internal patterns; not implemented |
| [Implementation plan](docs/implementation-plan.md) | Phased delivery and acceptance checks |
| [Open questions](docs/open-questions.md) | Unresolved product and technical decisions |
| [Confirmed decisions](docs/decisions.md) | Locked choices vs proposals |

## Cursor rules

Project rules live under [`.cursor/rules/`](.cursor/rules/). They are short, scoped, and intended for agents and contributors during future implementation.

## Working agreements (standing)

- Ask before heavy cloud-agent cost; one cloud agent at a time.
- Planning: explicit Grok 4.7 / 4.6; implementation and doc edits: Composer 2.5 fast (`fast: false`); no Auto.
- **No application implementation** until explicitly approved beyond this documentation pass.

## Quick links

- V1: [local-only scope](docs/scope.md#v1-local-only)
- Money model: [piastres & balances](docs/data-schema.md#financial-invariants)
- Build order: [phase 1–5](docs/implementation-plan.md)
