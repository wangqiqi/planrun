# Quickstart (中文)

## 1. 构建

```sh
cd /data/test-jw/planrun
pnpm install
pnpm run build
pnpm run verify
```

开发时 `skill-provider` 的 devDependencies 指向同级目录 `deepseek-harness`。

## 2. 安装 bundle

**已发布（推荐）**：

```sh
dsh plugin --profile web add @planrun/bundle
```

发布与维护说明 → [publish.md](publish.md)

**本仓开发**（先 `pnpm run build`）：

```sh
export PLANRUN_HOME=/path/to/planrun
dsh plugin --profile web add "file:$PLANRUN_HOME/packages/bundle-planrun"
```

验证：

```sh
dsh --profile web --dump-config | grep planrun-skills
ls "$DSH_HOME/profiles/web/node_modules/@planrun/skill-provider/skills/"
```

`@planrun/bundle`（目录 `packages/bundle-planrun/`）会通过依赖把 skill 包链进 profile；**不要**再手动改 `cordis.patch.yml` 插入同一插件（避免双挂载）。

从 harness 仓开发时可用：

```sh
cd /path/to/deepseek-harness
pnpm dsh plugin --profile web add "file:$PLANRUN_HOME/packages/bundle-planrun"
```

**常见错误**：若 bundle 仍用 `workspace:^` 声明 skill-provider，`dsh plugin add` 在 profile 目录会报 `WORKSPACE_PKG_NOT_FOUND`。

## 3. 项目内 growth 模板

```sh
./scripts/install-planrun.sh --here
```

会在 Git 项目根创建 `.dsh/growth/`（plan · learn · archive）。

## 4. Workflow guard（Sprint 闸门）

`sprint-plan` 写好 plan 并设 `PLAN_APPROVED` 后，**`run`** 前先：

```sh
pnpm run gate-check
pnpm run plan-check
pnpm run task-verify    # 任务收尾前
pnpm run next-task      # 找下一项
```

plan 路径：`.dsh/growth/plan.md`（开发 PlanRun 本身可用 `.cursorGrowth/plan.md`）。详见 [workflow-guard.md](workflow-guard.md)。

## 5. 在会话中使用

使用 **standard** preset（或 **planrun** preset）：

| 场景 | 加载 skill |
|---|---|
| 不知道用哪个流程 | `master` |
| 多任务 / Sprint 规划 | `sprint-plan` |
| 跨 Sprint Epic | `long` |
| 执行 ACTIVE 任务 | `run` |
| 学本仓约定 | `learn` |
| Git 提交/合并 | `git` |
| 空仓库脚手架 | `scaffold` |
| PR / 代码回顾 | `review` |
| 打版 / merge / tag | `release` |
| 上线走查 | `delivery` |
| 写测试 / TDD | `test` |
| 查 bug / 测挂了 | `debug` |
| 安全审查 / 密钥鉴权 | `security` |
| API 设计 / OpenAPI | `api` |
| 重构 / 删死代码 | `refactor` |
| 性能慢 / bundle 大 | `perf` |
| 单任务方案设计 | DSH **`/plan`**（plan mode，不是 sprint-plan） |

## 6. Dogfood（deepseek-harness）

**结构闭环（推荐先做）** — 不依赖 `dsh web`：

```sh
export PLANRUN_HOME=/path/to/planrun
export DEEPSEEK_HARNESS_HOME=/path/to/deepseek-harness
pnpm run build
pnpm run verify:dogfood
```

详见 [dogfood.md](dogfood.md)。

**交互走查**（需 `dsh` CLI）：

```sh
export PLANRUN_HOME=/path/to/planrun
cd /path/to/deepseek-harness
"$PLANRUN_HOME/scripts/install-planrun.sh" --here --copy-plan
# bundle 见 §2；启动 dsh web + planrun preset 后加载 master / sprint-plan / run / review
```

bundle 变更后需**重启** profile（`dsh web`），不像 profile 级 `cordis.patch.yml` 那样热加载。

## 7. 与 Super Cursor 对照

见 [mapping-from-super-cursor.md](mapping-from-super-cursor.md) 与 [naming.md](naming.md)。

English: [quickstart.md](quickstart.md)
