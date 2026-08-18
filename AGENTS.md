# AGENTS.md

Instructions for AI coding agents working on InShelf. Human-facing overview lives in [README.md](README.md); deeper context in [docs/](docs/).

## Project

InShelf is a single-target iOS app (SwiftUI + SwiftData) for tracking pantry items and expiration dates. Offline-only, no backend, no third-party dependencies. Solo-maintained.

- Target: iOS 18.5+, Swift 5.0, Xcode 16+
- Bundle ID: `br.academy.InShelf`
- ~1100 lines of Swift across 16 files

## Commands

```bash
# Build
xcodebuild -scheme InShelf -destination 'generic/platform=iOS Simulator' build

# Test (needs a booted-able simulator, not a generic destination)
xcodebuild test -scheme InShelf -destination 'platform=iOS Simulator,name=iPhone 17'

# Open in Xcode (preferred for UI work — SwiftUI previews are the fast loop)
open InShelf.xcodeproj
```

If `iPhone 17` does not exist locally, `xcodebuild -list` and `xcrun simctl list devices available` show what does. CI picks a simulator dynamically for this reason — see [.github/workflows/ci.yml](.github/workflows/ci.yml).

Tests live in `InShelfTests/` and use Swift Testing (`@Test` / `#expect`), not XCTest. Both `InShelf/` and `InShelfTests/` are file-system-synchronized folders: adding or deleting a `.swift` file there needs no `project.pbxproj` edit, and anything with a `.swift` extension inside them is compiled.

## Layout

| Path | Contains |
|---|---|
| `InShelf/App/` | Entry point, `TabBar`, `Assets.xcassets` |
| `InShelf/Models/` | `StockItem` (@Model) + presentation enums |
| `InShelf/Screens/` | One file per screen, named after the screen |
| `InShelf/Components/` | Reusable views |

Full data flow and design tokens: [docs/architecture.md](docs/architecture.md).

## Conventions

- **Colors come from the asset catalog, never literals.** Use `.labelPrimary`, `.backgroundSecondary`, `.redPrimary`, etc. via the generated `ShapeStyle` accessors — not `.white`, `.gray`, or `Color("RedSecondary")` string lookups.
- **Both color schemes must work.** The app does not force dark mode; `#Preview` blocks using `.preferredColorScheme(.dark)` hide light-mode bugs. Preview both.
- **Enums over magic strings.** `ItemIcon`, `UnitType`, and `ItemPurchaseState` are `String`-backed enums; follow that pattern. Read purchase state through `StockItem.state`, never `stateRaw`.
- **No fixed widths.** Use `.frame(maxWidth: .infinity)` + padding. Card images are `.resizable().scaledToFit()` so they follow their container.
- **Expiry logic belongs in `ExpiryStatus`.** Do not compare dates for expiry anywhere else, and keep that file free of SwiftUI and SwiftData so its check stays runnable.
- **Never hardcode a locale.** `Item.swift` pins the DatePicker to `pt_BR`; that is a bug. Use the device locale.
- SwiftData writes go through `@Environment(\.modelContext)`. Reads go through `@Query`. There is no repository layer and none is wanted at this size.

## Boundaries

- Do not add third-party dependencies (SPM, CocoaPods). The app ships zero and should stay that way unless the user explicitly asks.
- Do not restructure directories or rename types without being asked.
- `InShelf.xcodeproj/project.pbxproj` is machine-generated — edit through Xcode, not by hand.
- Assets in `Assets.xcassets` were exported from Figma. Do not regenerate or rename imagesets; `ItemIcon` raw values depend on their exact names (including spaces, e.g. `"hot dog"`).
- `.claude/agents/` is version-controlled and shared; the rest of `.claude/` is local-only.

## Git

Commits are one capitalized imperative sentence, no `feat:`/`fix:` prefix. Branches are short-lived kebab-case. Full rules — including the PR template and release format — in [docs/git-conventions.md](docs/git-conventions.md). Do not commit or push unless asked.

## Before you claim done

1. The change builds and `xcodebuild test` passes. Run them — do not assume.
2. Any new view was checked in **both** light and dark schemes.
3. You did not introduce a new hardcoded color, width, or locale.
4. Known issues you touched are updated in [docs/known-issues.md](docs/known-issues.md).

## Working with a plan

Read [docs/roadmap.md](docs/roadmap.md) before proposing new features — most obvious gaps are already sequenced, and the ordering exists because early phases make later ones cheap. For fan-out work and subagent usage, see [docs/agents.md](docs/agents.md).
