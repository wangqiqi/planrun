---
name: long
description: >-
  Long-horizon Epic scheduling (/long): Epic→Sprint→Task convergence, multi-Sprint
  sprint-plan/run chains, checkpoints. Not single-Sprint AUTONOMOUS (use run).
disable-model-invocation: true
user-invocable: true
---

# long

**用这个**：跨多个 Sprint 的大目标 — 总规划 → 分 Sprint → 每 Sprint **`sprint-plan`** + **`run`** → 归档 → 下一 Sprint。**不是那个**：单 Sprint 连跑 → **`sprint-plan`** + **`run`** 一次；学新技术 → **`study`**（v0.2+）。

Details: [reference/hierarchy.md](reference/hierarchy.md) · [reference/pacing-checkpoint.md](reference/pacing-checkpoint.md)

## When to enter

- user **`/long <Epic goal>`** or「长程开发」「多 Sprint 做到底」
- **`/long resume`** — read `.dsh/growth/long-state.json`
- **`master`** keyword route

**Existing single-Sprint ACTIVE** and user only says **`run`** → do **not** intercept; continue **`run`**.

## Three-layer limits

| layer | limit | carrier |
|-------|-------|---------|
| Epic → Sprint | ≤5 | `long-state.json` |
| Sprint → Task | ≤5 | `.dsh/growth/plan.md` |
| Task depth | L2 only | no sub-task IDs |

Overflow → merge abstractly or split Epics. See [hierarchy.md](reference/hierarchy.md).

## Flow

### 1. Epic planning (L0)

1. read `.dsh/growth/learn/` · plan candidates · user goal
2. write/update `.dsh/growth/long-state.json` ([schema](reference/pacing-checkpoint.md#long-statejson))
3. split **≤5** Sprints (Goal + dependency each); **`ask_user_question`** confirm (≤4 options)
4. `status: active` · `active_sprint_index: 0`

If user already approved「自动 plan 并连跑」→ still persist long-state.

### 2. Sprint loop (L1)

For each `sprints[i]`, **in order**:

| step | action | skill |
|------|--------|-------|
| a | Goal · Done when · Out of scope | **`sprint-plan`** phase 1 |
| b | TASK table ≤5 + order | **`sprint-plan`** phase 2 |
| c | handoff: user confirms; one ACTIVE | **`sprint-plan`** phase 3 |
| d | implement all TASKs | **`run`** (same session; do not wait for second **`run`**) |
| e | verify · archive · plan reconciliation · long checkpoint | **`run`** closeout + [pacing-checkpoint.md](reference/pacing-checkpoint.md) |
| f | `active_sprint_index++` · next Sprint or Epic `completed` | |

Between Sprints: optional pause; cross-day use **`/long resume`**.

### 3. Resume

1. read `long-state.json` + `.dsh/growth/plan.md`
2. `paused` / interrupt → explain `interrupt_reason`; confirm with user
3. open Sprint → continue **`run`** (ACTIVE)
4. closed Sprint → **`sprint-plan`** for next Sprint (steps 2a–f)

Project verify must pass before marking Sprint ✅ (v0.3: `@dsh-super/workflow` guard).

## Division of labor

| component | role |
|-----------|------|
| **long** | Epic shell · Sprint order · checkpoint · resume |
| **sprint-plan** | single Sprint Goal/TASK/handoff |
| **run** | TASK implementation · verify · commit |

## Decision interrupts

| type | long action |
|------|-------------|
| `decision_needed` | `paused` + `interrupt_reason` |
| `blocker` | same; user **`sprint-plan`** then resume |
| `high_risk` | user confirm required |
| `goal_drift` | stop Epic; explain drift |
| `release` | **`release`** (v0.2+) or explicit user |

**Non-interrupts**: TASK switch · commit · CHANGELOG · README within Sprint.

## Forbidden

- skip verify before ✅
- silent new TASK/Sprint mid-run
- infinite task-tree generation

## Acceptance (mother repo)

When changing `skills/long/` in dsh-super: `pnpm run verify` green; Epic complete → `long-state.status: completed` · no Active block in plan mirror.
