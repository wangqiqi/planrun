# 发布 PlanRun 到 npm

`@planrun` 作用域三个公开包：

| 包 | 作用 |
|----|------|
| `@planrun/skill-provider` | 28 bundled skills + `roles.json` |
| `@planrun/workflow` | Cordis plugin（growth · run-start · run-stop · persona） |
| `@planrun/bundle` | DSH profile bundle |

目录 `packages/bundle-planrun/` 对应 npm 名 **`@planrun/bundle`**。

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

## 项目 growth + guard

```sh
./scripts/install-planrun.sh --here --copy-plan
```

种子 `.dsh/growth/` 并复制 guard 到 `scripts/`。

## 相关

- [quickstart.md](quickstart.md)  
- [workflow-guard.md](workflow-guard.md)  
- [naming.md](naming.md)
