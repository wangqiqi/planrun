# Sprint: <title>

<!-- PlanRun plan mirror — HTML meta is SSOT for dsh-guard; session todos remain authoritative in DSH -->

<!-- PLANNING: true -->
<!-- SPRINT: SPRINT-01 -->
<!-- PLAN_APPROVED: (none) -->
<!-- AUTONOMOUS: false -->
<!-- SPRINT_STATUS: active -->
<!-- ACTIVE: TASK-001 -->
<!-- NEXT: TASK-002 -->
<!-- LAST_DONE: (none) -->
<!-- VERIFY: ./scripts/verify.sh -->
<!-- MAX_LOOPS: 15 -->

**Goal:** Deliver a concrete capability or user-visible increment (not tag-only / verify-only sprints).

**Done when:**

- [ ] …

**Out of scope:** …

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | … | P0 | ⬜ | `./scripts/verify.sh` | `src/...` |
| TASK-002 | … | P0 | ⬜ | … | … |

**执行顺序**: `TASK-001` → `TASK-002`

## Notes

- Set `<!-- PLANNING: false -->` and `<!-- PLAN_APPROVED: YYYY-MM-DD -->` before **`run`**.
- Replace `./scripts/verify.sh` with **your** project's verify command (the acceptance cell
  takes any executable command, or a description when there is nothing to run).
- Only one `ACTIVE` row / `<!-- ACTIVE: ... -->` at a time.
- SPIKE-* = read-only research; DOC-* = docs only.
- Guard: `pnpm run gate-check` · `plan-check` · `task-verify` · `next-task` (see https://znza.top/planrun/en/workflow-guard).
- The `pnpm run` gates exist only in a Node project where `install-planrun.sh` merged the
  guard scripts; otherwise call the locator directly: `node scripts/run-bash.mjs scripts/dsh-guard.sh gate-check`.
