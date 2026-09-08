# Workflow guard（dsh-guard）

Super Cursor `runner.sh` 闸门的 DSH 替代 — bash + pnpm 脚本，**不依赖** Cordis plugin。

实现：`scripts/dsh-guard.sh` + `scripts/plan-parse.sh`（解析 plan HTML 元数据与 TASK 表）。

## 命令

| 命令 | 作用 |
|------|------|
| `pnpm run gate-check` | **`run` 前硬闸门**（`PLANNING` / `PLAN_APPROVED`） |
| `pnpm run plan-check` | handoff 结构告警（ACTIVE、执行顺序、VERIFY…） |
| `pnpm run task-verify` | 跑当前 ACTIVE 任务验收 |
| `pnpm run next-task` | 按执行顺序取下一待办 TASK id |
| `pnpm run guard` | 状态摘要 |
| `pnpm run verify` | 全量结构验收（`verify-planrun.sh`） |

```sh
bash scripts/dsh-guard.sh gate-check
bash scripts/dsh-guard.sh task-verify TASK-001
```

## plan 路径解析

1. `DSH_GROWTH_PLAN` — 显式路径  
2. 从 **当前 cwd** 向上找 `.dsh/growth/plan.md` 或 `.cursorGrowth/plan.md`  
3. 回退：PlanRun 本仓根（含 `scripts/` 时）

目标项目：跑 `install-planrun.sh` 复制 guard 到 `scripts/` 并合并 `package.json` scripts。

## HTML 元数据（SSOT）

| 键 | 含义 |
|----|------|
| `PLANNING` | `true` → 禁止 run |
| `PLAN_APPROVED` | 日期字符串 — gate-check 必需 |
| `SPRINT` | Sprint id |
| `SPRINT_STATUS` | `active` \| `closed` |
| `ACTIVE` | 当前 TASK |
| `NEXT` | 建议下一 TASK |
| `LAST_DONE` | 上一完成 TASK |
| `AUTONOMOUS` | `true` → 同会话 Sprint 连跑 |
| `VERIFY` | 全量 verify 命令 |
| `MAX_LOOPS` | 自治循环上限（默认 15） |

模板：[templates/growth/plan.md](../../templates/growth/plan.md)

## TASK 表

列：ID · Task · Priority · Status · Acceptance · Target

- **Status**：`⬜` · `🔧` · `✅`
- **Acceptance**：优先可执行命令；描述性验收 → 启发式回退（`DSH_GUARD_FALLBACK_VERIFY`）

## 环境变量

| 变量 | 默认 | 含义 |
|------|------|------|
| `DSH_GROWTH_PLAN` | — | 覆盖 plan 路径 |
| `DSH_GUARD_HEURISTICS` | `true` | 描述性验收时回退 |
| `DSH_GUARD_FALLBACK_VERIFY` | `./scripts/verify-planrun.sh` | 回退脚本 |

## 对照 Super Cursor

| Super Cursor | PlanRun guard |
|--------------|----------------|
| `.cursor/bin/runner.sh` | `scripts/dsh-guard.sh` |
| `.cursor/config/workflow.json` | env + plan HTML meta |
| `.cursorGrowth/plan.md` | `.dsh/growth/plan.md` |

`@planrun/workflow` 可注入会话 hook；**未挂载 plugin 时 guard 脚本仍是可移植基线**。

## 相关 skills

- **`sprint-plan`** — 写 plan + 元数据  
- **`run`** — 编码前 `gate-check`；✅ 前 `task-verify`

见 [mapping-from-super-cursor.md](mapping-from-super-cursor.md)。
