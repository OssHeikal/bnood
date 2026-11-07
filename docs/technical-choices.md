# Technical choices (implementation proposals)

These are **current code defaults**, not confirmed product decisions unless listed in [decisions.md](decisions.md).

| Topic | V1 implementation | Tests |
|-------|---------------------|--------|
| Engineer estimated profit | `engineerBasisPoints` int; profit `(totalSpend * bp) ~/ 10000` (floor) | `test/money_format_test.dart`, `test/basis_points_test.dart` |
| Statement opening balance | Sum of receives/spends **before** period start | `test/ledger_math_test.dart` |
| Agreement amount | SQL `NULL` distinct from `0` | `test/agreement_test.dart` |

Open product question [OQ-07](open-questions.md) remains **open**.
