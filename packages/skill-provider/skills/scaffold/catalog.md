# Scaffold catalog (planrun)

**Contributor note**: stack templates and `scaffold.sh` live in the **planrun mother repo** at `.cursor/templates/scaffold/` and `.cursor/bin/scaffold.sh`. They are **not** shipped inside `@planrun/skill-provider` npm files.

Source manifest: planrun checkout → `.cursor/templates/scaffold/manifest.json` · tier: **standard+** (lint/test/verify/README + CI + `.env.example`)

| id | category | tests | loop |
|----|----------|-------|------|
| `react-vite-ts` | frontend | Vitest+RTL · `tests/` | test.sh → verify.sh |
| `vue-vite-ts` | frontend | Vitest · `tests/` | same |
| `nextjs-ts` | frontend | Vitest · App Router | same |
| `go-api` | backend | `tests/integration` + internal | same |
| `rust-axum` | backend | `tests/*.rs` · `app()` | same |
| `python-fastapi` | backend | unit+integration · pytest | same |
| `cpp-cmake` | systems | GoogleTest · `tests/` | same |

## Skill vs templates vs rules

| kind | path (mother repo) | role |
|------|-------------------|------|
| **skill** | `packages/skill-provider/skills/scaffold/SKILL.md` | detect → `ask_user_question` → dry-run → apply |
| **templates** | `.cursor/templates/scaffold/<id>/` | project skeleton files |
| **rules** | `.cursor/rules/tech/*.mdc` | post-scaffold coding SOP (Cursor mother repo only) |

## post_apply

After apply, run manifest `post_apply`, then `./scripts/verify.sh`.

| id | key steps |
|----|-----------|
| react / vue / nextjs | `npm install` → verify |
| go-api | fix `go.mod` module path → `go mod tidy` → verify |
| rust-axum | `cargo test` → verify |
| python-fastapi | venv → `pip install -e '.[dev]'` → verify |
| cpp-cmake | verify (cmake build + ctest) |

## Pure DSH projects (no `.cursor/`)

When the target has only `.dsh/growth/` and harness skills:

1. Use **`install-planrun.sh --here`** for growth seeds
2. For greenfield app stacks, either work from a **planrun checkout** (`$PLANRUN_HOME/.cursor/bin/scaffold.sh`) or hand-roll README + verify per stack conventions
3. Do **not** assume `scaffold.sh` exists in the target repo

## Extension

Unlisted stacks (Spring Boot, Django, …): after `ask_user_question`, hand-write standard+ layout or contribute a new template id to the mother repo.
