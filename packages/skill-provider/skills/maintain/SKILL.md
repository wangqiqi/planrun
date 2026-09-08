---
name: maintain
description: >-
  Dev environment maintenance (no slash): Ubuntu/Linux diagnose and safe cleanup,
  delegates disk snapshots. Trigger on 清理环境, dev maintenance, 系统维护.
disable-model-invocation: true
user-invocable: true
---

# maintain · 开发环境维护

**工具技能**（无 slash · 非 sprint-plan/run 主路径）。**用这个**：本机诊断/安全清理（Linux）。**不是那个**：业务 refactor；先看占用 → **disk** skill。

诊断与本机安全清理（**Linux**）。快照与对比委托 **disk** skill。

**Scripts**: bundled at `@planrun/skill-provider/skills/maintain/scripts/` (planrun checkout: `packages/skill-provider/skills/maintain/scripts/`).

## 何时进入

- 用户说「清理环境」「系统维护」「磁盘满了」「dev maintenance」
- 清理前/后配合 **disk** skill 观察变动
- **`master`** 或关键词命中

## 流程

### 1. 诊断（默认）

```bash
packages/skill-provider/skills/maintain/scripts/dev-maintain.sh --diagnose
```

### 2. 预览清理

```bash
packages/skill-provider/skills/maintain/scripts/dev-maintain.sh --clean --dry-run
```

### 3. 执行清理

```bash
packages/skill-provider/skills/maintain/scripts/dev-maintain.sh --clean
# 高风险项（Downloads 旧包、Docker、HF 缓存等）：
packages/skill-provider/skills/maintain/scripts/dev-maintain.sh --interactive --clean
```

### 4. 快照对比（推荐包裹清理）

```bash
packages/skill-provider/skills/maintain/scripts/dev-maintain.sh --snapshot
packages/skill-provider/skills/maintain/scripts/dev-maintain.sh --clean
packages/skill-provider/skills/maintain/scripts/dev-maintain.sh --snapshot
packages/skill-provider/skills/maintain/scripts/dev-maintain.sh --diff
```

或直接用 **disk** skill / `collect-disk.py`。

## 配置

| 文件 | 用途 |
|------|------|
| `skills/maintain/config/default-protected.json` | 默认受保护目录与缓存列表 |
| `.dsh/growth/maintain-config.json` | 本机覆盖（可复制 default-protected 结构自定义） |

Playwright 浏览器缓存（`~/.cache/ms-playwright*`）默认在 `protected_dirs`，清理时保留。薄封装可通过环境变量 `MAINTAIN_BUILTIN_PROTECTED`（`|` 分隔路径）追加白名单。

**禁止**在配置中写入个人信息；仅路径与标签。

## 与 disk 的分工

| 工具 | 职责 |
|------|------|
| **maintain** | 诊断 + 可选删除 |
| **disk** | 只读快照 + diff |

## 兼容入口

仓库根 `ubuntu-ai-maintenance.sh`（若存在）为薄封装，委托本脚本。
