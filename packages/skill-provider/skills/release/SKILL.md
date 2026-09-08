---
name: release
description: >-
  Sprint exit (/release): branch merge/PR/keep/discard, semver, CHANGELOG, tag.
  Use when shipping, merging, opening PR, or tagging. Not a Sprint Goal by itself.
disable-model-invocation: true
user-invocable: true
---

# release · Sprint exit

**用这个**：Sprint/Task 已绿、**`run`** 已归档后，人主导分支收尾与打版。**不是那个**：能力交付本身 → **`sprint-plan`** + **`run`**；日常 commit → **`git`** skill。

Standing discipline: [docs/en/discipline.md](../../../docs/en/discipline.md)

After code is green and `.dsh/growth/archive/` notes exist: **merge to mainline, then tag** (if shipping).

```bash
pnpm run verify          # planrun repo
git status && git diff --stat
```

v1.1: `@planrun/workflow` may add guard hooks; until then use project verify + explicit user confirm for tag/push.

## Branch closeout (merge / PR)

### Prerequisites

- [ ] Current ACTIVE or Sprint P0 tasks ✅ (or user only wants branch cleanup)
- [ ] verify commands actually run
- [ ] no secrets · no accidental large files
- [ ] **UI/feature Sprint**: **`delivery`** recommended first; report **Blockers** before `ask_user_question`

### Flow

**Verify** → **(recommended) delivery** → **`ask_user_question` (4 choices)** → **execute** → optional worktree cleanup (see **`git`**)

| # | Option | Action |
|---|--------|--------|
| 1 | Local merge | checkout base · merge feature · verify · delete local feature (after confirm) |
| 2 | Push + PR | `git push -u origin HEAD` · `gh pr create` (Summary + Test plan · TASK IDs) |
| 3 | Keep branch | push or leave; no merge |
| 4 | Discard | **explicit user confirmation**; no silent force/reset |

Detached HEAD: offer options 2–4 only.

### With run

| When | run | release §branch |
|------|-----|-----------------|
| single TASK ✅ | ✅ | |
| Sprint all ✅ · archive | ✅ | optional **§branch** next |
| merge / PR / discard | | ✅ |

### Forbidden

- force-push shared/default branch (unless user explicit)
- `reset --hard` · `clean -fdx` without confirm
- merge without verify

---

## Shipping (semver · tag)

When mainline is green and users need a version bump.

### Version bump guide

| Level | When | Auto? |
|-------|------|-------|
| **patch** | fixes, docs, single TASK | manual `git tag` |
| **minor** | user-visible feature, no breaking | user decides |
| **major** | breaking change | user decides |

### planrun repo checklist

- [ ] `pnpm run build && pnpm run verify` green
- [ ] `CHANGELOG.md` — fold `[Unreleased]` into `## [x.y.z] - date`
- [ ] `README.md` aligned with CHANGELOG (skill list, roadmap)
- [ ] **security** skim if auth/PII touched
- [ ] **UI/feature**: **`delivery`** no Blocker (recommended)
- [ ] annotated tag on CHANGELOG commit:

```bash
git tag -a v0.2.0 -m "Release 0.2.0: <summary>"
git push origin v0.2.0   # only when user asks
```

### deepseek-harness

Follow root `AGENTS.md` and [dsh-pre-push-checks](https://github.com/deepseek-ai/deepseek-harness/blob/main/.agents/skills/dsh-pre-push-checks/SKILL.md) before push.

### Follow-up release density

- cluster patches on same symptom → note root Sprint in CHANGELOG
- prefer one minor over many patches when UX-only follow-ups stack up

## Not a Sprint

「打版 / 打 tag / merge only」is **not** a Sprint Goal — see **`sprint-plan`** goal gate. Deliver capability first, **`release`** as exit.

## Delegation (ship subagent)

When user delegates autonomous release and **planrun** preset delegation tools are available:

```
subagent_ship(
  label: "release v1.6.0",
  prompt: "Load release skill. Run pnpm run verify, update CHANGELOG, bump to 1.6.0, tag if user already approved push.",
  run_in_background: true
)
```

Or switch session preset to **planrun-ship** for a dedicated release thread. SSOT remains this skill §semver/tag — see `agents/ship.md` in skill-provider.
