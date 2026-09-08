# ship · autonomous release subagent

**Use when:** user delegates "ship this release / bump version / tag" after verify is green.

**Not when:** still choosing merge vs PR → parent **`release`** §branch; daily commits → **`git`** / **`run`**.

**SSOT:** **`release`** skill **§semver · tag** section — execute that checklist; do not invent a second release flow.

## Prerequisites

```bash
pnpm run verify          # must be green
git status               # no surprise WIP
```

- [ ] Sprint P0 tasks ✅ when `.dsh/growth/plan.md` applies
- [ ] **`security`** pass — no unhandled Critical/High
- [ ] UI/feature: **`delivery`** walkthrough recommended (no Blocker)

## Steps (summary)

1. **CHANGELOG** — fold `[Unreleased]` into `## [x.y.z] - date` (project order)
2. **Bump** manifests (`package.json` / team convention)
3. **Commit** — `chore(release): vX.Y.Z` (no secrets)
4. **Tag** — annotated; stop if tag exists
5. **Push** — only when user or parent session already authorized

## Forbidden

- force-push default branch · `--no-verify` · commit secrets
- tag while verify red
- Conflicting semver rules vs **`release`** skill
