# Workflow guard (dsh-guard)

DSH-native replacement for Super Cursor `runner.sh` gates — bash + pnpm scripts, no Cordis plugin required.

Implementation: `scripts/dsh-guard.sh` sources `scripts/plan-parse.sh` for plan HTML meta and TASK table parsing.

## Commands

| Command | Role |
|---------|------|
| `pnpm run gate-check` | Hard gate before **`run`** (`PLANNING` / `PLAN_APPROVED`) |
| `pnpm run plan-check` | Handoff structure warnings (ACTIVE, 执行顺序, VERIFY, …) |
| `pnpm run task-verify` | Run ACTIVE task acceptance (or heuristic fallback) |
| `pnpm run next-task` | Next pending TASK ID from 执行顺序 / table |
| `pnpm run guard` | Status summary (`dsh-guard.sh status`) |
| `pnpm run verify` | Full structural verify (`verify-planrun.sh`) |

Direct CLI:

```sh
bash scripts/dsh-guard.sh gate-check
bash scripts/dsh-guard.sh task-verify TASK-001
```

## Plan file resolution

Priority:

1. `DSH_GROWTH_PLAN` — explicit path
2. Walk up from **current working directory** for `.dsh/growth/plan.md` or `.cursorGrowth/plan.md`
3. Fallback: PlanRun repo root (when `scripts/` live in the planrun checkout)

Target projects: run `install-planrun.sh` to copy guard scripts to `scripts/` and merge npm scripts into `package.json`.

## HTML metadata (SSOT)

Guard reads HTML comments at the top of `plan.md`:

| Key | Purpose |
|-----|---------|
| `PLANNING` | `true` → block run (planning only) |
| `PLAN_APPROVED` | Date string — required for gate-check |
| `SPRINT` | Sprint id (e.g. `SPRINT-04`) |
| `SPRINT_STATUS` | `active` \| `closed` |
| `ACTIVE` | Current TASK id |
| `NEXT` | Suggested next TASK |
| `LAST_DONE` | Last completed TASK |
| `AUTONOMOUS` | `true` → same-session Sprint chain |
| `VERIFY` | Full verify command (default `./scripts/verify-planrun.sh`) |
| `MAX_LOOPS` | Autonomy loop cap (default 15) |

Template: [templates/growth/plan.md](../../templates/growth/plan.md)

## TASK table

Super Cursor–compatible columns:

| ID | Task | Priority | Status | Acceptance | Target |

- **Status**: `⬜` · `🔧` · `✅` (growth template also maps `ACTIVE`/`TODO`/`DONE`)
- **Acceptance**: executable command preferred (`pnpm run verify`, `bash scripts/...`)
- Descriptive acceptance → heuristic fallback (`DSH_GUARD_FALLBACK_VERIFY`, default `./scripts/verify-planrun.sh`)

## Environment

| Variable | Default | Meaning |
|----------|---------|---------|
| `DSH_GROWTH_PLAN` | — | Override plan path |
| `DSH_GUARD_HEURISTICS` | `true` | Fallback when acceptance is descriptive |
| `DSH_GUARD_FALLBACK_VERIFY` | `./scripts/verify-planrun.sh` | Fallback script |

## vs Super Cursor

| Super Cursor | PlanRun guard |
|--------------|-----------------|
| `.cursor/bin/runner.sh` | `scripts/dsh-guard.sh` |
| `.cursor/config/workflow.json` | env + plan HTML meta |
| `.cursorGrowth/plan.md` | `.dsh/growth/plan.md` (+ mother `.cursorGrowth/`) |
| `release-tag` | **`release`** skill (not in guard MVP) |

Future: `@planrun/workflow` Cordis plugin injects session hooks; **guard scripts remain the portable baseline** when the plugin is not mounted.

## Skills

- **`sprint-plan`** — write plan + metadata before run
- **`run`** — `pnpm run gate-check` before coding; `task-verify` before ✅

See [mapping-from-super-cursor.md](mapping-from-super-cursor.md).
