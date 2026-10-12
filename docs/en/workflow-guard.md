# Workflow guard (dsh-guard)

DSH-native replacement for Super Cursor `runner.sh` gates — POSIX shell + pnpm scripts, no Cordis plugin required.

Implementation: `scripts/dsh-guard.sh` sources `scripts/plan-parse.sh` for plan HTML meta and TASK table parsing; `doctor` delegates to the Node modules `scripts/planrun-doctor.mjs` + `scripts/planrun-manifest.mjs`.

## Commands

| Command | Role |
|---------|------|
| `pnpm run gate-check` | Hard gate before **`run`** (`PLANNING` / `PLAN_APPROVED`) |
| `pnpm run plan-check` | Handoff structure warnings (ACTIVE, 执行顺序, VERIFY, …) |
| `pnpm run task-verify` | Run ACTIVE task acceptance (or heuristic fallback) |
| `pnpm run next-task` | Next pending TASK ID from 执行顺序 / table |
| `pnpm run doctor` | Install drift check — guard files · plan template · `@planrun/*` versions vs the version manifest |
| `pnpm run guard` | Status summary (`dsh-guard.sh status`) |
| `pnpm run verify` | Full structural verify (`verify-planrun.sh`) |

Direct CLI:

```sh
bash scripts/dsh-guard.sh gate-check
bash scripts/dsh-guard.sh task-verify TASK-001
bash scripts/dsh-guard.sh doctor --json

# no bash on PATH? run the same scripts through the portable launcher:
node scripts/run-bash.mjs scripts/dsh-guard.sh gate-check
```

## Install drift check (`doctor`)

`install-planrun.sh` writes `.dsh/growth/.planrun-manifest.json` (PlanRun version · guard sha256 · template schema · install time). `doctor` reads it back and reports four checks:

| Check | Fails when |
|-------|-----------|
| `manifest` | manifest missing, unparsable, or written by another schema |
| `guard-files` | a tracked `scripts/*` file was edited after install, or differs from the reference copy |
| `plan-template` | recorded template schema is older than this build, `plan.md` is missing, or core HTML meta is missing |
| `packages` | installed `planrun` / `@planrun/*` versions disagree with each other, with the project record, or with the reference build |

Exit codes: **0** no drift · **1** drift (each FAIL prints a `FIX:` line) · **2** cannot determine (not a PlanRun project). A check with nothing to compare against is `SKIP`, never a fabricated failure — including the npm channel still being unpublished.

Reference copy resolution order: `--expect-guard` → `--source` → `PLANRUN_HOME` → the manifest's `planrunSource` → the DSH profile package. Flags: `--json` (machine output), `--no-profile` (ignore profile packages), `--project <dir>`, `--reference-version x.y.z`.

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
- **One command per cell**: `task-verify` strips the backticks and `eval`s the whole cell as one command. Write a single command, or `bash -c 'a && b'` for a sequence — `cmd1 + cmd2` runs as one broken command.
- **No bare `|` inside a cell**: it adds a field and shifts every positional column (`$5` status · `$6` acceptance · `$7` target). A row whose field count differs from the header is a hard `plan-check` FAIL, and `task-verify` **refuses to verify it** instead of falling back to heuristic verify. Write `{en,zh}` rather than `en|zh`.
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
