# Super Cursor → PlanRun 映射

参考：Super Cursor v4.x（母版 `.cursor/`）。

状态：**keep** · **rename** · **merge** · **defer** · **drop**

## Skills（28 bundled · v1.4+）

| Super Cursor | PlanRun | 状态 |
|--------------|---------|------|
| master | master | **keep** |
| plan | sprint-plan | **rename** · **keep** |
| run | run | **keep** |
| review | review | **keep** |
| long · learn · scaffold · git | 同名 | **keep**（batch-1） |
| release · delivery · debug · test | 同名 | **keep**（batch-2） |
| security · api · refactor · perf | 同名 | **keep**（batch-3） |
| user-manual · test-report · mcp · study | 同名 | **keep**（batch-4） |
| ux · ia · week · disk · maintain · code-stats-viz · pencil-design · md2docx-export | 同名 | **keep**（v1.4+） |

## Rules（48 → ~12 条）

| Super Cursor | PlanRun | 状态 |
|--------------|---------|------|
| core / workflow / constitution | [discipline.md](discipline.md) | **merge** |
| feedback/* | run + release skills + dsh-pre-push-checks | **merge** |
| execution/* | 领域 skills | defer |
| tech/* | 按栈 preset | defer |
| persona rules | discipline §Persona + workflow 注入 | **merge** |
| roles.json（12） | `@planrun/skill-provider/config/roles.json` | **keep**（v1.4） |

## 运行时

| Super Cursor | PlanRun | 状态 |
|--------------|---------|------|
| hooks.json | `@planrun/workflow` | **keep**（v1.1） |
| runner.sh | `dsh-guard.sh` + `pnpm run gate-check` | **keep** |
| plan HTML meta | `.dsh/growth/plan.md` + guard | **keep** |
| commands/*.md | skill 描述 + 用户 slash | **merge** |
| agents ship/review/spike | subagent presets + `agents/*.md` | **keep**（v1.6） |

## 安装

| Super Cursor | PlanRun |
|--------------|---------|
| 复制 `.cursor/` | `dsh plugin add @planrun/bundle` |
| `.cursorGrowth/` 种子 | `install-planrun.sh` → `.dsh/growth/` |

## 与 deepseek-harness 去重

| 主题 | 归属 |
|------|------|
| Pre-push | harness `dsh-pre-push-checks` |
| 文档闸门 | `dsh-doc` · `doc-sync` |
| Plan mode | `@deepseek-ai/dsh-plan-mode` |
| Skill 注册 | `@deepseek-ai/dsh-skill` + filesystem |

PlanRun skills **链接** harness 闸门，不重复列命令。
