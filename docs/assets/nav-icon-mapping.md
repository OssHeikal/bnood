# Shell navigation icon mapping (owner review)

Mapped from the 73 SVG set by **filename semantics**, not app screen design. No filled/selected asset variants — active state is **tint + label weight** only (`ColorFilter.srcIn` on stroke-based outlines).

| Role | FlutterGen getter | Asset file | Notes |
|------|-------------------|------------|--------|
| Home tab | `Assets.icons.homeOutline` | `home_outline.svg` | House outline |
| Clients tab | `Assets.icons.clientsOutline` | `clients_outline.svg` | People/clients |
| Directory tab (suppliers + craftsmen) | `Assets.icons.directoryOutline` | `directory_outline.svg` | Explicit directory glyph |
| Items tab | `Assets.icons.itemsLayersOutline` | `items_layers_outline.svg` | Layered items; `categories_outline.svg` exists but not used |
| Voucher satellite (+) | `Assets.icons.addOutline` | `add_outline.svg` | Outside pill; semantic label `navAdd` |

**Not used in nav:** social (`whatsapp_*`, `instagram_*`), construction literals (hammer, shovel, etc.), arrow/chevron variants.

**Satellite placement:** trailing side of pill in reading order (`Row` pill → gap → +). Diameter **`AppSize.shellDockHeight`** (64), same as pill height. Owner has **not** locked LTR/RTL geometry; visual sign-off still open per [ui-acceptance.md](../ui-acceptance.md).

**Nav labels (AR/EN):** one word via `navHome` / `navClients` / `navDirectory` / `navItems`. Directory **screen** title uses `directoryTitle` (long Arabic unchanged).

**Multicolor:** Nav picks outline strokes only; multicolor brand SVGs are out of scope for the dock.
