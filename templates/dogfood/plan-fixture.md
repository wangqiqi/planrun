# Sprint: dogfood fixture

<!-- PlanRun dogfood fixture — SSOT for verify-dogfood guard loop; not a live sprint -->

<!-- PLANNING: false -->
<!-- SPRINT: DOGFOOD-FIXTURE -->
<!-- PLAN_APPROVED: 2026-09-08 -->
<!-- AUTONOMOUS: true -->
<!-- SPRINT_STATUS: active -->
<!-- ACTIVE: TASK-001 -->
<!-- NEXT: TASK-002 -->
<!-- LAST_DONE: (none) -->
<!-- VERIFY: pnpm run verify -->
<!-- MAX_LOOPS: 15 -->

**Goal:** Validate PlanRun guard and skill routing on a harness-shaped project without interactive `dsh web`.

**Done when:**

- [ ] `gate-check` passes on this fixture
- [ ] `next-task` resolves TASK-002 while TASK-001 is ACTIVE

**Out of scope:** Modifying deepseek-harness upstream sources.

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | Guard gate on fixture | P0 | ⬜ | `pnpm run gate-check` with `DSH_GROWTH_PLAN` set | `templates/dogfood/` |
| TASK-002 | Next task resolution | P0 | ⬜ | `pnpm run next-task` prints `TASK-002` | `scripts/dsh-guard.sh` |

**执行顺序**: `TASK-001` → `TASK-002`

## Notes

- Used only by `scripts/verify-dogfood.sh` via `DSH_GROWTH_PLAN`.
- SPIKE-* / DOC-* rows are skipped by `next-task` when present.
