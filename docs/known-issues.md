# Known Issues

Findings from a full-source review on 2026-08-18. Severity is user impact, not effort.

Numbers are stable IDs — when an issue is fixed its entry is deleted, and the remaining numbers do **not** shift. Gaps in the sequence mean something was fixed.

**Fixed 2026-08-18 (Phase 0):** #1 Light Mode, #2 always-expiring items, #3 to-buy leaking into Stock, #4 placeholder-as-value, #5 pinned `pt_BR` locale, #13 string-based color lookup.

## P1 — Layout and correctness

**6. Hardcoded widths overflow small screens.** `ItemBar.swift:59` (`width: 361`), `MenuCardView.swift:43` (`176.5`), `FeaturedCardView.swift:19` (`361`), and `Item.swift` (`minWidth: 361` / `171`, seven call sites) are absolute point values derived from a 393pt design. On iPhone SE (375pt) and iPhone mini they clip or force horizontal scroll, and `minWidth` blocks any Dynamic Type reflow.
→ `.frame(maxWidth: .infinity)` with padding at the container.

**7. `stateRaw` is an untyped string.** `StockItem.swift:14` stores state as `String`, compared against `"inStock"` / `"toBuy"` literals in `Item.swift`, `Stock.swift:15`, and `MyItems.swift:37`. One typo silently desyncs a screen with no compiler error. `ItemIcon` and `UnitType` already demonstrate the fix in this codebase.
→ Make `ItemPurchaseState: String, Codable` and store it directly; SwiftData persists `Codable` enums.

**8. Validation alert is unreachable.** `Item.swift` shows `showValidationAlert` when the name is invalid, but `.disabled(!isNameValid)` on the same button uses the identical predicate. The button cannot be tapped in the state that triggers the alert.
→ Pick one. Keeping the alert and dropping `.disabled` gives better feedback than a dead button.

**9. Expiry logic is duplicated.** `expiryColor(for:)` exists verbatim in `Stock.swift:46` and `MyItems.swift:9`, and the copies have already drifted cosmetically (`nowStart` vs. a locally recomputed `now`). Adding a fourth expiry tier means editing two files and hoping.
→ Extract to a single `ExpiryStatus` enum with `color` and `label`, computed from `StockItem`. This is the seam every roadmap feature touches — notifications, widgets, filters, sorting.

## P2 — Polish and dead code

**10. `EmptyStateView` promises an action it never offers.** `EmptyStateView.swift:6` requires an `action: () -> Void`, both call sites pass `{}`, and the body renders no button — despite copy reading "Create a product and it will appear here."
→ Either render a CTA that calls `action`, or drop the parameter.

**11. Selected purchase-state button looks disabled.** `Item.swift` applies `.opacity(0.5)` to the *selected* state while also drawing a colored stroke on it. Dimming conventionally means unavailable; the two signals contradict.

**12. "1 expired items".** `ItemBar.swift:72` interpolates a raw count.
→ `Text("^[\(expiredCount) item](inflect: true) expired")`.

**14. Dead code.** `TaskCategory.swift` is entirely unused — nine to-do-app categories (Education, Fitness, Travel…) in a pantry app, presumably left from a template. `ItemBarType.addOnly` / `.addRemove` / `.simple` are referenced only in previews, so those branches are unexercised. `Item.swift:38` (`misc`) is declared and never read.
→ Delete `TaskCategory` and `misc`. Keep the `ItemBarType` cases — `.addRemove` is exactly what the shopping list needs (roadmap Phase 2).

**15. No schema versioning.** `InShelfApp.swift:10` configures a bare `.modelContainer(for: [StockItem.self])`. The first non-additive change to `StockItem` will fail to open an existing store on a user's device with no migration path.
→ Adopt `VersionedSchema` + `SchemaMigrationPlan` before the first TestFlight build, not after.

## Verified non-issues

Checked and confirmed correct — do not "fix" these:

- All 50 `ItemIcon` raw values map to real imagesets, including the ones with spaces and the `"sushi rool"` spelling.
- The `validItems` sort comparator in `Stock.swift:32` is a valid strict-weak ordering; undated items sort last as intended.
- `.onDelete` in `MyItems.swift:48` maps indices to objects *before* deleting, which is the index-safe order.
- `didLoadFromItem` in `Item.swift:47` correctly guards against `.onAppear` firing twice and clobbering in-progress edits.
