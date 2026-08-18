# Architecture

How InShelf is put together. Read this before changing data flow, adding a screen, or touching persistence.

## Shape of the app

Single target, no modules, no dependencies. SwiftUI views read and write SwiftData directly — there is no ViewModel, repository, or service layer, and at ~1100 lines none is warranted.

```
InShelfApp (@main)
  └─ .modelContainer(for: [StockItem.self])   ← the only persistence setup
       └─ TabBar (TabView, 5 tabs)
            ├─ Recipes  → ComingSoon
            ├─ List     → ComingSoon
            ├─ Create   → Create ─┬─ FeaturedCardView
            │                     └─ MenuCardView → MyItems ─┬─ ItemBar (rows)
            │                                                └─ Item (create / edit form)
            ├─ Stock    → Stock ──── ItemBar (rows)
            └─ Profile  → ComingSoon
```

Three of five tabs are placeholders. `Create` is the only path that reaches the editor, and `Item` is the only writer in the app.

## Data flow

Reads are declarative, writes are imperative:

- **Read** — `@Query(sort: \StockItem.createdAt, order: .reverse)` in `Stock` and `MyItems`. Filtering and sorting happen in Swift computed properties on the view, not in the query predicate.
- **Write** — `Item.swift` holds `@State` copies of every field, hydrates them from the passed-in `StockItem` in `.onAppear` (guarded by `didLoadFromItem`), and on save either mutates the existing model object or inserts a new one via `modelContext.insert`. SwiftData autosaves; there is no explicit `save()`.
- **Delete** — `.onDelete` in `MyItems` maps `IndexSet` to objects before calling `modelContext.delete`, which is the index-safe order.

The `Item` screen intentionally edits a *copy* in `@State` so an abandoned edit does not dirty the model. The trade-off is the hydration guard: `didLoadFromItem` exists because `.onAppear` can fire more than once and would otherwise stomp in-progress edits.

## Model

`StockItem` is the only persisted type.

| Field | Type | Notes |
|---|---|---|
| `name` | `String` | Trimmed on save |
| `iconRaw` | `String` | Raw value of `ItemIcon`; falls back to `.avocado` when unmapped |
| `quantity` | `Int` | Floor-clamped at 0 in the editor |
| `unitRaw` | `String` | Raw value of `UnitType` (`units` / `kg` / `g`) |
| `notes` | `String` | Labelled "Description" in the UI |
| `expirationDate` | `Date?` | Optional in the model, but the editor never writes `nil` — see known issues |
| `alwaysInList` | `Bool` | Reserved for the shopping list; nothing reads it yet |
| `recipesCount` | `Int` | Reserved for recipes; display-only, never incremented |
| `stateRaw` | `String` | `"toBuy"` or `"inStock"` — untyped, compared as literals in 3 files |
| `createdAt` / `updatedAt` | `Date` | `updatedAt` is only touched on edit, not on insert |

No schema versioning or `VersionedSchema` is configured. Any change to `StockItem` that is not purely additive will fail to open existing stores on device.

## Derived state

Expiry classification is the app's core logic and currently lives in two places.

```
expired      target < today
expiring     0 ≤ (target − today) ≤ 3 days   → .orangePrimary
valid        otherwise, or no date            → .greenPrimary
```

`Stock` additionally partitions items: expired ones collapse into a single `.warning` summary row, the rest sort ascending by expiration date with undated items last. `MyItems` does no partitioning and shows everything.

`expiryColor(for:)` is duplicated verbatim in `Stock.swift` and `MyItems.swift`. Extracting it (as an `ExpiryStatus` enum on `StockItem`) is Phase 1 work — it is the seam every future feature touches.

## Design system

Everything visual is driven by the asset catalog. Never inline a color.

**Semantic tokens** — `BackgroundPrimary` (screen), `BackgroundSecondary` (cards, rows), `BackgroundTertiary`; `LabelPrimary`, `LabelSecondary`, `LabelTertiary`.

**Accent tokens** — `RedPrimary` (tab tint), `RedSecondary` (destructive, expired, interactive glyphs), `GreenPrimary` (valid, additive actions), `OrangePrimary` (expiring soon).

**Shape** — 16pt corner radius throughout. Rows that carry a warning banner use `UnevenRoundedRectangle` with square bottom corners so the banner reads as one unit.

**Icons** — 50 SVG imagesets under `Assets.xcassets/Icons/`, enumerated by `ItemIcon`. Raw values match filenames exactly, including spaces (`"hot dog"`, `"sushi rool"` — the typo is in the asset name and must be preserved).

## Components

| Component | Purpose | Notes |
|---|---|---|
| `ItemBar` | The one row type, driven by `ItemBarType` | 5 cases; only `.normal` and `.warning` are used in production |
| `EmptyStateView` | Illustration + copy for empty lists | Takes an `action` closure that is never called and renders no button |
| `MenuCardView` | Navigation card on the Create hub | |
| `FeaturedCardView` | Static promo banner | Hardcoded copy, no destination |

`ItemBarType` is a closed enum carrying display data as associated values rather than taking a `StockItem`. That keeps the component previewable without a model container, which is why previews work without an in-memory store.

## What is deliberately absent

No networking, no auth, no analytics, no CloudKit, no notifications, no localization catalog, no test target, no CI. Each of these is a roadmap decision, not an oversight — see [roadmap.md](roadmap.md).
