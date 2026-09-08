---
name: sprint-plan
description: >-
  Sprint and multi-task planning for planrun. Use when breaking down goals into
  TASKs, writing .dsh/growth/plan.md, or SPIKE/DOC work. Not DSH /plan plan mode
  (single-task design). No business code in this skill.
disable-model-invocation: true
user-invocable: true
---

# sprint-plan

**Not DSH plan mode.** DSH `/plan` explores one task and exits through `exit_plan_mode`. This skill owns **multi-task / Sprint** planning and the `.dsh/growth/plan.md` mirror.

Standing discipline: [docs/discipline.md](../../../docs/discipline.md)

**Persona**: planning tone follows active session persona; technical gates unchanged.

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
3. **Write** `.dsh/growth/plan.md` from [templates/growth/plan.md](../../../templates/growth/plan.md) — include HTML metadata block (`PLANNING`, `PLAN_APPROVED`, `ACTIVE`, `VERIFY`, …).
4. **Set** `<!-- PLANNING: false -->` and `<!-- PLAN_APPROVED: YYYY-MM-DD -->` after user confirms.
5. **Mark** `<!-- ACTIVE: TASK-xxx -->` (and one table row `⬜`/`🔧`) for **`run`**.
6. **Hand off** — user loads **`run`** or continues in the same session.

## Gate before run

```sh
pnpm run gate-check   # BLOCK → stay in sprint-plan
pnpm run plan-check   # handoff structure
```

See [docs/workflow-guard.md](../../../docs/workflow-guard.md).

## plan.md mirror format

```markdown
<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-09-08 -->
<!-- ACTIVE: TASK-001 -->
<!-- VERIFY: pnpm run verify -->

**Goal:** …

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | … | P0 | ⬜ | `pnpm run verify` | … |
```

**执行顺序**: `TASK-001` → `TASK-002`

Status values: `⬜` · `🔧` · `✅` (or `ACTIVE`/`TODO`/`DONE` in simplified tables)

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
