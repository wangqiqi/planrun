# PlanRun subagent 预设（DSH）

将 Super Cursor **ship** · **review** · **spike** agent 移植为 DSH **agent preset** + 命名委派工具。

## 安装预设

```sh
export PLANRUN_HOME=/path/to/planrun
"$PLANRUN_HOME/scripts/install-planrun.sh" --preset
```

复制到 `~/.dsh/.agent-presets/`：

| Preset | 用途 |
|--------|------|
| `planrun` | Sprint 人格 + `subagent_*` 委派 |
| `planrun-review` | 只读 review 会话 |
| `planrun-spike` | 只读 SPIKE 会话 |
| `planrun-ship` | release / tag 会话 |

安装后重启 `dsh web`。

## 推荐组合

| 层 | 选择 |
|----|------|
| Bundle | `dsh plugin add @planrun/bundle` |
| 默认 preset | **`standard`**（全工具）+ bundle skills |
| 委派 | 复制 planrun 委派行到 standard，或切 **planrun** preset |

日常编码用 **standard** + PlanRun skills；需要 `subagent_review` / `subagent_spike` / `subagent_ship` 时切 **planrun**。

## 命名委派工具（planrun preset）

| 工具 | 模式 | 只读 |
|------|------|------|
| `subagent_review` | one-shot | 是 |
| `subagent_spike` | one-shot | 是 |
| `subagent_ship` | 后台可续 | 否（release 写入） |
| `subagent` | 可续 | 继承父 preset |
| `subagent_fork` | one-shot fork | 继承父 preset |

### 示例：review

```
subagent_review(
  label: "REV-001",
  prompt: "Load review skill. Review packages/workflow since main.",
  run_in_background: false
)
```

### 示例：SPIKE

```
subagent_spike(
  label: "SPIKE-001",
  prompt: "Compare npm vs git install for @planrun/bundle.",
  run_in_background: false
)
```

### 示例：ship

```
subagent_ship(
  label: "ship v1.6.2",
  prompt: "Load release skill. verify → CHANGELOG → tag.",
  run_in_background: true
)
```

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

- 在 `@planrun/bundle` cordis.patch 自动挂载 `~/.dsh/.agent-presets`（仍须 `--preset` 手动复制）
