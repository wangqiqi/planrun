# Workflow guard（dsh-guard）

Super Cursor `runner.sh` 闸门的 DSH 替代 — POSIX shell + pnpm 脚本，**不依赖** Cordis plugin。

实现：`scripts/dsh-guard.sh` + `scripts/plan-parse.sh`（解析 plan HTML 元数据与 TASK 表）；`doctor` 转发给 Node 模块 `scripts/planrun-doctor.mjs` + `scripts/planrun-manifest.mjs`。

## 命令

| 命令 | 作用 |
|------|------|
| `pnpm run gate-check` | **`run` 前硬闸门**（`PLANNING` / `PLAN_APPROVED`） |
| `pnpm run plan-check` | handoff 结构告警（ACTIVE、执行顺序、VERIFY…） |
| `pnpm run task-verify` | 跑当前 ACTIVE 任务验收 |
| `pnpm run next-task` | 按执行顺序取下一待办 TASK id |
| `pnpm run doctor` | 版本漂移体检 —— guard 脚本 · plan 模板 · `@planrun/*` 包版本 vs 版本清单 |
| `pnpm run guard` | 状态摘要 |
| `pnpm run verify` | 全量结构验收（`verify-planrun.sh`） |

```sh
bash scripts/dsh-guard.sh gate-check
bash scripts/dsh-guard.sh task-verify TASK-001
bash scripts/dsh-guard.sh doctor --json

# PATH 上没有 bash？用可移植启动器跑同样的脚本：
node scripts/run-bash.mjs scripts/dsh-guard.sh gate-check
```

## 版本漂移体检（`doctor`）

`install-planrun.sh` 会在 `.dsh/growth/.planrun-manifest.json` 落一份清单（PlanRun 版本 · guard sha256 · 模板 schema · 安装时间）。`doctor` 把它读回来，报四项检查：

| 检查 | 何时 FAIL |
|------|-----------|
| `manifest` | 清单缺失、不是合法 JSON、或 schema 与本构建不符 |
| `guard-files` | 受管 `scripts/*` 安装后被改动，或与参考副本不一致 |
| `plan-template` | 清单记录的模板 schema 落后于当前构建、`plan.md` 缺失、或缺核心 HTML meta |
| `packages` | 已装的 `planrun` / `@planrun/*` 版本互相不一致、与项目记录不一致、或落后于参考构建 |

退出码：**0** 无漂移 · **1** 有漂移（每条 FAIL 都给 `FIX:`）· **2** 无法判定（不是 PlanRun 项目）。没有参照物可比的检查一律 `SKIP`，绝不凭空报错 —— 包括 npm 通道尚未发布时。

参考副本解析顺序：`--expect-guard` → `--source` → `PLANRUN_HOME` → 清单里的 `planrunSource` → DSH profile 包。常用开关：`--json`（机器可读）、`--no-profile`（不扫 profile 包）、`--project <dir>`、`--reference-version x.y.z`。

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
- **一格一条命令**：`task-verify` 去掉反引号后把整格 `eval` 成**一条**命令。写单条命令，或 `bash -c 'a && b'`；写成 `cmd1 + cmd2` 会被当一条跑挂。
- **单元格禁裸竖线**：多一个字段就把位置列全部右移（`$5` 状态 · `$6` 验收 · `$7` 落点）。行字段数与表头不一致时，`plan-check` 硬 FAIL，`task-verify` **拒绝验收该行**而不是回退到启发式验证。`en|zh` 请写成 `{en,zh}`。

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
