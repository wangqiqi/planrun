# PlanRun workflow hooks 映射

Super Cursor `hooks.json` → DSH Cordis 扩展点（**`@planrun/workflow`**）。

| Super Cursor | DSH 事件 | 处理 | 行为 |
|--------------|----------|------|------|
| `beforeSubmitPrompt` → `growth-init.sh` | `agent/pre-step` | `ensureGrowth()` | 幂等种子 `.dsh/growth/` |
| `sessionStart` → `run-start.sh` | `agent/session-start` | `buildRunStartContext()` + Persona | 注入 plan 闸门 / ACTIVE / Persona hint |
| `stop` → `run-stop.sh` | `agent/turn-stopping` | `buildRunStopSteer()` | `AUTONOMOUS:true` 时 steer 下一 TASK |

## plan 路径（同 dsh-guard）

1. `DSH_GROWTH_PLAN`  
2. `<cwd>/.dsh/growth/plan.md`  
3. `<cwd>/.cursorGrowth/plan.md`（本仓开发）

## Growth 模板

`PLANRUN_HOME` 或包相对路径 → `templates/growth/`。

## 可移植基线

未挂载 workflow plugin 时，仍用 `scripts/dsh-guard.sh` CLI 闸门。

## 相关

- [workflow-guard.md](workflow-guard.md) — guard 命令  
- Super Cursor 母版 `autonomy-chain.md` — AUTONOMOUS 矩阵
