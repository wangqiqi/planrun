---
name: master
description: >-
  Router when unsure which dsh-super workflow to use. Load for help, ambiguous goals,
  or new sessions. Routes to sprint-plan, run, learn, review, and release — does not
  execute downstream work itself.
user-invocable: true
disable-model-invocation: true
---

# master · Router

**Daily loop: `sprint-plan` ↔ `run`. When lost, load `master`.** Other skills (`review`, `security`, `delivery`, …) are chosen from the Sprint Goal and Done-when in `.dsh/growth/plan.md`.

**Route only — never substitute for downstream skills.** After routing, hand off and tell the user which skill to load next.

Canonical route table: [routes.md](routes.md)

## When to load

- User says they are lost or asks what to do next
- Goal is clear but no workflow is named (scaffold, ship, verify failed, empty repo)
- New session right after `install-super-dsh.sh`

**Do not intercept** when the user already named a skill (`sprint-plan`, `run`, `review`) or DSH plan mode (`/plan` for single-task design).

## Flow

1. **Quick sense** (optional): read `.dsh/growth/plan.md`, `git status`, project scripts — do not dump internals to the user.
2. **ask_user_question** when the choice is genuinely ambiguous (≤7 options). If unavailable, numbered prose options.
3. **Hand off** with one concrete next skill name.

## Primary routes

| Intent | Skill | Notes |
|---|---|---|
| New / empty project | `scaffold` (v0.2) | Not bundled in v0.1 |
| Sprint / multi-task planning | `sprint-plan` | Not DSH `/plan` plan mode |
| Continue implementation | `run` | Requires approved plan mirror |
| Learn this repo | `learn` (v0.2) | Project conventions |
| Bug / verify blocked | `run` or `sprint-plan` | Re-plan if scope drift |
| Ship / release | `release` (v0.2) | After Sprint done |
| Code / PR review | `review` | Read-only checklist |

Full table: [routes.md](routes.md)

## Discipline

Standing rules live in [docs/discipline.md](../../../docs/discipline.md) at the dsh-super repo root (or project `AGENTS.md` snippet after install).
