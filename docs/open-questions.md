# Open questions

Unresolved items — **do not implement** a single chosen behavior until product confirms. Linked from [Decisions](decisions.md) and domain docs.

## Data & sync

| ID | Topic | Notes |
|----|--------|--------|
| OQ-01 | Transaction sync deletion | Local delete in V1; multi-device semantics TBD |
| OQ-02 | Conflict resolution | Required for V2 sync |
| OQ-03 | Audit trail | History of edits/deletes for compliance? |
| OQ-04 | Historical rename | Client/supplier/item rename on old PDFs/statements |
| OQ-05 | Workspace migrations | IDs prepare for scale; zero-downtime migration not guaranteed |

## Financial

| ID | Topic | Notes |
|----|--------|--------|
| OQ-06 | Negative project balance | Allow with warning vs block — undecided |
| OQ-07 | Engineer % precision | Rounding for `estimatedProfit` display |
| OQ-08 | Statement period opening | Opening balance / carry-forward vs period-only activity |
| OQ-09 | Shared funding vs custody | V2: author ≠ payer; ledger model deferred |

## V2 SaaS

| ID | Topic | Notes |
|----|--------|--------|
| OQ-10 | Role matrix | Enterprise permissions detail |
| OQ-11 | Pricing & paid limits | Personal free tier caps; configurable policy |
| OQ-12 | Backend stack | Auth provider, API shape, sync protocol |

## UX / PDF

| ID | Topic | Notes |
|----|--------|--------|
| OQ-13 | Supplier PDF | In-app required; PDF share optional vs mandatory |
| OQ-14 | Page breaks | Long grouped item sections in Arabic PDF |

## Process

| ID | Topic | Notes |
|----|--------|--------|
| OQ-15 | Test strategy | Flutter test layout not defined in this doc pass |

When closing a question, move the outcome to [Decisions](decisions.md) and update affected schemas/UX sections.
