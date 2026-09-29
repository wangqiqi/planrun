# Naming conventions

| Super Cursor | PlanRun | Notes |
|---|---|---|
| `plan` skill | **`sprint-plan`** | Avoid clash with DSH `/plan` plan mode |
| `/plan` slash | DSH **`/plan`** | Plan mode — explore then `exit_plan_mode` |
| Load sprint planning | **`sprint-plan` skill** | User slash `/sprint-plan` where supported |
| `.cursorGrowth/` | **`.dsh/growth/`** | Project-local, usually gitignored |
| `AskQuestion` | **`ask_user_question`** | DSH interaction tool |
| `rules/*.mdc` | **`docs/en/discipline.md`** + skills | No glob rule engine in v0.1 |
| `install-super-cursor.sh` | **`install-planrun.sh`** | |
| `SUPER_CURSOR_HOME` | **`PLANRUN_HOME`** | Path to this repo |

## DSH `/plan` vs PlanRun `sprint-plan`

Both plan, at different scopes — they are not alternatives to each other:

| | DSH `/plan` | PlanRun `sprint-plan` |
|---|---|---|
| Scope | one task, designed in-session | multi-task Sprint across sessions |
| Artifact | the plan you approve through `exit_plan_mode` | `.dsh/growth/plan.md` (HTML meta + TASK table) |
| Gate | plan mode's own policy | `gate-check` · `plan-check` · `PLAN_APPROVED` |
| Autonomous nudge | none | the chain driven by `AUTONOMOUS:true` |

There is no name clash: PlanRun's planning skill is **`sprint-plan`**, and skills share the `/`
palette with host commands — where DSH resolves a shared `/name` to the **host command first**,
so a future collision would shadow the skill rather than crash. While plan mode is in force,
PlanRun's autonomous chain stands down (see [workflow-hooks-map.md](workflow-hooks-map.md)).

## Package scope

- `@planrun/skill-provider` — bundled skills Cordis plugin
- `@planrun/bundle` — profile bundle patch (directory `packages/bundle-planrun/`)

## Bundled skills (28)

`master` · `sprint-plan` · `run` · `review` · `learn` · `git` · `scaffold` · `long` · `release` · `delivery` · `debug` · `test` · `security` · `api` · `refactor` · `perf` · `mcp` · `study` · `user-manual` · `test-report` · `ux` · `ia` · `week` · `disk` · `maintain` · `code-stats-viz` · `pencil-design` · `md2docx-export`

## Personas (12)

`config/roles.json` in `@planrun/skill-provider` · default `dashu` · session state `.dsh/growth/session/persona.json`
