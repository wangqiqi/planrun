# PlanRun guard scripts (project-local)

Copied by `install-planrun.sh` into your repo `scripts/` directory.

| Script | Role |
|--------|------|
| `dsh-guard.sh` | `gate-check` · `plan-check` · `task-verify` · `next-task` |
| `plan-parse.sh` | plan.md HTML meta + TASK table parser (sourced by guard) |

Plan resolution (same as `@planrun/workflow`):

1. `DSH_GROWTH_PLAN` env override
2. Walk up from **cwd** for `.dsh/growth/plan.md` or `.cursorGrowth/plan.md`

npm scripts (merged into root `package.json` when present):

```sh
pnpm run gate-check
pnpm run plan-check
pnpm run task-verify
pnpm run next-task
```

See [workflow-guard.md](../../docs/workflow-guard.md).
