# 安装 PlanRun

任何人都可以使用 PlanRun：**MIT 许可**、**公开** `@planrun/*` npm 包，无需作者账号。你仍需要正确的**宿主**与**工具链**（见下）。

English → [en/install.md](../en/install.md) · 逐步命令 → [quickstart.md](quickstart.md)

## 适用对象

| 你是 | 路径 |
|------|------|
| **DSH 用户** — 在 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 跑 Agent | **路径 A** — `@planrun/bundle`（推荐） |
| **PlanRun 贡献者** — 改本仓 | **路径 B** — clone + `file:` bundle |
| **Super Cursor 用户** — 只用 Cursor、不用 DSH | **路径 C** — 装 Super Cursor `.cursor/`（另仓 / `install-super-cursor.sh`） |

npm 里的 PlanRun **skills** 面向 **DSH**。本仓 `.cursor/` 是 **Super Cursor 母版**，不以 `@planrun/bundle` 发布。

## 前置条件

| 要求 | 说明 |
|------|------|
| **DeepSeek Harness** + `dsh` CLI | 路径 A/B 必需 |
| **Node.js** `^22.19` 或 `>=24` | 构建与 guard 脚本 |
| **pnpm** | 本仓 monorepo 开发 / verify |
| **Git** | 目标项目的 `.dsh/growth/` |
| **bash** | `install-planrun.sh`、`dsh-guard.sh` |

**不需要**：特定 Linux 用户、维护者机器路径或 Cursor IDE。

## 路径 A — npm 用户（推荐）

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

## 路径 B — 本仓开发

```sh
git clone https://github.com/wangqiqi/planrun.git planrun && cd planrun
pnpm install && pnpm run build && pnpm run verify
export PLANRUN_HOME=/path/to/planrun
dsh plugin --profile web add "file:$PLANRUN_HOME/packages/bundle-planrun"
```

## 路径 C — 仅 Super Cursor（Cursor IDE）

用上游 **install-super-cursor** 装到业务仓；不必装 PlanRun npm bundle。

映射对照 → [mapping-from-super-cursor.md](../en/mapping-from-super-cursor.md)（English）

## Workflow guard

```sh
pnpm run gate-check
pnpm run plan-check
pnpm run task-verify
pnpm run next-task
```

详见 [workflow-guard.md](../en/workflow-guard.md)（English）

## 常见错误

| 现象 | 处理 |
|------|------|
| `WORKSPACE_PKG_NOT_FOUND` | 先在 PlanRun 仓 `pnpm run build`；发布用 npm 而非 profile 里 `workspace:^` |
| bundle 会话里不可见 | `dsh plugin add` 后重启 profile |
| `gate-check` BLOCK | 在 `.dsh/growth/plan.md` 设 `PLAN_APPROVED` |

## 相关

- [publish.md](../en/publish.md) — 维护者发布（English）
- [subagents.md](../en/subagents.md) — planrun 预设（English）
