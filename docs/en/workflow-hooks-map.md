# PlanRun workflow hooks map

Super Cursor `hooks.json` → DSH Cordis extension points via **`@planrun/workflow`**.

| Super Cursor | DSH event (`@planrun/workflow`) | Handler | Behavior |
|---|---|---|---|
| `beforeSubmitPrompt` → `growth-init.sh` | `agent/pre-step` | `ensureGrowth()` | Idempotent `.dsh/growth/` seed from `templates/growth` |
| `sessionStart` → `run-start.sh` | `agent/created` | `buildRunStartContext()` + `buildPersonaStartContext()` | Inject plan gate / ACTIVE / AUTONOMOUS + **Persona hint** |
| `stop` → `run-stop.sh` | `agent/turn-stopping` | `buildRunStopSteer()` | `agent.steer()` next TASK when `AUTONOMOUS:true` |

> DSH renamed this hook from `agent/session-start` to `agent/created` on 2026-09-09
> (commit `9b7a8ccc9f`). The old event name is never emitted, so a listener on it
> stays silent instead of failing — keep this table in sync with
> `packages/workflow/src/index.ts`.

## DSH plan mode wins

While `ctx.planMode` reports `active` — or a `/plan` selection is still pending — PlanRun stands
down: `agent/created` injects a "paused for DSH plan mode" block instead of the AUTONOMOUS
chain, and `agent/turn-stopping` does not steer. Plan mode means "explore and plan"; the
autonomous chain means "implement and commit". Running both inside one turn makes the model
fight the plan-mode policy. Leave plan mode (`exit_plan_mode` or `/plan off`) and the chain
resumes on its own. Covered by `packages/workflow/tests/workflow.test.mjs`.

## Plan file resolution (same as `dsh-guard.sh`)

1. `DSH_GROWTH_PLAN` env (absolute path)
2. `<cwd>/.dsh/growth/plan.md`
3. `<cwd>/.cursorGrowth/plan.md` (PlanRun mother-repo dev)

## Growth templates

`PLANRUN_HOME` or package-relative repo root → `templates/growth/`.

## Portable baseline

`scripts/dsh-guard.sh` remains the CLI gate when the workflow plugin is not mounted.

## Related

- `docs/en/workflow-guard.md` — guard commands
- `.cursor/skills/plan/reference/autonomy-chain.md` — AUTONOMOUS followup matrix (Super Cursor mother)
