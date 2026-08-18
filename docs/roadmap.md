# Roadmap

Written 2026-08-18 against commit `2bb1b7b`. Phases are ordered so each one makes the next cheaper — the sequence matters more than the dates.

## Where the app actually is

Three of five tabs are placeholders. One write path exists (`Item`), one read path is complete (`Stock` / `MyItems`). The data model already carries fields nothing consumes yet — `alwaysInList`, `recipesCount`, `stateRaw` — which is a good sign: the schema anticipated features that are still missing, and several of them are cheap to finish rather than build.

The honest summary: **the inventory half works, the acting-on-inventory half does not.** An expiry tracker that only tells you something expired when you remember to open it is a list you forget. Phase 3 is where this app becomes worth keeping installed.

---

## Phase 0 — Make it correct ✅ Done 2026-08-18

Nothing new. Fix what is broken for anyone who is not you, on your device, in dark mode.

- ~~Light Mode readability (#1)~~ — semantic tokens; rows now inherit `.labelPrimary` from the container
- ~~Optional expiration date (#2)~~ — `hasExpiration` toggle gates what gets written; unset saves `nil`
- ~~Separate "to buy" from "in stock" (#3)~~ — Stock filters on `stateRaw` alone
- ~~Placeholder-as-value in the name field (#4)~~ — initializes empty; the placeholder does its job
- ~~Remove the hardcoded `pt_BR` locale (#5)~~ — DatePicker follows the device
- ~~String-based color lookup (#13)~~ — fixed in passing, same lines

**Why first:** these are not polish. Each one produces visibly wrong behavior on a stock device, and #2 and #3 corrupt the data users enter — the longer they ship, the more bad rows exist to migrate later.

Effort: small. All were localized edits, no architecture involved.

**Note:** existing items created before this fix still carry a bogus `expirationDate` of their creation date. There is no migration — decide whether to clear them manually or leave them.

---

## Phase 1 — Make it cheap to change ✅ Done 2026-08-18

Still nothing new. This phase exists because every feature after it touches the same three seams.

- ~~**Extract `ExpiryStatus`** (#9)~~ — `Models/ExpiryStatus.swift`, Foundation-only and clock-injectable. The two copies of `expiryColor(for:)` are gone; `ItemBar` now takes a status and maps the color itself.
- ~~**Type the purchase state** (#7)~~ — `ItemPurchaseState` is `String`-backed with a `StockItem.state` accessor. `stateRaw` stays the stored column but nothing outside `StockItem+Derived.swift` touches it, so no schema change and no migration.
- ~~**Responsive layout** (#6)~~ — every hardcoded 361 / 176.5 / 171 replaced with `maxWidth: .infinity`; card images are resizable and scale to their container.
- ~~Delete `TaskCategory` and unused `@State` vars (#14)~~
- ~~Pluralize the expired banner (#12)~~ — done in passing
- ~~**Test target** (#16)~~ — `InShelfTests/` runs on Swift Testing, covering the expiry boundaries against a fixed clock and the state accessor's round-trip and fallback. The scheme is shared so `xcodebuild test` works from a clean clone, and CI runs it on every pull request.
- **Schema versioning (#15)** — deliberately skipped. No users, no store worth migrating.

**Why second:** this is the only phase with no user-visible output, which makes it the easiest to skip and the most expensive to skip. Doing it after Phase 2 would mean retrofitting a shopping list that already shipped on magic strings.

Run the suite with:

```bash
xcodebuild test -scheme InShelf -destination 'platform=iOS Simulator,name=iPhone 17'
```

---

## Phase 2 — Close the loop

The core user journey — *notice you are out of something → put it on a list → buy it → it goes back in stock* — is half built. The model already supports all of it.

- **Shopping List tab.** The `List` tab exists and shows "Coming Soon". `stateRaw == "toBuy"` already partitions the data, `alwaysInList` already exists to auto-restock staples, and `ItemBarType.addRemove` is already written and rendered only in previews. This is the highest value-per-line feature in the repo: mostly wiring, not building.
- **Check off → move to stock.** Tapping an item complete flips `stateRaw` to `inStock`. This is the single interaction that makes the two tabs one product instead of two lists.
- **Search and filter in Stock.** `Stock.swift:106-119` already renders a magnifying glass and a filter button with empty action closures. Wire `.searchable` and a filter by status (expiring / expired / all) — the latter falls out of Phase 1's `ExpiryStatus` for free.
- **Inline quantity adjustment.** Adjusting a count should not require opening the full editor. `.addRemove` is built for exactly this.
- **Empty state CTAs** (#10) — the copy already promises a button; render it.

**Why third:** this is the smallest amount of work that turns InShelf from an inventory viewer into something used weekly.

Effort: medium. Almost entirely composition of parts that already exist.

---

## Phase 3 — Make it worth keeping

Everything above still requires the user to remember to open the app. This phase removes that requirement, and it is where the app earns its retention.

- **Local expiry notifications.** `UNUserNotificationCenter`, no dependencies, no backend. Schedule on save, cancel on edit or delete. Rough default: one notification 3 days out, one on the day. This is the feature the entire premise depends on — everything else is bookkeeping in service of this alert.
- **Barcode scanning.** `VisionKit`'s `DataScannerViewController` is native and dependency-free. The biggest friction in the app is that adding an item means typing a name and choosing from 50 icons. Scanning collapses that to pointing the camera. Pairing the barcode with a lookup (Open Food Facts has a free API) auto-fills the name — that is the one place a network call earns its complexity, and it should degrade gracefully to manual entry offline.
- **Home screen widget.** WidgetKit reading the same SwiftData store, showing what expires this week. Cheap once `ExpiryStatus` exists, and it is passive retention — the user sees the app without opening it.

**Why fourth:** notifications only make sense once expiry dates are trustworthy (Phase 0 #2) and the status logic lives in one place (Phase 1). Building them earlier means scheduling alerts against dates the app invented.

Effort: notifications small, scanning medium, widget small.

---

## Phase 4 — Expand

Only after the core loop is solid and retained. Each of these is optional and independently valuable.

- **Recipes.** The `Recipes` tab, `MenuCardView` for "My Recipes", `FeaturedCardView`, and `StockItem.recipesCount` are all already scaffolded for it. The interesting version is not a recipe book — it is *"what can I cook with what is about to expire?"*, which is the only recipe feature that uses data the app already has.
- **iCloud sync.** SwiftData supports CloudKit natively; the model needs every attribute to be optional or defaulted. Doing this after Phase 1's schema versioning is straightforward; doing it before is not.
- **Shared pantry.** Two people, one fridge. `CKShare` on top of the above. This is the feature that turns a personal tool into one people tell others about.
- **Profile / settings.** Notification timing, default unit, theme, data export. Currently a placeholder tab.
- **Localization.** A String Catalog with pt-BR and en. The `pt_BR` DatePicker override removed in Phase 0 is the symptom of doing this by hand.
- **Waste stats.** "You threw away 4 items this month." Requires logging discards, which requires a discard action, which does not exist yet.

---

## Deliberately not doing

- A ViewModel / repository layer. At 1100 lines with `@Query` and `@Model`, indirection costs more than it saves. Revisit if a screen ever needs logic that cannot be a computed property.
- Third-party dependencies. Everything above is achievable with Apple frameworks. The one exception under consideration is a barcode-to-product lookup, and that is a URL, not an SDK.
- An account system. Sync via iCloud requires no accounts, no server, and no privacy policy about storing user data.
