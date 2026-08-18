# Known Issues

Findings from a full-source review on 2026-08-18. Severity is user impact, not effort.

Numbers are stable IDs — when an issue is fixed its entry is deleted, and the remaining numbers do **not** shift. Gaps in the sequence mean something was fixed.

**Fixed 2026-08-18 (Phase 0):** #1 Light Mode, #2 always-expiring items, #3 to-buy leaking into Stock, #4 placeholder-as-value, #5 pinned `pt_BR` locale, #13 string-based color lookup.

**Fixed 2026-08-18 (Phase 1):** #6 hardcoded widths, #7 untyped state, #9 duplicated expiry logic, #12 pluralization, #14 dead code.

## P1 — Layout and correctness

**8. Validation alert is unreachable.** `Item.swift` shows `showValidationAlert` when the name is invalid, but `.disabled(!isNameValid)` on the same button uses the identical predicate. The button cannot be tapped in the state that triggers the alert.
→ Pick one. Keeping the alert and dropping `.disabled` gives better feedback than a dead button.

## P2 — Polish and dead code

**10. `EmptyStateView` promises an action it never offers.** `EmptyStateView.swift:6` requires an `action: () -> Void`, both call sites pass `{}`, and the body renders no button — despite copy reading "Create a product and it will appear here."
→ Either render a CTA that calls `action`, or drop the parameter.

**11. Selected purchase-state button looks disabled.** `Item.swift` applies `.opacity(0.5)` to the *selected* state while also drawing a colored stroke on it. Dimming conventionally means unavailable; the two signals contradict.

**15. No schema versioning.** `InShelfApp.swift:10` configures a bare `.modelContainer(for: [StockItem.self])`. The first non-additive change to `StockItem` will fail to open an existing store with no migration path.
→ Deliberately deferred: there are no users, so there is no store worth migrating. Adopt `VersionedSchema` + `SchemaMigrationPlan` before the first build that reaches a device someone else owns.

**16. No Xcode test target.** `ExpiryStatus` is covered by `Scripts/check-expiry-status.swift`, which compiles the real source and asserts against a fixed clock — but it runs by hand, not in Xcode and not in CI. Adding a target means editing `project.pbxproj`, which is safest done through Xcode (File → New → Target → Unit Testing Bundle).
→ When the target exists, port the cases from the script and delete it.

## Verified non-issues

Checked and confirmed correct — do not "fix" these:

- All 50 `ItemIcon` raw values map to real imagesets, including the ones with spaces and the `"sushi rool"` spelling.
- The `validItems` sort comparator in `Stock.swift:32` is a valid strict-weak ordering; undated items sort last as intended.
- `.onDelete` in `MyItems.swift:48` maps indices to objects *before* deleting, which is the index-safe order.
- `didLoadFromItem` in `Item.swift` correctly guards against `.onAppear` firing twice and clobbering in-progress edits.
- `ItemBarType.addOnly` / `.addRemove` / `.simple` are still preview-only. Kept on purpose — `.addRemove` is what the shopping list needs in Phase 2.
