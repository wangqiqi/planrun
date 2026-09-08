# Naming conventions

| Super Cursor | planrun | Notes |
|---|---|---|
| `plan` skill | **`sprint-plan`** | Avoid clash with DSH `/plan` plan mode |
| `/plan` slash | DSH **`/plan`** | Plan mode — explore then `exit_plan_mode` |
| Load sprint planning | **`sprint-plan` skill** | User slash `/sprint-plan` where supported |
| `.cursorGrowth/` | **`.dsh/growth/`** | Project-local, usually gitignored |
| `AskQuestion` | **`ask_user_question`** | DSH interaction tool |
| `rules/*.mdc` | **`docs/discipline.md`** + skills | No glob rule engine in v0.1 |
| `install-super-cursor.sh` | **`install-planrun.sh`** | |
| `SUPER_CURSOR_HOME` | **`PLANRUN_HOME`** | Path to this repo |

## Package scope

- `@planrun/skill-provider` — bundled skills Cordis plugin
- `@planrun/bundle-planrun` — profile bundle patch

## Skill IDs (kebab-case)

Bundled (v0.2): `master`, `sprint-plan`, `run`, `review`, `learn`, `git`, `scaffold`, `long`, `release`, `delivery`, `debug`, `test`
