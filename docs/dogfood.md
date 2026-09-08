# Harness dogfood (structural)

PlanRun **structural dogfood** validates bundle artifacts, 16 bundled skills, growth install, and the guard loop (`gate-check` · `plan-check` · `next-task`) against a local **deepseek-harness** checkout — **without** interactive `dsh web`.

For interactive sessions (load `master` · `sprint-plan` · `run`), see [quickstart.zh.md](quickstart.zh.md) §6.

## Prerequisites

| Variable | Required | Description |
|----------|----------|-------------|
| `DEEPSEEK_HARNESS_HOME` | **Yes** | Path to a `deepseek-harness` git checkout (must contain `.git`) |
| `PLANRUN_HOME` | No | PlanRun repo root (defaults to parent of `scripts/`) |

Build PlanRun packages first:

```sh
cd "$PLANRUN_HOME"
pnpm install
pnpm run build
```

## Run structural dogfood

```sh
export DEEPSEEK_HARNESS_HOME=/path/to/deepseek-harness
export PLANRUN_HOME=/path/to/planrun   # optional

pnpm run verify:dogfood
# or: ./scripts/verify-dogfood.sh
```

| Outcome | Meaning |
|---------|---------|
| Exit **1** + `DEEPSEEK_HARNESS_HOME 未设置` | Explicit dogfood run without env (expected) |
| Exit **1** + missing `.git` / invalid path | Fix checkout path |
| Exit **0** + `verify-dogfood: OK` | Structural loop green |

`pnpm run verify` does **not** invoke dogfood — CI without a harness checkout stays green.

## What is checked

1. **Harness layout** — root `package.json` or `AGENTS.md`
2. **Plan fixture** — `templates/dogfood/plan-fixture.md` (HTML meta + TASK table)
3. **Guard loop** — `DSH_GROWTH_PLAN=<fixture>` → `gate-check` · `plan-check` · `next-task`
4. **Bundle artifacts** — `bundle-planrun` · `skill-provider` · `workflow` `lib/` after `pnpm run build`
5. **16 skills** — disk inventory + `master/routes.md` references
6. **Install seed** — `install-planrun.sh` creates `.dsh/growth/` on a temp git root (does not modify harness)

## Guard fixture SSOT

`templates/dogfood/plan-fixture.md` is the **single source of truth** for automated guard tests. The harness repo may keep its own `.dsh/growth/plan.md`; dogfood does not require changing upstream harness files.

## Interactive dogfood (manual)

When `dsh` CLI is available:

```sh
export PLANRUN_HOME=/path/to/planrun
dsh plugin --profile web add "file:$PLANRUN_HOME/packages/bundle-planrun"
# restart dsh web · use planrun preset · load master / sprint-plan / run
```

See [quickstart.zh.md](quickstart.zh.md) for full install steps.

## Related

- [workflow-guard.md](workflow-guard.md) — `dsh-guard.sh` commands
- [workflow-hooks-map.md](workflow-hooks-map.md) — `@planrun/workflow` hook mapping
