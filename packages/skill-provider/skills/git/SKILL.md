---
name: git
description: >-
  Git — branches, commits, merge. Use when git operations are needed in a DSH
  session. Links harness pre-push checks when working in deepseek-harness.
disable-model-invocation: true
user-invocable: true
---

# git

Branches: `feat/*` · `fix/*` · `chore/*` · `docs/*`  
Format: `type(scope): summary` (scope optional)

## Conventional Commits

```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

| type | Use | SemVer |
|------|-----|--------|
| `feat` | new feature | MINOR |
| `fix` | bug fix | PATCH |
| `docs` · `style` · `refactor` · `perf` · `test` · `build` · `ci` · `chore` | non-feature | usually none |
| `BREAKING CHANGE:` footer or `type!:` | breaking change | MAJOR |

- One logical change per commit; body explains **why**
- scope = affected module (e.g. `feat(api): …`)

## Before commit

- [ ] `git status` — no `.env`, secrets, accidental large files; **do not** stage `.dsh/growth/plan.md` or growth tree (gitignored)
- [ ] `git diff --stat` — scope matches current TASK
- [ ] project verify for the task (e.g. `pnpm run verify`, `./scripts/verify.sh`)
- [ ] in **deepseek-harness**: follow [dsh-pre-push-checks](https://github.com/deepseek-ai/deepseek-harness/blob/main/.agents/skills/dsh-pre-push-checks/SKILL.md) before push
- [ ] `CHANGELOG [Unreleased]` updated for user-visible changes (if any)
- [ ] message references plan task ID (e.g. `fix(bundle): profile install (TASK-002)`)

## Auto-commit with run

When **`run`** is active: each TASK ✅ and Sprint closeout require **commit in the same turn**; do not leave commits to the user unless working tree is clean.

**`.dsh/growth/plan.md`** is local-only (gitignored). Commits include tracked code, CHANGELOG, README — not growth mirror files.

## Branch and merge

- Short-lived feature branches; **no force-push** to shared/default branches unless user explicitly asks
- Before merge: local verify green · no WIP commits
- UI/feature PR: **`delivery`** (v0.2+) recommended before ship
- Protected branches: PR + review per team policy

## GitHub ops (`gh` when available)

| Scenario | Typical action |
|----------|----------------|
| Issue triage | `gh issue list` · `gh issue view` |
| PR status | `gh pr checks` · `gh run view` |
| Release | `gh release create` — align with **`release`** (v0.2+) and CHANGELOG |

## Forbidden (unless user explicit)

- `git push --force` to shared/default branch
- `git reset --hard` · `git clean -fdx`
- `--no-verify` / `--no-gpg-sign`

## Release

Checklist → **`release`** skill (v0.2+). Tag rules → project `CHANGELOG` / team convention.

## Worktree isolation (optional)

```bash
git worktree add ../repo-feature-<name> -b feat/<name>
git worktree list
git worktree remove <path>   # no uncommitted changes · user confirms
```
