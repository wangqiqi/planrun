# Install PlanRun

Anyone can use PlanRun: **MIT license**, **public** `@planrun/*` npm packages, no author account required. You still need the right **host** and **toolchain** (see below).

中文版 → [zh/install](../zh/install.md) · [zh/quickstart](../zh/quickstart.md)。Step-by-step → [quickstart.md](quickstart.md).

## Who this is for

| You are | Use |
|---------|-----|
| **DSH user** — running agents in [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) | **Path A** — `@planrun/bundle` (recommended) |
| **DSH user without the npm registry** | **Path A′** — `dsh plugin add github:wangqiqi/planrun` |
| **PlanRun contributor** — hacking this repo | **Path B** — clone + `file:` bundle |
| **Super Cursor user** — Cursor-only, no DSH | **Path C** — install Super Cursor `.cursor/` into your project (separate repo / `install-super-cursor.sh`) |

PlanRun **skills in npm** target **DSH**. The `.cursor/` tree in this repo is the **Super Cursor mother pack**; it is not published as `@planrun/bundle`.

## Prerequisites

| Requirement | Notes |
|-------------|--------|
| **DeepSeek Harness** + `dsh` CLI | Required for Path A/B |
| **Node.js** `^22.19` or `>=24` | Build and guard scripts |
| **pnpm** | Monorepo dev / verify |
| **Git** | Target project for `.dsh/growth/` |
| **bash** | `install-planrun.sh`, `dsh-guard.sh` |

**Not required**: a specific Linux user, this maintainer's machine paths, or Cursor IDE.

**Optional later**: `@planrun/workflow` hooks (included in the bundle), external tools (e.g. `mddocx` for **md2docx-export** skill). The four `planrun*` agent presets ship inside the bundle as `@deepseek-ai/dsh-agent-preset` declarations — no separate install step.

## Path A — npm user (recommended)

1. Install and configure DSH (see upstream harness docs).
2. Add the bundle to your profile:

```sh
dsh plugin --profile web add @planrun/bundle
```

3. Restart the profile (`dsh web` or your team's flow).
4. In a **Git project** root, seed growth (from any clone of this repo, or after downloading `install-planrun.sh`):

```sh
git clone https://github.com/wangqiqi/planrun.git planrun
export PLANRUN_HOME="$PWD/planrun"
"$PLANRUN_HOME/scripts/install-planrun.sh" --here --copy-plan
```

Creates `.dsh/growth/` (plan · learn · archive). Add `.dsh/growth/` to `.gitignore` if needed.

5. **Verify** bundle mounted:

```sh
dsh --profile web --dump-config | grep planrun-skills
ls "$DSH_HOME/profiles/web/node_modules/@planrun/skill-provider/skills/"
```

**Do not** manually insert the same plugin again in `cordis.patch.yml` — double mount breaks boot.

## Path A′ — GitHub (no npm registry)

The repo root is itself a DSH bundle: `dsh.bundle.patch` points at `cordis.patch.yml` (rows use
paths relative to the patch, which DSH turns into `file://` URLs) and at
`packages/bundle-planrun/presets.patch.yml` for the four agent presets. Nothing has to be
published to npm:

```sh
dsh plugin --profile web add "github:wangqiqi/planrun#v1.8.0"
```

A git install fetches sources only. The runtime entry points (`packages/*/lib/*.js`) are
**committed**, and the root manifest declares no `prepare`, so pnpm installs the dependency
without running any build script: no `allowBuilds` permission, no local toolchain.

`pnpm run verify:lib` fails when the committed runtime drifts from `src/`, and
`pnpm run verify:github` exercises the whole channel (`PLANRUN_GIT_SPEC=git+file:///path/to/checkout#ref`
tests an unpushed commit).

Pin a tag (`#v1.8.0`) or a commit so a later push cannot change what you install. Verify as in
Path A. Install **Path A or Path A′**, never both: two mounts of the same skill provider collide
in the skill registry.

## Path B — develop from this repo

```sh
git clone https://github.com/wangqiqi/planrun.git planrun
cd planrun
pnpm install
pnpm run build
pnpm run verify
```

Install bundle from source:

```sh
export PLANRUN_HOME=/path/to/planrun
"$PLANRUN_HOME/scripts/pack-local.sh"
dsh plugin --profile web add "file:$PLANRUN_HOME/dist-local/bundle-planrun"
```

End-to-end check (needs a built `deepseek-harness` checkout): `pnpm run verify:e2e`
stages the packages, installs them into a throwaway profile, and boots it. Do not
`add` the raw `packages/bundle-planrun` directory — its `workspace:^` deps fail
with `ERR_PNPM_WORKSPACE_PKG_NOT_FOUND`.

Optional structural dogfood (requires harness checkout):

```sh
export DEEPSEEK_HARNESS_HOME=/path/to/deepseek-harness
pnpm run verify:dogfood
```

See [dogfood.md](dogfood.md).

## Path C — Super Cursor (Cursor IDE only)

| Piece | Location |
|-------|----------|
| Rules · skills · agents | Super Cursor mother repo `.cursor/` |
| Project-specific plan/learn | `.cursorGrowth/` (gitignored) on target project |

Use upstream **install-super-cursor** flow into your application repo. PlanRun npm bundle is **not** required for pure Cursor workflows.

Mapping DSH ↔ Super Cursor → [mapping-from-super-cursor.md](mapping-from-super-cursor.md) · [naming.md](naming.md).

## Workflow guard (after plan approval)

In a project with `.dsh/growth/plan.md` and `PLAN_APPROVED` set:

```sh
pnpm run gate-check
pnpm run plan-check
pnpm run task-verify
pnpm run next-task
```

Details → [workflow-guard.md](workflow-guard.md).

## Common errors

| Symptom | Fix |
|---------|-----|
| `WORKSPACE_PKG_NOT_FOUND` on `dsh plugin add file:…` | Run `pnpm run build` in PlanRun repo; publish uses npm, not `workspace:^` in consumer profile |
| Git install fails, pnpm mentions an ignored build script | The checkout must declare no `prepare`/`prepublish` script — this channel ships committed runtime. Run `pnpm run verify:lib` and commit `packages/*/lib/*.js` |
| Bundle not visible in session | Restart DSH profile after plugin add |
| `gate-check` BLOCK | Set `PLAN_APPROVED` in `.dsh/growth/plan.md` (or `.cursorGrowth/plan.md` when dogfooding PlanRun itself) |
| Skills load but plan path wrong | PlanRun dev uses `.cursorGrowth/plan.md`; normal projects use `.dsh/growth/plan.md` |

## Related

- [publish.md](publish.md) — maintainer npm publish
- [subagents.md](subagents.md) — `planrun` presets
- [workflow-hooks-map.md](workflow-hooks-map.md) — `@planrun/workflow`
