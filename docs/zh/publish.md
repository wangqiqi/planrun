# 发布 PlanRun 到 npm

`@planrun` 作用域三个公开包：

| 包 | 作用 |
|----|------|
| `@planrun/skill-provider` | 28 bundled skills + `roles.json` |
| `@planrun/workflow` | Cordis plugin（growth · run-start · run-stop · persona） |
| `@planrun/bundle` | DSH profile bundle（`dsh.bundle.patch` = `cordis.patch.yml` + `presets.patch.yml`） |

目录 `packages/bundle-planrun/` 对应 npm 名 **`@planrun/bundle`**。

`presets.patch.yml` 由 `node scripts/gen-presets.mjs` 从 `presets/<id>/{preset.yml,plugins.yml}` 生成；`pnpm run verify` 在它过期时报错。两个 patch 文件都必须发布——`verify:publish` 会读 `dsh.bundle.patch` 并断言每个声明的文件都在 tarball 里。

## 用户安装

```sh
dsh plugin --profile web add @planrun/bundle
```

bundle 变更后**重启** profile（`dsh web`）。

## 维护者发布

### 前置

- Node `^22.19` 或 `>=24`  
- `npm login`（`@planrun` 权限）  
- `pnpm run build` · `verify` · `verify:publish` 全绿

### 发布顺序

1. `@planrun/skill-provider`  
2. `@planrun/workflow`  
3. `@planrun/bundle`

```sh
pnpm run build
pnpm run verify:publish
pnpm run publish:packages
```

仅 pack 不上传：

```sh
bash scripts/publish-packages.sh --pack-only
```

### 本仓 dev vs npm

- **Monorepo**：`workspace:^` 链 sibling  
- **发布**：`pnpm publish` 自动把 `workspace:^` 写成 semver

### GitHub 直装（免 npm 发布）

仓库根本身就是 DSH bundle，因此不需要先发布 npm：

```sh
dsh plugin --profile web add "github:wangqiqi/planrun#v1.8.0"
```

pnpm 取源码后，DSH 直接挂载 `./cordis.patch.yml`（相对行名转成 `file://` URL）与 preset 声明。根 manifest 不声明 `prepare`，运行时（`packages/*/lib/*.js`）随源码提交，因此安装**不执行任何构建脚本**，也不需要 `allowBuilds` 授权。`pnpm run verify:lib` 会在提交的运行时与 `src/` 不一致时报错。

请固定 tag 或 commit。**GitHub 通道与 `@planrun/bundle` 只能选一个。** `pnpm run verify:github` 端到端跑通整条链路（`PLANRUN_GIT_SPEC=git+file:///path/to/checkout#main` 可验证尚未 push 的本地提交）。

## 项目 growth + guard

```sh
./scripts/install-planrun.sh --here --copy-plan
```

种子 `.dsh/growth/` 并复制 guard 到 `scripts/`。

## 相关

- [quickstart.md](quickstart.md)  
- [workflow-guard.md](workflow-guard.md)  
- [naming.md](naming.md)
