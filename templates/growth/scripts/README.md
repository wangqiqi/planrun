# PlanRun guard scripts (project-local)

Copied by `install-planrun.sh` into your repo `scripts/` directory.

| Script | Role |
|--------|------|
| `dsh-guard.sh` | `gate-check` · `plan-check` · `task-verify` · `next-task` |
| `plan-parse.sh` | plan.md HTML meta + TASK table parser (sourced by guard) |
| `planrun-manifest.mjs` | records the installed PlanRun version + guard sha256 → `.dsh/growth/.planrun-manifest.json` |
| `planrun-doctor.mjs` | drift check: guard files · plan template · installed `@planrun/*` versions (`doctor`) |
| `run-bash.mjs` | locates a working POSIX shell, so the npm scripts work on Windows too |

Plan resolution (same as `@planrun/workflow`):

1. `DSH_GROWTH_PLAN` env override
2. Walk up from **cwd** for `.dsh/growth/plan.md` or `.cursorGrowth/plan.md`

npm scripts (merged into root `package.json` when present — each one runs
`node scripts/run-bash.mjs scripts/dsh-guard.sh <command>`, so no `bash` on `PATH`
is required):

```sh
pnpm run gate-check
pnpm run plan-check
pnpm run task-verify
pnpm run next-task
```

Docs: <https://znza.top/planrun/en/workflow-guard> — linked by URL because this
file also ships inside `@planrun/workflow`'s `templates/`, where a
repo-relative `../../../docs/...` link would not resolve.
