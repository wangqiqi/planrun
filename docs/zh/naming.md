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

## DSH `/plan` vs PlanRun `sprint-plan`

两者都在"规划"，但层级不同，不是二选一：

| | DSH `/plan` | PlanRun `sprint-plan` |
|---|---|---|
| 范围 | 单任务，会话内设计 | 多任务 Sprint，跨会话 |
| 产物 | 通过 `exit_plan_mode` 批准的方案 | `.dsh/growth/plan.md`（HTML meta + TASK 表） |
| 闸门 | plan mode 自身策略 | `gate-check` · `plan-check` · `PLAN_APPROVED` |
| 自主推进 | 无 | `AUTONOMOUS:true` 驱动的链式推进 |

命名不冲突：PlanRun 的规划 skill 叫 **`sprint-plan`**；skill 与宿主命令共用 `/` 面板，而同名时 DSH **优先解析为宿主命令**——所以将来即使撞名，也是该 skill 被遮蔽而不是报错。plan mode 生效期间，PlanRun 的自主链会主动让位（见 [workflow-hooks-map.md](workflow-hooks-map.md)）。

## npm 包

- `@planrun/skill-provider` — bundled skills Cordis plugin  
- `@planrun/bundle` — profile bundle（目录 `packages/bundle-planrun/`）

## Bundled skills（28）

`master` · `sprint-plan` · `run` · `review` · `learn` · `git` · `scaffold` · `long` · `release` · `delivery` · `debug` · `test` · `security` · `api` · `refactor` · `perf` · `mcp` · `study` · `user-manual` · `test-report` · `ux` · `ia` · `week` · `disk` · `maintain` · `code-stats-viz` · `pencil-design` · `md2docx-export`

## Personas（12）

`@planrun/skill-provider/config/roles.json` · 默认 `dashu` · 会话态 `.dsh/growth/session/persona.json`
