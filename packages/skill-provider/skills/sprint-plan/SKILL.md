---
name: sprint-plan
description: >-
  Sprint and multi-task planning for dsh-super. Use when breaking down goals into
  TASKs, writing .dsh/growth/plan.md, or SPIKE/DOC work. Not DSH /plan plan mode
  (single-task design). No business code in this skill.
disable-model-invocation: true
user-invocable: true
---

# sprint-plan

**Not DSH plan mode.** DSH `/plan` explores one task and exits through `exit_plan_mode`. This skill owns **multi-task / Sprint** planning and the `.dsh/growth/plan.md` mirror.

Standing discipline: [docs/discipline.md](../../../docs/discipline.md)

## Scale gate · plan ≥ 5 items

| Condition | Action |
|---|---|
| More than **5** tasks or unclear scope | Write/update `.dsh/growth/plan.md` (Goal · Done when · TASK table), get user confirmation, then load **`run`** |
| ≤5 and scope is clear | May execute inline; still prefer a short plan mirror |

Do not keep a 6+ step checklist only in chat.

## Sprint Goal quality

Sprint Goal = **capability / module / user-visible increment**. Not: tag-only, CHANGELOG-only, or verify-only sprints.

## Workflow

1. **Clarify** Goal and Done-when with `ask_user_question` when ambiguous.
2. **Decompose** into TASK rows with IDs (`TASK-001`, `SPIKE-001`, `DOC-001`).
3. **Write** `.dsh/growth/plan.md` from [templates/growth/plan.md](../../../templates/growth/plan.md).
4. **Mark** one row `ACTIVE` for `run`.
5. **Hand off** — user loads **`run`** or continues in the same session.

## plan.md mirror format

```markdown
# Sprint: <title>

**Goal:** …
**Done when:** …

| ID | Status | Target | Verify |
|---|---|---|---|
| TASK-001 | ACTIVE | … | `pnpm test` … |
```

Status values: `ACTIVE` · `TODO` · `DONE` · `BLOCKED`

## SPIKE / DOC

- **SPIKE-*** — read-only research; no production code
- **DOC-*** — documentation-only tasks

## Relationship to DSH plan mode

| Need | Use |
|---|---|
| One feature / one PR design | DSH **`/plan`** + `exit_plan_mode` |
| Multi-day Sprint / many TASKs | **`sprint-plan`** + `.dsh/growth/plan.md` |

## v0.2 references (Super Cursor parity)

Phases, SDD, autonomy chain, prioritization — migrate from Super Cursor `plan/reference/` in a later release.
