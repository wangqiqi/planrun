# PlanRun workflow hooks 映射

Super Cursor `hooks.json` → DSH Cordis 扩展点（**`@planrun/workflow`**）。

| Super Cursor | DSH 事件 | 处理 | 行为 |
|--------------|----------|------|------|
| `beforeSubmitPrompt` → `growth-init.sh` | `agent/pre-step` | `ensureGrowth()` | 幂等种子 `.dsh/growth/` |
| `sessionStart` → `run-start.sh` | `agent/created` | `buildRunStartContext()` + Persona | 注入 plan 闸门 / ACTIVE / Persona hint |
| `stop` → `run-stop.sh` | `agent/turn-stopping` | `buildRunStopSteer()` | `AUTONOMOUS:true` 时 steer 下一 TASK |

> DSH 已于 2026-09-09 把该 hook 从 `agent/session-start` 改名为 `agent/created`（commit `9b7a8ccc9f`）。旧事件名永远不会触发，监听它只会静默失效——请保持本表与 `packages/workflow/src/index.ts` 一致。

## DSH plan mode 优先

当 `ctx.planMode` 报告 `active`（或 `/plan` 选择尚处 pending）时，PlanRun 主动让位：`agent/created` 注入「paused for DSH plan mode」而非 AUTONOMOUS 链，`agent/turn-stopping` 不再 steer。plan mode 的语义是「只探索、只规划」，而自主链是「实现并提交」——同一轮里两者并存会让模型与 plan-mode 策略互相打架。退出 plan mode（`exit_plan_mode` 或 `/plan off`）后，自主链会自动恢复。覆盖测试见 `packages/workflow/tests/workflow.test.mjs`。

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
