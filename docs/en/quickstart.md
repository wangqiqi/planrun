# Quickstart

End-to-end install (paths, prerequisites, three install paths) → **[install.md](install.md)**.

## 1. Build

```sh
git clone https://github.com/wangqiqi/planrun.git planrun && cd planrun
pnpm install
pnpm run build
pnpm run verify
```

The harness packages are **optional peer dependencies** resolved from your DSH profile, not bundled here: `skill-provider` and `workflow` both declare `@deepseek-ai/cordis` `^4.0.0`, and `workflow` additionally `@deepseek-ai/dsh-agent` / `@deepseek-ai/dsh-llm`. No sibling `deepseek-harness` checkout is needed to build (only `verify:dogfood`, §5).

## 2. Install the bundle

**From GitHub, pinned (recommended — the only channel that works today)** — no npm registry, no build permission (the runtime is committed):

```sh
dsh plugin --profile web add "github:wangqiqi/planrun#<tag>"   # current release: #v1.9.0
```

**From npm (not published yet)** — `@planrun/bundle` returns 404 on `registry.npmjs.org`, so this command starts working only after the maintainer publishes the scope (steps in [publish.md](publish.md)):

```sh
dsh plugin --profile web add @planrun/bundle
```

**From this repo** (`pack-local.sh` builds, then rewrites the `workspace:^` deps to `file:`):

```sh
export PLANRUN_HOME=/path/to/planrun
"$PLANRUN_HOME/scripts/pack-local.sh"
dsh plugin --profile web add "file:$PLANRUN_HOME/dist-local/bundle-planrun"
```

## 3. Project growth templates

```sh
./scripts/install-planrun.sh --here
```

Creates `.dsh/growth/` at the Git project root.

## 4. Use in a session

With the **standard** preset:

| Situation | Load |
|---|---|
| Unsure which workflow | `master` |
| Multi-task / Sprint planning | `sprint-plan` |
| Execute ACTIVE tasks | `run` |
| PR / code review | `review` |
| Single-task design | DSH **`/plan`** (plan mode) |

## 5. Structural dogfood

```sh
export PLANRUN_HOME=/path/to/planrun
export DEEPSEEK_HARNESS_HOME=/path/to/deepseek-harness
pnpm run build
pnpm run verify:dogfood
```

See [dogfood.md](dogfood.md). `pnpm run verify` does not require `DEEPSEEK_HARNESS_HOME`.

## 6. Super Cursor mapping

See [mapping-from-super-cursor.md](mapping-from-super-cursor.md) and [naming.md](naming.md).

中文: [zh/quickstart](../zh/quickstart.md)
