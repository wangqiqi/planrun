# Harness dogfood（结构验收）

PlanRun **结构 dogfood** 在本地 **deepseek-harness** checkout 上验证 bundle 产物、28 skills、growth 安装与 guard 循环 — **无需**交互式 `dsh web`。

交互走查见 [quickstart.md](quickstart.md) §6。

## 前置

| 变量 | 必需 | 说明 |
|------|------|------|
| `DEEPSEEK_HARNESS_HOME` | **是** | deepseek-harness 仓路径（含 `.git`） |
| `PLANRUN_HOME` | 否 | PlanRun 根（默认 `scripts/` 上级） |

```sh
cd "$PLANRUN_HOME"
pnpm install && pnpm run build
```

## 运行

```sh
export DEEPSEEK_HARNESS_HOME=/path/to/deepseek-harness
export PLANRUN_HOME=/path/to/planrun

pnpm run verify:dogfood
```

| 结果 | 含义 |
|------|------|
| 退出 1 + 未设置 env | 预期（未配 harness） |
| 退出 0 + `verify-dogfood: OK` | 结构闭环绿 |

`pnpm run verify` **不**调用 dogfood — 无 harness 的 CI 仍绿。

## 检查项

1. Harness 布局（`package.json` 或 `AGENTS.md`）  
2. Plan fixture — `templates/dogfood/plan-fixture.md`  
3. Guard 循环 — `gate-check` · `plan-check` · `next-task`  
4. Bundle 产物 — skill-provider · workflow · bundle `lib/`  
5. **28 skills** 磁盘清单 + `master/routes.md`  
6. `install-planrun.sh` 在临时 git 根种子 `.dsh/growth/`

## 交互 dogfood（手动）

```sh
dsh plugin --profile web add "file:$PLANRUN_HOME/packages/bundle-planrun"
# 重启 dsh web · planrun preset · 加载 master / sprint-plan / run
```

## 相关

- [workflow-guard.md](workflow-guard.md)  
- [workflow-hooks-map.md](workflow-hooks-map.md)
