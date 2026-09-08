---
name: scaffold
description: >-
  Scaffold new or empty projects: detect stack, dry-run templates, apply with user
  confirmation. Mother-repo CLI only. Say 初始化 / 创建项目 / scaffold.
disable-model-invocation: true
user-invocable: true
---

# scaffold

Catalog: [catalog.md](catalog.md)

**Mother repo only (contributor / planrun checkout)**:

- Templates: `$PLANRUN_HOME/.cursor/templates/scaffold/` (or planrun root `.cursor/templates/scaffold/`)
- CLI: `$PLANRUN_HOME/.cursor/bin/scaffold.sh`

**Not shipped** in `@planrun/skill-provider` npm package. Pure DSH target projects without a checkout → see [catalog.md §Pure DSH projects](catalog.md#pure-dsh-projects-no-cursor).

**Gate**: scaffolding is **user-authorized** repo initialization. Empty repo (`detect` → `state=empty`) may run without a plan mirror. **Existing code** requires `audit` + `ask_user_question`, default `--dry-run`, no silent overwrite.

## Triggers

- user says「初始化项目」「创建脚手架」「空仓库怎么开始」
- **`sprint-plan`** phase: new repo → confirm stack → apply or `TASK-001` acceptance
- always communicate before mutating files

## Flow (empty project)

1. **Detect** (from planrun checkout):

```bash
export PLANRUN_HOME=/path/to/planrun
"$PLANRUN_HOME/.cursor/bin/scaffold.sh" detect
"$PLANRUN_HOME/.cursor/bin/scaffold.sh" list
```

2. **`ask_user_question`** (stack, package manager, optional bundles — ≤4 options per round; if tool unavailable → numbered prose options per **`master`**)

| Question | examples |
|----------|----------|
| project type | frontend · backend · systems |
| stack | `react-vite-ts` · `go-api` · `python-fastapi` · … (see catalog) |
| growth seeds | run **`install-planrun.sh --here --copy-plan`** after scaffold? |

3. **Preview** — before apply:

```bash
"$PLANRUN_HOME/.cursor/bin/scaffold.sh" info <id>
"$PLANRUN_HOME/.cursor/bin/scaffold.sh" apply <id> --dry-run
```

List CREATE / SKIP files; explain `post_apply` and verify.

4. **Apply** — only after explicit user「确认 / apply」:

```bash
"$PLANRUN_HOME/.cursor/bin/scaffold.sh" apply <id>
```

5. **Closeout**

- run manifest `post_apply`
- `./scripts/verify.sh` or project equivalent
- **`install-planrun.sh --here --copy-plan`** → `.dsh/growth/plan.md`
- **`learn`** → write stack conventions to `.dsh/growth/learn/dev-conventions.md`
- **`sprint-plan`** → first Sprint if multi-step work remains

## Flow (existing project)

1. `detect` + `audit` — no direct apply
2. Report structure · deps · quality (lint/test/CI/README/plan mirror)
3. `ask_user_question`: full scaffold · add `scripts/verify.sh` only · advice only
4. `--dry-run` → confirm → apply (**no `--force`** unless user explicitly requests)
5. align with **`learn`** for project-specific conventions

## With sprint-plan / run

| scenario | approach |
|----------|----------|
| empty repo first | scaffold confirm → apply → **`sprint-plan`** |
| planned init | Sprint `TASK-001` acceptance: scaffold apply + verify |
| advice only | `SPIKE-*` research, archive, then `TASK-*` |

**`run`** scaffold tasks still require clear Goal / ACTIVE row in `.dsh/growth/plan.md`.

## Forbidden

- apply without confirmation (especially `established` repos)
- default `--force` overwrite
- project-specific paths in mother templates (use **`learn`** or team docs)
