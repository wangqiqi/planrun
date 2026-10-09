# Publishing PlanRun to npm

> **Status: not published yet.** `registry.npmjs.org` returns HTTP 404 for
> `@planrun/bundle`, `@planrun/workflow` and `@planrun/skill-provider` (a control
> request for `yaml/latest` returns 200), and there is no npm token on the
> maintainer machine. The **Maintainer publish** section below is the documented
> procedure, **not** a record of a completed release. Users install from a pinned
> GitHub tag today — see the **Git install** section below.

PlanRun is packaged as three packages under the `@planrun` scope:

| Package | Role |
|---------|------|
| `@planrun/skill-provider` | 28 bundled skills + `config/roles.json` |
| `@planrun/workflow` | Cordis plugin (growth · run-start · run-stop · persona) |
| `@planrun/bundle` | DSH profile bundle (`dsh.bundle.patch` = `cordis.patch.yml` + `presets.patch.yml`) |

Directory `packages/bundle-planrun/` maps to npm name **`@planrun/bundle`**.

`presets.patch.yml` is generated from `presets/<id>/{preset.yml,plugins.yml}` by
`node scripts/gen-presets.mjs`; `pnpm run verify` fails when it is stale. Both patch
files must ship — `verify:publish` reads `dsh.bundle.patch` and asserts each declared
file is in the tarball.

## User install

**Today (works) — GitHub tag, pinned:**

```sh
dsh plugin --profile web add "github:wangqiqi/planrun#<tag>"   # current release: #v1.9.0
```

**After the npm scope is published (not yet — this command currently returns 404):**

```sh
dsh plugin --profile web add @planrun/bundle
```

Restart the profile after bundle changes (`dsh web`).

## Maintainer publish

> **Procedure only — not yet run for this scope.** No npm token exists on the
> maintainer machine, so nothing below has been executed.

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
- **Local install without publishing**: run `scripts/pack-local.sh`, which stages prebuilt
  copies into `dist-local/` and rewrites the bundle's deps to `file:../skill-provider` /
  `file:../workflow`. Installing the raw `packages/bundle-planrun` directory fails with
  `ERR_PNPM_WORKSPACE_PKG_NOT_FOUND`, because `workspace:^` only resolves inside the
  workspace (the `file:`/git path never runs pnpm's rewrite).

### End-to-end check

`pnpm run verify:e2e` builds, stages, installs into a throwaway DSH profile, asserts the
composed rows, imports the skill provider, and boots headless. It needs a built
`deepseek-harness` checkout (`DEEPSEEK_HARNESS_HOME`) and skips cleanly without one.

`pnpm run verify:npm` covers the artifact users will get once the scope is published: it installs
`@planrun/bundle@<repo version>` from the registry into a throwaway profile and boots it. Run it
after publishing (`bash scripts/verify-npm-install.sh @planrun/bundle@1.8.2` — pass any published
version).

### Git install (supported alternative)

**This is the channel users can install today.** The repository root is itself a DSH bundle, so it needs no npm publish:

```sh
dsh plugin --profile web add "github:wangqiqi/planrun#<tag>"   # current release: #v1.9.0
```

pnpm fetches sources and DSH mounts `./cordis.patch.yml` (relative rows become `file://` URLs)
plus the preset declarations. The root manifest declares no `prepare` and the runtime
(`packages/*/lib/*.js`) is committed, so the install runs **no build script** and needs no
`allowBuilds` permission. `pnpm run verify:lib` fails when that committed runtime drifts from
`src/`.

Pin a tag or commit. Install the git channel **or** `@planrun/bundle`, never both.
`pnpm run verify:github` runs the whole flow end to end
(`PLANRUN_GIT_SPEC=git+file:///path/to/checkout#main` tests an unpushed local commit).

## Project growth + guard

After the bundle is installed:

```sh
# from planrun checkout, or after cloning install-planrun.sh from release tag
./scripts/install-planrun.sh --here --copy-plan
```

This seeds `.dsh/growth/` and copies **guard scripts** to `scripts/` with npm scripts merged into `package.json`.

## Related

- [quickstart.md](quickstart.md) / [zh/quickstart](../zh/quickstart.md)
- [workflow-guard.md](workflow-guard.md)
- [naming.md](naming.md)
