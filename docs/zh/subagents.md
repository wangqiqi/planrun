# PlanRun subagent 预设（DSH）

将 Super Cursor **ship** · **review** · **spike** agent 移植为 DSH **agent preset** + 命名委派工具。

## 安装预设

四个 preset **随 bundle 一起安装**（`packages/bundle-planrun/presets.patch.yml` 里的官方 `@deepseek-ai/dsh-agent-preset` 声明）：

```sh
dsh plugin --profile web add "github:wangqiqi/planrun#<tag>"   # 当前版本：#v1.9.2

# npm（尚未发布）：
dsh plugin --profile web add @planrun/bundle

# 本仓开发：
"$PLANRUN_HOME/scripts/pack-local.sh"
dsh plugin --profile web add "file:$PLANRUN_HOME/dist-local/bundle-planrun"
```

重启 `dsh web`，preset 选择器出现：

| Preset | 用途 |
|--------|------|
| `planrun` | Sprint 人格 + `subagent_*` 委派 |
| `planrun-review` | 只读 review 会话 |
| `planrun-spike` | 只读 SPIKE 会话 |
| `planrun-ship` | release / tag 会话 |

> DSH 已不再读取 `$DSH_HOME/.agent-presets/<id>/` 目录（`preset.yml` + `agent.cordis.yml`）；agent preset 现在是 bundle patch 里的声明，因此 `install-planrun.sh --preset` 已删除。
> preset 只在挂载了 `@deepseek-ai/dsh-agent-preset-registry` 的表面生效——Web bundle 有，headless bundle 没有（在那里声明行保持 pending，打印一行无害的 "did not activate" 警告）。

修改 preset：改 `presets/<id>/{preset.yml,plugins.yml}` → 运行 `node scripts/gen-presets.mjs` → 重装 bundle。`pnpm run verify` 会在生成的 patch 过期时报错。

## 推荐组合

| 层 | 选择 |
|----|------|
| Bundle | `dsh plugin add "github:wangqiqi/planrun#<tag>"`（npm 等价物 `@planrun/bundle` 待发布） |
| 默认 preset | **`standard`**（全工具）+ bundle skills |
| 委派 | 复制 planrun 委派行到 standard，或切 **planrun** preset |

日常编码用 **standard** + PlanRun skills；需要 `subagent_review` / `subagent_spike` / `subagent_ship` 时切 **planrun**。

## 命名委派工具（planrun preset）

| 工具 | 子 preset | 只读 |
|------|-----------|------|
| `subagent_review` | `agentPreset: planrun-review` | 是（子 preset 不含 write/bash/委派工具） |
| `subagent_spike` | `agentPreset: planrun-spike` | 是 |
| `subagent_ship` | `agentPreset: planrun-ship` | 否（release 写入；子 preset 不含委派工具） |
| `subagent` | 继承父 preset | 继承父 preset |
| `subagent_fork` | 继承父 preset | 继承父 preset |

> DSH ≥0.2 已移除 tool-subagent 的逐工具 `persona` 与 toolFilter 配置：委派工具改用
> `agentPreset` 选择子 agent preset，限制由 preset 的插件清单决定。只读保证因此落在
> `planrun-review` / `planrun-spike`（不含 write/bash 行、不含 subagent 行）；这两个
> preset 必须保持安装，否则命名工具失去隔离。

### 示例：review

```
subagent_review(
  description: "review REV-001",
  prompt: "Load review skill. Review packages/workflow since main."
)
```

### 示例：SPIKE

```
subagent_spike(
  description: "SPIKE-001 research",
  prompt: "Compare npm vs git install for @planrun/bundle.",
)
```

### 示例：ship

```
subagent_ship(
  description: "ship v1.8.3",
  prompt: "Load release skill. verify → CHANGELOG → tag."
)
```

spawn provider 可续（子 agent 结束后可用 `send_message` 继续）；`run_in_background` / `label`
参数已不在工具面上。

## Agent 定义（npm）

```
node_modules/@planrun/skill-provider/agents/
  review.md · spike.md · ship.md
```

## Super Cursor 对照

| Super Cursor | PlanRun |
|--------------|---------|
| `.cursor/agents/review.md` | `planrun-review` + `subagent_review` |
| `.cursor/agents/spike.md` | `planrun-spike` + `subagent_spike` |
| `.cursor/agents/ship.md` | `planrun-ship` + `subagent_ship` |

## v1.6 未做

- Codex / Claude Code 产品专用 subagent 行（上游 standard preset 里仍 `disabled`）
