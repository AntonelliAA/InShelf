# Git Conventions

How commits, branches, and pull requests are written in this repo. Applies to humans and agents equally.

## Commits

One capitalized, imperative sentence in English. No type prefix, no scope, no trailing period.

```
Add create-release! function to support GitHub releases
Don't error on mismatches when actual value is nil
Fix branch name error with special char
Bump dependencies
Remove timbre dependency
```

**Not** `feat:`, `fix:`, `chore:`. Conventional Commits is deliberately not used here — the type prefix duplicates what the sentence already says and adds a vocabulary to argue about. Write what changed.

Rules:

- Imperative mood — "Add", not "Added" or "Adds". The subject completes *"this commit will …"*.
- Capitalize the first word. Everything else follows normal sentence case; code identifiers keep their own casing.
- Subject under ~72 characters. If it does not fit, the commit is probably two commits.
- A body is optional and usually unnecessary. Use it when *why* is not obvious from *what* — separated by a blank line, wrapped at 72 columns.
- One concern per commit. Mixed commits are the reason `git log` stops being useful.
- When a commit closes an issue, reference it in the body: `Closes #12`.

When a pull request is squash-merged, the resulting subject carries the PR number automatically:

```
Add create-release! function to support GitHub releases (#38)
```

Do not type that suffix by hand on direct commits.

## Branches

Short-lived, kebab-case, descriptive of the change. No mandatory type prefix.

```
add-license-to-pom-file
prune-dependencies
fix-namespaced-symbols-bug
create-deep-equals-matcher
bump-deps
```

Two accepted variants when they help:

- **Author prefix** when several people work in parallel — `als/optional-expiry-date`
- **Ticket prefix** when the work tracks an external ID — `IS-42-shopping-list`

Branch off `main`, keep the branch alive for hours or days, not weeks, and delete it after merge. Long-running branches are how merge conflicts get expensive. `main` is always releasable.

## Pull requests

Use [.github/pull_request_template.md](../.github/pull_request_template.md). The two sections that carry the most weight are the ones reviewers actually need and rarely get:

- **Where should the reviewer start?** — a diff is not self-navigating. Name the file and the reason.
- **Remaining problems or questions** — what this PR knowingly does *not* solve. Stating it beats a reviewer discovering it.

The status marker exists so a PR can be opened early without ambiguity about whether it is mergeable:

| Status | Meaning |
|---|---|
| `IN DEVELOPMENT` | Active work in the branch, do not merge |
| `HOLD` | Work is done, but something else must land first |
| `READY` | Merge it |

Before requesting review: discuss non-trivial changes in an issue first, make sure the project builds, and update the docs the change invalidates in the *same* PR.

Squash-merge into `main`. The branch's messy intermediate commits are working state; the squashed subject is the permanent record.

## Releases

Versions follow [semver](https://semver.org/). The narrative of a release lives in `CHANGELOG.md`, not in commit bodies:

```markdown
## 1.2.0 / 2026-08-18
- Expiration dates are now optional; items saved without one no longer expire
- Fix unreadable item rows in Light Mode
```

Newest version first, `## X.Y.Z / YYYY-MM-DD` heading, plain bullets. Version bumps are their own commit.

**This repo has no CHANGELOG yet** — start it at the first build that reaches a device someone else owns. Before that there is nothing to communicate and it would only rot.
