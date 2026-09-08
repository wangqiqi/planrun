# Publishing PlanRun to npm

PlanRun ships three public packages under the `@planrun` scope:

| Package | Role |
|---------|------|
| `@planrun/skill-provider` | 27 bundled skills + `config/roles.json` |
| `@planrun/workflow` | Cordis plugin (growth · run-start · run-stop · persona) |
| `@planrun/bundle` | DSH profile bundle (`dsh.bundle.patch`) |

Directory `packages/bundle-planrun/` maps to npm name **`@planrun/bundle`**.

## User install (one line)

```sh
dsh plugin --profile web add @planrun/bundle
```

Restart the profile after bundle changes (`dsh web`).

## Maintainer publish

### Prerequisites

- Node `^22.19` or `>=24`
- `npm login` with access to **`@planrun`** scope
- Clean `pnpm run build` · `pnpm run verify` · `pnpm run verify:publish`

### Publish order

Dependencies must publish in order:

1. `@planrun/skill-provider`
2. `@planrun/workflow`
3. `@planrun/bundle`

```sh
pnpm run build
pnpm run verify:publish          # structural pack checks (no upload)
pnpm run publish:packages        # upload to npm (requires npm login)
```

Dry-run pack only:

```sh
bash scripts/publish-packages.sh --pack-only
```

### Workspace dev vs publish

- **Local monorepo**: `bundle` uses `workspace:^` for skill-provider and workflow; pnpm links siblings.
- **npm consumers**: `pnpm publish` rewrites `workspace:^` to semver ranges automatically.

### Git install (alternative)

Not the primary path for v1.5. See [Harness publish docs](https://deepseek-harness.github.io/deepseek-harness/en/develop/basic/publish) for `prepare` + `allowBuilds` if needed.

## Project growth + guard

After the bundle is installed:

```sh
# from planrun checkout, or after cloning install-planrun.sh from release tag
./scripts/install-planrun.sh --here --copy-plan
```

This seeds `.dsh/growth/` and copies **guard scripts** to `scripts/` with npm scripts merged into `package.json`.

## Related

- [quickstart.md](quickstart.md) / [quickstart.zh.md](quickstart.zh.md)
- [workflow-guard.md](workflow-guard.md)
- [naming.md](naming.md)
