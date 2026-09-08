---
name: run
description: >-
  Execute ACTIVE tasks from .dsh/growth/plan.md for dsh-super. Implement, verify,
  update plan mirror, commit per task. Load after sprint-plan approval. Sprint
  finish may hand off to release (v0.2).
disable-model-invocation: true
user-invocable: true
---

# run

**Daily loop:** `sprint-plan` breaks work down → **`run`** implements → **`release`** (v0.2) ships.

Read `.dsh/growth/learn/` when present. Discipline: [docs/discipline.md](../../../docs/discipline.md)

## Before coding

1. Read `.dsh/growth/plan.md` — find the `ACTIVE` row.
2. If no ACTIVE row or gate failures → load **`sprint-plan`** or fix blockers first.
3. Run the project's verify command for the task **before** marking DONE.

## Per-task loop

```
ACTIVE → implement → verify → update plan.md → git commit → next ACTIVE
```

| Step | Rule |
|---|---|
| Verify | Task verify must pass before ✅ |
| Commit | **Required** after each TASK/DOC/SPIKE ✅ (exclude plan.md-only edits) |
| Message | `type(scope): summary (TASK-001)` |
| plan.md only | Do **not** commit (`.dsh/growth/` is usually gitignored) |
| Push | Only when user asks or release flow |

## Scope boundaries

- Stay inside current TASK Target and Out of scope.
- New theme / architecture decision → mark `⚠️`, load **`sprint-plan`**.
- No drive-by refactors.

## Verify commands

Prefer project-native scripts:

| Project | Suggested |
|---|---|
| deepseek-harness | `pnpm run test` (focused), `pnpm run doc-sync` for docs |
| Generic | `package.json` scripts, `./scripts/test.sh` |

Use [dsh-pre-push-checks](https://github.com/deepseek-ai/deepseek-harness/blob/main/.agents/skills/dsh-pre-push-checks/SKILL.md) when working in deepseek-harness.

## Autonomous Sprint (v0.3)

Super Cursor `AUTONOMOUS:true` chain moves to `@dsh-super/workflow` plugin. Until then: continue to next ACTIVE in the same session when user asked for full Sprint execution.

## Closeout

When all TASKs are DONE: update CHANGELOG if user-visible, archive notes to `.dsh/growth/archive/`, load **`release`** (v0.2).
