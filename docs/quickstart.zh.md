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

在已安装 `dsh` 的机器上（**先 `pnpm run build`**）：

```sh
export DSH_SUPER_HOME=/path/to/dsh-super
dsh plugin --profile web add "file:$DSH_SUPER_HOME/packages/bundle-super"
```

验证：

```sh
dsh --profile web --dump-config | grep super-skills
ls "$DSH_HOME/profiles/web/node_modules/@dsh-super/skill-provider/skills/"
```

`bundle-super` 会通过 `file:../skill-provider` 把 skill 包链进 profile；**不要**再手动改 `cordis.patch.yml` 插入同一插件（避免双挂载）。

从 harness 仓开发时可用：

```sh
cd /path/to/deepseek-harness
pnpm dsh plugin --profile web add "file:$DSH_SUPER_HOME/packages/bundle-super"
```

**常见错误**：若 `bundle-super` 仍用 `workspace:^` 声明 skill-provider，`dsh plugin add` 在 profile 目录会报 `WORKSPACE_PKG_NOT_FOUND`。

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
| 单任务方案设计 | DSH **`/plan`**（plan mode，不是 sprint-plan） |

## 5. Dogfood（deepseek-harness）

```sh
export DSH_SUPER_HOME=/path/to/dsh-super
cd /path/to/deepseek-harness
"$DSH_SUPER_HOME/scripts/install-super-dsh.sh" --here --copy-plan
# bundle 见 §2；启动 dsh web + standard preset 后加载 master / sprint-plan / run / review
```

bundle 变更后需**重启** profile（`dsh web`），不像 profile 级 `cordis.patch.yml` 那样热加载。

## 6. 与 Super Cursor 对照

见 [mapping-from-super-cursor.md](mapping-from-super-cursor.md) 与 [naming.md](naming.md)。

English: [quickstart.md](quickstart.md)
