# Design system

**Confirmed** visual direction for Flutter implementation. HTML demos may use placeholders; production icons are Material Icons in the app.

## Semantic colors

| Role | Light / dark usage |
|------|---------------------|
| Primary | Teal |
| Receive / success money | Green |
| Spend / outflow | Red |
| Warning, remaining emphasis | Dedicated warning token |
| Surfaces | Material-style elevated/neutral surfaces |

## Accent palette (10)

Teal, green, blue, purple, pink, orange, gold, brick-red, turquoise, olive — item color picks and chips; light theme may use subtle gradients on accents.

## Layout tokens

| Token | Values (dp) |
|-------|-------------|
| Spacing | 4, 8, 12, 16, 24, 32 |
| Corner radii | 8, 16, 24 |
| Typography | Balance amounts: display/balance style; captions for metadata |

Font family: **Cairo** for Arabic and Latin in app UI.

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

## Cross-references

- [Shared components](shared-components.md) — widgets
- [UX flows](ux-flows.md) — where tokens apply
