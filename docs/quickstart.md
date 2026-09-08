# Quickstart

End-to-end install (paths, prerequisites, three install paths) → **[install.md](install.md)**.

## 1. Build

```sh
git clone https://github.com/wangqiqi/planrun.git planrun && cd planrun
pnpm install
pnpm run build
pnpm run verify
```

DevDependencies point at sibling `deepseek-harness` for `@deepseek-ai/cordis` and `@deepseek-ai/dsh-skill`.

## 2. Install the bundle

**Published (recommended)**:

```sh
dsh plugin --profile web add @planrun/bundle
```

See [publish.md](publish.md) for maintainer steps.

**From this repo** (run `pnpm run build` first):

```sh
export PLANRUN_HOME=/path/to/planrun
dsh plugin --profile web add "file:$PLANRUN_HOME/packages/bundle-planrun"
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

中文: [quickstart.zh.md](quickstart.zh.md)
