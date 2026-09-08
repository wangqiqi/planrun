# Quickstart (中文)

## 1. 构建

```sh
cd /data/test-jw/dsh-super
pnpm install
pnpm run build
pnpm run verify
```

开发时 `skill-provider` 的 devDependencies 指向同级目录 `deepseek-harness`。

## 2. 安装 bundle

在已安装 `dsh` 的机器上：

```sh
export DSH_SUPER_HOME=/data/test-jw/dsh-super
dsh plugin --profile web add "file:$DSH_SUPER_HOME/packages/bundle-super"
```

或在 `$DSH_HOME/profiles/web/cordis.patch.yml` 追加：

```yaml
- insert:
    - id: super-skills
      name: '@dsh-super/skill-provider'
```

（需保证 Node 能解析 `@dsh-super/skill-provider`，通常通过 profile 的 `node_modules` 链接 workspace 包。）

## 3. 项目内 growth 模板

```sh
./scripts/install-super-dsh.sh --here
```

会在 Git 项目根创建 `.dsh/growth/`（plan · learn · archive）。

## 4. 在会话中使用

使用 **standard** preset（或未来的 **super** preset）：

| 场景 | 加载 skill |
|---|---|
| 不知道用哪个流程 | `master` |
| 多任务 / Sprint 规划 | `sprint-plan` |
| 执行 ACTIVE 任务 | `run` |
| PR / 代码回顾 | `review` |
| 单任务方案设计 | DSH **`/plan`**（plan mode，不是 sprint-plan） |

## 5. 与 Super Cursor 对照

见 [mapping-from-super-cursor.md](mapping-from-super-cursor.md) 与 [naming.md](naming.md)。

English: [quickstart.md](quickstart.md)
