# 安装 PlanRun

任何人都可以使用 PlanRun：**MIT 许可**，无需作者账号。目前可用的是 **GitHub tag** 通道；`@planrun/*` 的 npm 包**尚未发布**（见 [publish.md](publish.md)）。你仍需要正确的**宿主**与**工具链**（见下）。

English → [en/install.md](../en/install.md) · 逐步命令 → [quickstart.md](quickstart.md)

## 适用对象

| 你是 | 路径 |
|------|------|
| **DSH 用户** — 在 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 跑 Agent | **路径 A′** — `dsh plugin add "github:wangqiqi/planrun#<tag>"`（推荐：当前唯一可用通道） |
| **DSH 用户** — 等 `@planrun/*` 上了 npm 之后 | **路径 A** — `@planrun/bundle`（尚未发布） |
| **PlanRun 贡献者** — 改本仓 | **路径 B** — clone + `file:` bundle |
| **Super Cursor 用户** — 只用 Cursor、不用 DSH | **路径 C** — 装 Super Cursor `.cursor/` |

PlanRun 自带的 **skills** 面向 **DSH**。本仓 `.cursor/` 是 **Super Cursor 母版**，不以 `@planrun/bundle` 发布。

## 前置条件

| 要求 | 说明 |
|------|------|
| **DeepSeek Harness** + `dsh` CLI | 路径 A/A′/B 必需 |
| **Node.js** `^22.19` 或 `>=24` | 构建与 guard |
| **pnpm** | 本仓 monorepo |
| **Git** | 目标项目 `.dsh/growth/` |
| **POSIX shell**（`bash`/`sh`） | `install-planrun.sh` · `dsh-guard.sh` · `pnpm run` 的 verify/guard 脚本 —— 由 `scripts/run-bash.mjs` 自动定位（Windows 用 Git for Windows 或 WSL），不要求 `bash` 在 `PATH` 上 |

## 路径 A — npm 用户（尚未发布）

> **当前不可用**：`registry.npmjs.org` 对 `@planrun/bundle` · `@planrun/workflow` · `@planrun/skill-provider` 均返回 HTTP 404，维护者机器上也没有 npm token。现在请走**路径 A′**；以下步骤要等该 scope 发布后才生效（[publish.md](publish.md)）。

```sh
dsh plugin --profile web add @planrun/bundle
```

重启 profile 后，在 Git 项目根：

```sh
git clone https://github.com/wangqiqi/planrun.git planrun
export PLANRUN_HOME="$PWD/planrun"
"$PLANRUN_HOME/scripts/install-planrun.sh" --here --copy-plan
```

验证：

```sh
dsh --profile web --dump-config | grep planrun-skills
```

**不要**在 `cordis.patch.yml` 里再手动插入同一插件。

## 路径 A′ — GitHub tag 直装（推荐：当前可用）

仓库根本身就是一个 DSH bundle：`dsh.bundle.patch` 指向 `cordis.patch.yml`（行名用相对本文件的路径，DSH 会转成 `file://` URL）以及 `packages/bundle-planrun/presets.patch.yml`（四个 agent preset）。不需要发布到 npm：

```sh
dsh plugin --profile web add "github:wangqiqi/planrun#<tag>"   # 当前版本：#v1.9.0
```

git 安装只取源码。运行时入口（`packages/*/lib/*.js`）已**随源码提交**，且根 manifest 不声明 `prepare`，因此 pnpm 不会执行任何构建脚本：不需要 `allowBuilds` 授权，也不需要本地工具链。

`pnpm run verify:lib` 会在提交的运行时与 `src/` 不一致时报错；`pnpm run verify:github` 端到端跑通整条通道（`PLANRUN_GIT_SPEC=git+file:///path/to/checkout#ref` 可验证尚未 push 的本地提交）。

请固定 tag（当前版本 `#v1.9.0`）或 commit，避免后续 push 改变安装内容。验证方式同路径 A。**路径 A 与 A′ 只能选一个**：同一 skill provider 挂载两次会在 skill registry 冲突。

## 路径 B — 本仓开发

```sh
git clone https://github.com/wangqiqi/planrun.git planrun && cd planrun
pnpm install && pnpm run build && pnpm run verify
export PLANRUN_HOME=/path/to/planrun
"$PLANRUN_HOME/scripts/pack-local.sh"
dsh plugin --profile web add "file:$PLANRUN_HOME/dist-local/bundle-planrun"
```

**不要**直接 `add "file:$PLANRUN_HOME/packages/bundle-planrun"`：源码目录的 `workspace:^` 依赖会报 `ERR_PNPM_WORKSPACE_PKG_NOT_FOUND`。

端到端校验（需已构建的 `deepseek-harness`）：`pnpm run verify:e2e` —— 会 stage 三个包、装进一次性 profile 并 boot。

结构 dogfood：`pnpm run verify:dogfood`（需 `DEEPSEEK_HARNESS_HOME`）— 见 [dogfood.md](dogfood.md)。

## 路径 C — 仅 Super Cursor

用上游 **install-super-cursor** 装到业务仓；不必装 PlanRun npm bundle。

映射 → [mapping-from-super-cursor.md](mapping-from-super-cursor.md)

## Workflow guard

```sh
pnpm run gate-check
pnpm run plan-check
pnpm run task-verify
pnpm run next-task
pnpm run doctor        # 版本漂移体检：guard 脚本 · 模板 · 包版本
```

`pnpm run` 会转交 `scripts/run-bash.mjs`，由它先探测可用的 POSIX shell（见「前置条件」）。详见 [workflow-guard.md](workflow-guard.md)。

## 常见错误

| 现象 | 处理 |
|------|------|
| `WORKSPACE_PKG_NOT_FOUND` | 跑 `scripts/pack-local.sh`（会把 `workspace:^` 改写成 `file:` 并输出到 `dist-local/`），或改用固定 tag 的 GitHub 直装 |
| GitHub 安装失败、pnpm 提示 build script 被忽略 | 该通道不应声明 `prepare`/`prepublish`（运行时是提交进仓库的）；跑 `pnpm run verify:lib` 并把 `packages/*/lib/*.js` 提交 |
| bundle 不可见 | `dsh plugin add` 后重启 profile |
| 预设/技能/插件更新后界面还是旧的 | DSH **不监听** profile 文件变化。在 **设置 → 内置插件** 里对该 bundle 做一次**关/开**（触发 in-process reload），或重启 `dsh web`。只把文件换掉不够——运行中的实例仍持旧定义，例如预设会一直显示「加载失败」 |
| `gate-check` BLOCK | `.dsh/growth/plan.md` 设 `PLAN_APPROVED` |
| `doctor` FAIL：guard 脚本漂移 | 重跑 `install-planrun.sh --here`（会记录新 hash），或把 `templates/growth/scripts/*` 复制进 `scripts/` |
| `doctor` FAIL：包版本不一致 | DSH profile 与项目装自不同 tag —— 对齐两边，FAIL 行会打印具体命令 |

## 相关

- [publish.md](publish.md) — 维护者发布流程（尚未执行）  
- [subagents.md](subagents.md) — planrun 预设
