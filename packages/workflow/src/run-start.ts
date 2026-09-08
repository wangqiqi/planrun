import type { PlanSnapshot } from './plan-parser.js'

export function buildRunStartContext(plan: PlanSnapshot | undefined): string | undefined {
  if (!plan) return undefined
  if (plan.planning) {
    return `## PlanRun · plan in progress
- **SPRINT**: \`${plan.sprint || 'unset'}\`
- Load skill \`sprint-plan\`; keep \`PLANNING: true\` until handoff
- Handoff: \`PLANNING: false\` + \`PLAN_APPROVED\` + \`pnpm run plan-check\` + \`pnpm run gate-check\` → \`run\` skill`
  }
  if (plan.gate !== 'OK') {
    return `## PlanRun · run gate blocked (${plan.gate})
- Complete \`sprint-plan\` and set \`PLAN_APPROVED\`
- Run: \`pnpm run gate-check\``
  }
  if (plan.autonomous && plan.active) {
    return `## PlanRun · autonomous Sprint chain
- **SPRINT**: \`${plan.sprint || 'unset'}\` · **ACTIVE**: \`${plan.active}\` (${plan.activeStatus || 'unknown'}) · pending=${plan.pendingCount}
- User authorized **one run** — continue all TASK in this session until decision or sprint done
- **Interrupt only**: decision_needed · blocker · high_risk · release · goal_drift
- **Verify**: \`pnpm run task-verify\`; sprint \`${plan.verifyCmd}\`
- Load \`run\` skill: gate-check → implement → task-verify → commit → next ACTIVE`
  }
  return undefined
}
