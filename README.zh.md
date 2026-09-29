# PlanRun

[English](README.md) | **中文**

> **Plan once · Run with gates · Ship with receipts.**

把 [Super Cursor](https://github.com/wangqiqi/cursor-ai) 的 Agent 工作流 SOP 搬进 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) — **28** 个 workflow skill、**12** 人格、一套 profile bundle、项目级 `.dsh/growth/` 模板。不是 DSH fork，也不是 Cursor 插件。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](package.json)
[![文档](https://img.shields.io/badge/文档-znza.top%2Fplanrun-orange)](https://znza.top/planrun/zh/)
[![Node](https://img.shields.io/badge/node-%5E22.19%20%7C%20%3E%3D24-brightgreen)](package.json)
[![dsh-plugin](https://img.shields.io/badge/topic-dsh--plugin-181717?logo=github)](https://github.com/topics/dsh-plugin)
[![Harness](https://img.shields.io/badge/DeepSeek%20Harness-v0.1%20preview-orange)](https://github.com/deepseek-ai/deepseek-harness)

---

## 为什么用 PlanRun

在 Cursor 里用 `/plan` · `/run` · `/release` 跑 Sprint 的人，换到 DSH 后往往缺同一套**可审计、可验证**的流程约束。

PlanRun 填这个缝：

| 你得到 | 不是什么 |
|---|---|
| 28 个 bundled **skills** + **12 人格**（Cordis 插件挂载） | 不是 fork `deepseek-harness` |
| **`@planrun/bundle`** — `dsh plugin add @planrun/bundle` 一键进 profile | 不是 Cursor rules 复制粘贴 |
| **`.dsh/growth/`** — plan · learn · archive 项目本地镜像 | 不是替代 DSH 内置 `/plan` plan mode |

日常口诀：**一次 sprint-plan 批准 · 一次 run 连跑 · 决策才停 · verify 才勾 ✅**

**安装（任意用户）** → [docs/zh/install.md](docs/zh/install.md) · 快速上手 → [docs/zh/quickstart.md](docs/zh/quickstart.md) · **站点** → [znza.top/planrun/zh](https://znza.top/planrun/zh/)

---

## 谁适合用 PlanRun

| 情况 | 说明 |
|------|------|
| ✅ 已用 **DeepSeek Harness**，想要 plan → run → verify → release 纪律 | `@planrun/bundle` 挂载即可 |
| ✅ 想要 **28 个 skill** + **12 人格**，不想手抄 `.cursor/` | Cordis 插件 + growth 模板 |
| ⚠️ **只用 Cursor**、没有 DSH | 用 **Super Cursor** 装目标项目 `.cursor/` — 见 [install.md](docs/zh/install.md) 路径 C |
| ❌ 要独立桌面应用或完全不要 Node | 不在范围内 — 宿主是 DSH + Node 工具链 |

**许可**：MIT — 任何人可安装、修改、再分发。**不需要**作者账号或某台开发机路径。

### 前置条件（摘要）

| 项 | 用途 |
|----|------|
| [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) + `dsh` | npm / 本地 `file:` 安装 bundle |
| Node `^22.19` 或 `>=24` | build · verify · guard |
| bash | `install-planrun.sh` · `dsh-guard.sh` |

完整表与三条安装路径 → **[docs/zh/install.md](docs/zh/install.md)**。

### PlanRun（DSH）vs Super Cursor（`.cursor/`）

| | **PlanRun**（`@planrun/bundle`） | **Super Cursor**（母版 `.cursor/`） |
|--|--------------------------------|-------------------------------------|
| **宿主** | DeepSeek Harness profile | Cursor IDE 项目 |
| **plan 文件** | `.dsh/growth/plan.md` | `.cursorGrowth/plan.md` |
| **安装** | `dsh plugin add @planrun/bundle` | `install-super-cursor.sh` → 目标 `.cursor/` |
| **本仓** | `packages/*` 发 npm | `.cursor/` skills/rules（母版开发） |

---

## 工作流闭环

```mermaid
flowchart LR
  A[master<br/>迷路路由] --> B[sprint-plan<br/>多任务规划]
  B --> C[run<br/>ACTIVE 实现]
  C --> D{完成?}
  D -->|否| C
  D -->|是| E[release · delivery<br/>打版走查]
  C -.-> F[review · debug · test]
  B -.-> G[long · scaffold · learn · git]
```

| 阶段 | Skills | 一句话 |
|---|---|---|
| **路由** | `master` | 不知道下一步加载谁 |
| **规划** | `sprint-plan` · `long` | 多任务 Sprint / Epic（≠ DSH `/plan` 单任务设计） |
| **执行** | `run` · `debug` · `test` | 按 `.dsh/growth/plan.md` ACTIVE 行实现 + verify |
| **沉淀** | `learn` · `git` · `scaffold` | 项目约定 · 分支提交 · 空仓脚手架 |
| **交付** | `review` · `delivery` · `release` | PR 回顾 · 7 维走查 · merge / tag / CHANGELOG |

---

## 仓库结构

```
packages/
  skill-provider/       # @planrun/skill-provider — Cordis 插件 + skills/
  bundle-planrun/       # @planrun/bundle — dsh.bundle.patch + agent presets
  workflow/             # @planrun/workflow — session hooks（growth · run-start · run-stop）
presets/                # preset 源：<id>/{preset.yml,plugins.yml}
templates/growth/       # plan.md · learn/ · archive/ 种子
scripts/                # install-planrun.sh · gen-presets.mjs · dsh-guard.sh · verify-*
docs/                   # en/ · zh/ — VitePress 文档站
```

| 组件 | 包 / 路径 | 作用 |
|---|---|---|
| Bundled skills | `@planrun/skill-provider` | 28 workflow skills + `config/roles.json`（12 人格） |
| Profile bundle | `@planrun/bundle` | `cordis.patch.yml` 挂载 skill provider + **workflow**；`presets.patch.yml` 声明 4 个 agent preset |
| Agent presets | `presets/` → `presets.patch.yml` | 官方 `@deepseek-ai/dsh-agent-preset` 声明（由 `scripts/gen-presets.mjs` 生成） |
| Growth 模板 | `templates/growth/` | 项目本地 `.dsh/growth/` 种子 |
| 安装脚本 | `scripts/install-planrun.sh` | 复制 growth 模板 + 打印 profile 说明 |
| Workflow guard | `scripts/dsh-guard.sh` | `gate-check` · `plan-check` · `task-verify` · `next-task` |

Bundle 声明（`patch` 是**有序列表**，与官方 `dsh-web-app` 同模式）：

```json
"dsh": {
  "bundle": { "patch": ["./cordis.patch.yml", "./presets.patch.yml"] }
}
```

---

## 快速开始

### 1 · 构建（本仓开发）

```sh
git clone https://github.com/wangqiqi/planrun.git planrun && cd planrun
pnpm install
pnpm run build
pnpm run verify          # 28 skills + 12 personas + DSH 适配 token 结构检查
```

开发时 `skill-provider` 的 peer 可指向同级 `deepseek-harness` checkout。

### 2 · 安装 bundle（DSH profile）

**已发布（推荐）**：

```sh
dsh plugin --profile web add @planrun/bundle
```

**本仓开发**（`pack-local.sh` 会先构建，再把 `workspace:^` 改写成 file: 依赖）：

```sh
export PLANRUN_HOME=/path/to/planrun
"$PLANRUN_HOME/scripts/pack-local.sh"
dsh plugin --profile web add "file:$PLANRUN_HOME/dist-local/bundle-planrun"
```

**不要**直接 `add "file:$PLANRUN_HOME/packages/bundle-planrun"`：monorepo 的 `workspace:^` 依赖会报 `ERR_PNPM_WORKSPACE_PKG_NOT_FOUND`。

验证：

```sh
dsh --profile web --dump-config | grep planrun-skills
ls "$DSH_HOME/profiles/web/node_modules/@planrun/skill-provider/skills/"
```

**不要**在 profile 的 `cordis.patch.yml` 里再手动 insert 同一插件 — bundle 已挂载，双挂载会 boot 失败。

详见 [publish.md](docs/zh/publish.md) · [Harness publish 文档](https://deepseek-harness.github.io/deepseek-harness/en/develop/basic/publish)。

### 3 · 初始化项目 growth

在目标 Git 仓库根：

```sh
export PLANRUN_HOME=/path/to/planrun
"$PLANRUN_HOME/scripts/install-planrun.sh" --here --copy-plan
```

创建 `.dsh/growth/`（plan · learn · archive），通常 gitignore。

### 3b · Workflow guard（Sprint 闸门）

`sprint-plan` 批准 Sprint 后，**`run`** 前：

```sh
pnpm run gate-check    # PLAN_APPROVED + ACTIVE
pnpm run plan-check    # handoff 结构
pnpm run task-verify   # 当前 ACTIVE 验收
pnpm run next-task     # 下一待办 TASK id
```

plan 路径：`.dsh/growth/plan.md`（开发本仓时自动回退读 `.cursorGrowth/plan.md`）。详见 [docs/zh/workflow-guard.md](docs/zh/workflow-guard.md)。

### 4 · 在会话中使用

用 **standard** preset（或 bundle 自带的 **planrun** / **planrun-review** / **planrun-spike** / **planrun-ship**），按场景加载 skill。
四个 preset 由 `@planrun/bundle` 的 `presets.patch.yml` 声明，装完 bundle 重启 `dsh web` 即在 preset 选择器可见（无需再手动复制目录）：

| Skill | 何时加载 |
|---|---|
| `master` | 迷路 / 新会话 |
| `sprint-plan` | 多任务 Sprint 规划 |
| `run` | 执行 plan.md ACTIVE 行 |
| `review` | PR / 代码结构化回顾 |
| `learn` | 沉淀项目约定 → `.dsh/growth/learn/` |
| `git` | 分支 · 提交 · 合并 |
| `scaffold` | 空仓库脚手架 |
| `long` | 跨 Sprint Epic |
| `release` | merge · PR · tag · CHANGELOG |
| `delivery` | 上线前 7 维走查 |
| `debug` | 复现优先调试循环 |
| `test` | TDD · 分层测试 |
| `security` | 合并前安全审查 |
| `api` | REST/OpenAPI 设计审查 |
| `refactor` | 安全重构 · 死代码删除 |
| `perf` | 性能排查（测量优先） |
| `mcp` | MCP 服务器设计与 Eval |
| `study` | 学新技术/语言（≠ `learn` 本仓约定） |
| `user-manual` | 可发布使用说明书 · 配图 regen |
| `test-report` | 可发布测试报告 · verify 汇总 |

单任务方案设计 → DSH 内置 **`/plan`** plan mode（不是 `sprint-plan`）。

Bundle 变更后需**重启** profile（`dsh web`），不像 profile 级 patch 那样热加载。

---

## 与 Super Cursor 命名对照

| Super Cursor | PlanRun | 说明 |
|---|---|---|
| `plan` skill | **`sprint-plan`** | 避免与 DSH `/plan` plan mode 冲突 |
| `.cursorGrowth/` | **`.dsh/growth/`** | 项目本地，通常 gitignore |
| `AskQuestion` | **`ask_user_question`** | DSH 交互工具 |
| `rules/*.mdc` | **`docs/zh/discipline.md`** | 常驻纪律摘要 |

完整对照 → [docs/zh/mapping-from-super-cursor.md](docs/zh/mapping-from-super-cursor.md) · [docs/zh/naming.md](docs/zh/naming.md)

---

## 校验命令

```sh
pnpm run build
pnpm run verify
pnpm run verify:publish   # npm pack 结构（lib/*.js 运行时模块必须齐全）
pnpm run verify:links     # 仓库内所有 markdown 相对链接都能解析
pnpm run verify:e2e       # 构建 → 装临时 profile → boot（须 DEEPSEEK_HARNESS_HOME）
pnpm run verify:dogfood   # 须 DEEPSEEK_HARNESS_HOME
pnpm run gate-check    # 有 plan 时
pnpm run typecheck
```

`verify-planrun.sh` 校验 **28** 个 skill 目录、**12** 人格 catalog、**4** 个 subagent preset、bundled `agents/*.md`、long/delivery reference、guard 脚本与 npm scripts，并确保 Super Cursor 残留 token（`.cursorGrowth` · `AskQuestion` · `runner.sh`）不出现在 bundled skills 中。它还会在这些情况报错：bundle 内 skill 名与官方 DSH skill（`dsh-badge` · `office-*` · `cordis-*`）或命令（`plan` · `compact` · `goal` · `feedback`）冲突、`presets.patch.yml` 过期、以及使用了已废弃的 DSH API（`agent/session-start` · `kind: 'plugin'`）。bundle 内 skill 仍指向已废弃入口（`install-planrun.sh --preset` · `.agent-presets`）、或任何仓库内 markdown 相对链接失效时，它同样会报错——这样一次文档搬家不会留下断链。

`verify-plugin-e2e.sh` 是唯一能证明插件**真的能加载**的检查：它打包三个包、装进一次性 profile、断言 `--dump-config` 里的 bundle 行、导入 skill catalog，并 headless boot。以下情况会失败：`failed to import`、dsh peer 范围不兼容、或 session format 拒绝的 message source kind。

---

## 路线图

| 版本 | 范围 | 状态 |
|---|---|---|
| **v0.1** | MVP：`master` · `sprint-plan` · `run` · `review` + bundle + installer | ✅ |
| **v0.2 batch-1** | `learn` · `git` · `scaffold` · `long` | ✅ |
| **v0.2 batch-2** | `release` · `delivery` · `debug` · `test` | ✅ |
| **v1.0** | PlanRun 品牌更名 · `@planrun/*` · guard MVP · 16 skills | ✅ |
| **v1.1** | `@planrun/workflow` — optional hooks injection | ✅ |
| **v1.2** | Harness 结构 dogfood（`verify:dogfood`） | ✅ |
| **v1.3** | defer skills：`mcp` · `study` · `user-manual` · `test-report` | ✅ |
| **v1.4** | **12 人格** + 工具类 skills · 27 bundled | ✅ |
| **v1.5** | npm 发布 · `@planrun/bundle` · guard cwd · 项目 guard 种子 | ✅ |
| **v1.6** | subagent 预设 · `agents/*.md` · `docs/zh/subagents.md` | ✅ |
| **v1.7** | DSH API 对齐（`agent/created` · source kind）· 发布打包修复 · preset 改为官方 bundle 声明 · `verify:e2e` | ✅ current |

变更记录 → [CHANGELOG.md](CHANGELOG.md)

---

## 文档索引

| 文档 | 内容 |
|---|---|
| **站点** | [znza.top/planrun/zh](https://znza.top/planrun/zh/)（`docs/en/` · `docs/zh/`） |
| [quickstart.md](docs/zh/quickstart.md) | 安装与 dogfood |
| [dogfood.md](docs/zh/dogfood.md) | Harness 结构 dogfood（`verify:dogfood`） |
| [mapping-from-super-cursor.md](docs/zh/mapping-from-super-cursor.md) | Super Cursor → PlanRun 映射 |
| [naming.md](docs/zh/naming.md) | 命名与包坐标 |
| [workflow-guard.md](docs/zh/workflow-guard.md) | Sprint 闸门（dsh-guard） |
| [workflow-hooks-map.md](docs/zh/workflow-hooks-map.md) | Cursor hook → DSH 触点映射 |
| [publish.md](docs/zh/publish.md) | npm 发布与用户安装 |
| [subagents.md](docs/zh/subagents.md) | ship · review · spike 预设与委派 |

---

## 许可证

[MIT](LICENSE) — 亦见 `package.json` → `license`。
