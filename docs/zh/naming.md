# 命名与包坐标

| Super Cursor | PlanRun | 说明 |
|--------------|---------|------|
| `plan` skill | **`sprint-plan`** | 避免与 DSH `/plan` plan mode 冲突 |
| `/plan` slash | DSH **`/plan`** | 单任务方案设计 |
| 多任务规划 | **`sprint-plan` skill** | 用户可用 `/sprint-plan`（若支持） |
| `.cursorGrowth/` | **`.dsh/growth/`** | 项目本地，通常 gitignore |
| `AskQuestion` | **`ask_user_question`** | DSH 交互工具 |
| `rules/*.mdc` | **`docs/zh/discipline.md`** + skills | v0.1 无 glob rule 引擎 |
| `install-super-cursor.sh` | **`install-planrun.sh`** | |
| `SUPER_CURSOR_HOME` | **`PLANRUN_HOME`** | 本仓路径 |

## npm 包

- `@planrun/skill-provider` — bundled skills Cordis plugin  
- `@planrun/bundle` — profile bundle（目录 `packages/bundle-planrun/`）

## Bundled skills（28）

`master` · `sprint-plan` · `run` · `review` · `learn` · `git` · `scaffold` · `long` · `release` · `delivery` · `debug` · `test` · `security` · `api` · `refactor` · `perf` · `mcp` · `study` · `user-manual` · `test-report` · `ux` · `ia` · `week` · `disk` · `maintain` · `code-stats-viz` · `pencil-design` · `md2docx-export`

## Personas（12）

`@planrun/skill-provider/config/roles.json` · 默认 `dashu` · 会话态 `.dsh/growth/session/persona.json`
