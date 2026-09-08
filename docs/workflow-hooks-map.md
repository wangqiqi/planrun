# PlanRun workflow hooks map

Super Cursor `hooks.json` → DSH Cordis extension points via **`@planrun/workflow`**.

| Super Cursor | DSH event (`@planrun/workflow`) | Handler | Behavior |
|---|---|---|---|
| `beforeSubmitPrompt` → `growth-init.sh` | `agent/pre-step` | `ensureGrowth()` | Idempotent `.dsh/growth/` seed from `templates/growth` |
| `sessionStart` → `run-start.sh` | `agent/session-start` | `buildRunStartContext()` | Inject plan gate / ACTIVE / AUTONOMOUS hint |
| `stop` → `run-stop.sh` | `agent/turn-stopping` | `buildRunStopSteer()` | `agent.steer()` next TASK when `AUTONOMOUS:true` |

## Plan file resolution (same as `dsh-guard.sh`)

1. `DSH_GROWTH_PLAN` env (absolute path)
2. `<cwd>/.dsh/growth/plan.md`
3. `<cwd>/.cursorGrowth/plan.md` (PlanRun mother-repo dev)

## Growth templates

`PLANRUN_HOME` or package-relative repo root → `templates/growth/`.

## Portable baseline

`scripts/dsh-guard.sh` remains the CLI gate when the workflow plugin is not mounted.

## Related

- `docs/workflow-guard.md` — guard commands
- `.cursor/skills/plan/reference/autonomy-chain.md` — AUTONOMOUS followup matrix (Super Cursor mother)
