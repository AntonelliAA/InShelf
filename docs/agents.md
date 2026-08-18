# Working with AI Agents on InShelf

Two things live here: how to give an agent good context on this repo, and when fanning out to subagents is actually worth it.

## The context layer

| File | Audience | Contains |
|---|---|---|
| `README.md` | Humans | What the app is, how to run it |
| `AGENTS.md` | Any coding agent | Commands, conventions, boundaries, done-criteria |
| `docs/architecture.md` | Both | Data flow, model, design tokens |
| `docs/known-issues.md` | Both | Open defects with file:line |
| `docs/roadmap.md` | Both | What to build and in what order |

`AGENTS.md` is the entry point. It is an open format donated to the Linux Foundation's Agentic AI Foundation in December 2025 and read by Claude Code, Codex, Cursor, Copilot, Gemini CLI, Zed, Aider, and around twenty other tools — so one file covers whatever the user happens to be running. The convention is to keep it under ~150 lines and treat it like source: review changes to it, and update it in the same commit that introduces a new convention.

The split that matters: `README.md` explains the project, `AGENTS.md` constrains the agent. Instructions that only an agent needs ("never hardcode a color", "there is no test target, do not claim tests pass") belong in `AGENTS.md`, not in the README where they read as noise to a human.

### Keeping it honest

Documentation that drifts is worse than none, because an agent trusts it. Two rules:

- Every claim in `AGENTS.md` and `architecture.md` should be checkable against the code in under a minute. No aspirational statements.
- `known-issues.md` is a ledger. Fixing an issue means deleting its entry, not marking it done.

### Sharing agent config

`.gitignore` excludes `.claude/*` but un-ignores `.claude/agents/`, so the subagent below travels with the repo while local settings and caches stay out. Anything that should work for every clone belongs in `AGENTS.md` regardless — it is committed and portable across every tool, not just Claude Code.

## When to use subagents

Anthropic's published results for orchestrator-worker systems are a ~90% improvement over single-agent on research-style tasks — at roughly **15× the token cost**. That trade only pays when the work is genuinely parallel and exceeds one context window.

InShelf is 1100 lines across 16 files. **The entire codebase fits in a single context window.** For most work here, one agent that has read everything beats four agents that each read a quarter and have to reconcile. Fanning out on this repo is usually a way to spend 15× for a worse answer.

### Where it does pay

Two cases, both real for this project:

**Independent, non-overlapping edits.** Phase 0 has five fixes in four different files with no shared state. That is a legitimate fan-out: one agent per fix, each with an explicit file scope. The test is whether two agents could touch the same lines — if yes, do it sequentially.

**Breadth-first research.** "How do other pantry apps handle expiry notifications?" or "compare VisionKit's DataScanner against AVFoundation for barcode scanning" — these are searches, not edits, and parallel searches genuinely beat serial ones.

### Where it does not

- Anything touching `StockItem` or `ExpiryStatus`. Every screen reads them; parallel agents will conflict.
- Design work. Visual consistency needs one pair of eyes on the whole surface.
- Debugging. Reproduce first, in one context, with the full picture. Splitting a bug hunt across agents multiplies wrong theories.

### Effort scaling

The heuristic from Anthropic's own guidance, applied here:

| Task | Shape |
|---|---|
| Single fact, single file | No subagent. Just do it. |
| One feature, one screen | One agent, full context |
| 2–4 independent fixes | One agent each, explicit file scope |
| Broad research | 2–4 agents, each on a distinct angle |

If you cannot name what each agent will do differently from the others, you need one agent, not three.

## Writing a task for a subagent

The single biggest failure mode is a vague brief. "Fix the light mode bug" produces an agent that guesses at scope, duplicates work another agent is doing, or stops early. Every delegation needs four things:

1. **Objective** — the specific outcome, not the topic
2. **Scope** — which files it may touch, and which it may not
3. **Output** — what it should hand back (a diff? a report? a list?)
4. **Boundaries** — what "done" means and where to stop

A good brief for this repo:

> Fix issue #1 in `docs/known-issues.md`. Replace every hardcoded `.white` and `.gray` foreground color in `InShelf/Components/ItemBar.swift` and `InShelf/Components/FeaturedCardView.swift` with the semantic asset-catalog tokens (`.labelPrimary` for primary text, `.labelSecondary` for secondary). Do not touch any other file. Do not change layout, spacing, or the enum shape. When done, report the list of lines changed and confirm the project still builds with `xcodebuild -scheme InShelf -destination 'generic/platform=iOS Simulator' build`.

A bad one: *"make light mode work"*.

Note what the good version does: it hands the agent the *conclusion* of the investigation, not the investigation. The orchestrator already read the code — making the subagent rediscover that is the 15× cost with none of the benefit.

## The project subagent

One custom agent is defined in `.claude/agents/`:

**`swift-reviewer`** — reviews SwiftUI/SwiftData changes against this project's specific failure modes: hardcoded colors, hardcoded widths, magic-string state, locale pinning, and SwiftData schema hazards. These are the classes of bug the full-source review actually found, so they are the ones worth automating.

There is deliberately only one. Generic agents for exploration, planning, and general review already ship with the tooling; adding project-specific copies of them would be duplication that drifts. The reviewer earns its place because it encodes knowledge that exists nowhere else — the recurring mistakes this particular codebase makes.

## Sources

- [AGENTS.md specification](https://agents.md/)
- [Anthropic — How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Best Practices for Multi-Agent Orchestration with Claude](https://github.com/anthropics/anthropic-sdk-python/discussions/1313)
