---
name: run
description: >-
  Execute ACTIVE tasks from .dsh/growth/plan.md for planrun. Implement, verify,
  update plan mirror, commit per task. Load after sprint-plan approval. Sprint
  finish may hand off to release (v0.2).
disable-model-invocation: true
user-invocable: true
---

# run

**Daily loop:** `sprint-plan` breaks work down → **`run`** implements → **`release`** (v0.2) ships.

Read `.dsh/growth/learn/` when present. Discipline: [docs/discipline.md](../../../docs/discipline.md)

**Persona**: default `dashu`; user may summon via **master** §人格·呼叫. Voice changes only — never skip verify or gate-check for tone.

## Before coding

```sh
pnpm run gate-check    # BLOCK → sprint-plan or fix plan metadata
```

1. Read `.dsh/growth/plan.md` — `<!-- ACTIVE: ... -->` or ACTIVE table row.
2. If no ACTIVE or gate failures → load **`sprint-plan`** first.
3. Run task verify **before** marking DONE:

```sh
pnpm run task-verify          # current ACTIVE
pnpm run task-verify TASK-001 # explicit id
```

Guard reference: [docs/workflow-guard.md](../../../docs/workflow-guard.md)

## Per-task loop

```
ACTIVE → implement → pnpm run task-verify → update plan.md → git commit → next ACTIVE
```

| Step | Rule |
|---|---|
| Verify | `pnpm run task-verify` must pass before ✅ |
| Next | `pnpm run next-task` after ✅ (or read `<!-- NEXT: ... -->`) |
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

## Autonomous Sprint

When `<!-- AUTONOMOUS: true -->` in plan.md and user asked for full Sprint execution:

- Continue to next `pnpm run next-task` in the **same session** after each TASK ✅ + commit
- Only interrupt on decisions listed in plan or scope expansion (`⚠️` → **`sprint-plan`**)

Cordis `@planrun/workflow` plugin provides session hooks (growth-init · run-start · run-stop); **guard scripts remain the portable baseline** when the plugin is not mounted.

## Closeout

When all TASKs are DONE: update CHANGELOG if user-visible, archive notes to `.dsh/growth/archive/`, load **`release`** (v0.2).
