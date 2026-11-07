# Design system

Visual direction for Flutter implementation. **Authoritative layout and styling:** owner `index.html` — see [visual-reference.md](visual-reference.md). **Navigation:** owner override supersedes index center-FAB bar — see [ux-flows.md](ux-flows.md).

Production icons: owner-supplied **SVG** (planned). Current app may use Material placeholders.

## Semantic colors

Index-aligned light tokens (**confirmed** in index CSS; mirrored in `AppColors`):

| Role | Hex / usage |
|------|-------------|
| Primary | `#0D9B8A` |
| Primary dark | `#0A7A6C` |
| Success / receive | `#1B9E5A` |
| Danger / spend | `#D64545` |
| Remaining emphasis | Primary teal (same family as remaining money) |
| Background | `#F4F7F6` |
| Surface | `#FFFFFF` |
| On-surface | `#1A2422` |
| On-surface muted | `#5C6B68` |
| Outline | `#D5DEDC` |

**Proposal:** Dark mode keeps role names with `AppColors` dark constants; gradient stops reinterpreted for contrast (index HTML is light-first).

## Accent palette (10)

Teal, green, blue, purple, pink, orange, gold, brick-red, turquoise, olive — item color picks and chips; light theme may use subtle gradients on accents (per index item rows).

## Layout tokens

| Token | Values (dp) — **confirmed** |
|-------|---------------------------|
| Spacing | 4, 8, 12, 16, 24, 32 |
| Corner radii | 8, 16, 24 |
| Screen horizontal gutter | 16 |
| Icon touch control | 40×40 class (index icon buttons) |
| Nav chrome height basis | 64 + safe area (index `--nav-h`) — pill layout **proposal** sizing |

### Spacing rules

- **Intra-component** (inside card, between label and value): 6–8 where index uses tight meta; prefer **8** or **12** from scale.
- **Between sections** on a screen: **16–24**.
- **Between cards in a stack:** **12** default (`stack` gap in index).
- Sheets: fit content; **16** horizontal padding typical; no full-screen empty form unless data requires it.

## Typography

Font family: **Cairo** for Arabic and Latin.

### Current font inventory (read-only verified 2026-11)

| Asset | Registration | Technical note |
|-------|--------------|----------------|
| `Cairo-Regular.ttf` | `weight: 400` in `pubspec.yaml` | Variable font; **`wght` axis 200–1000** |
| `Cairo-Bold.ttf` | `weight: 700` | **700** static face; no `wght` axis |
| Medium / SemiBold files | **Absent** | Required for faithful index weights **500** and **600** unless `FontVariation` applied |

**Do not** claim Medium/SemiBold exist until UI-01 in [ui-acceptance.md](ui-acceptance.md) is done.

### Text roles (hierarchy)

Combine **size + weight + color + line height**. Weights in **bold** are index targets; until UI-01, implementation may temporarily approximate — must not be called “design complete.”

| Role | Size | Weight | Color |
|------|------|--------|-------|
| Main balance | 28 | 700–800 | Money semantic |
| Page title | 22 | 700–800 | On-surface |
| Section title | 15 | 700 | On-surface |
| Card / stat label | 13 | **600** | Muted |
| Body emphasis | 14 | 700 | On-surface |
| Subtitle / secondary | 13 | **500** | Muted |
| Supporting | 12 | **500** | Muted |
| Caption / meta | 11–12 | **500** | Muted |
| Money medium / small | 18 / 14 | 700 | Money semantic |

**Proposed** Arabic line height: 1.35–1.45 for body and captions. **No** tracking that breaks Arabic cursive. Money: tabular digits; currency in muted semantic color, not opacity hack.

See `.cursor/rules/bnood-ui-design.mdc` for anti-patterns and dock/scroll rules.

## Surfaces & elevation

- Cards: white surface, radius **16**, shadow `0 2px 12px` rgba(26,36,34,0.06) class (index `--shadow`)
- Stat cards: role-specific **gradients** (receive / spend / remain)
- List rows: optional accent stripe; movement rows green/red amount semantics

## Default workspace items (seed catalog)

Arabic names are **product/UI labels** (quoted). English `l10n` keys should map to equivalent English strings.

| # | English (seed meaning) | Arabic label (UI) |
|---|------------------------|-------------------|
| 1 | Demolition / removal | «هدم وإزالة» |
| 2 | Plastering | «محارة» |
| 3 | Flooring | «أرضيات» |
| 4 | Ceramic / bathrooms | «سيراميك وحمامات» |
| 5 | Plumbing | «سباكة» |
| 6 | Electrical | «كهرباء» |
| 7 | Gypsum board | «جبس بورد» |
| 8 | Painting | «دهانات» |
| 9 | Carpentry / doors | «نجارة وأبواب» |
| 10 | Kitchen | «مطبخ» |
| 11 | Aluminum / shutters | «ألوميتال وشتر» |
| 12 | AC | «تكييف» |
| 13 | Lighting | «إضاءة» |
| 14 | Labor | «أيدي عاملة» |
| 15 | Transport / errands | «نقل ومهمات» |
| 16 | Miscellaneous | «متنوعات» |

**Confirmed:** Sixteen default items seeded on first workspace creation.

## Themes

- Light and dark fully supported
- Teal primary; receive/spend semantic colors consistent across modes
- Token-driven gradients — avoid per-screen one-off colors

## Cross-references

- [Shared components](shared-components.md)
- [UX flows](ux-flows.md)
- [UI acceptance](ui-acceptance.md)
- [Visual reference](visual-reference.md)
