import { hasWarningTask, loadPlanSnapshot, nextTaskId, readPlanContent, type PlanSnapshot } from './plan-parser.js'

export interface RunStopInput {
  readonly planPath: string
  readonly loopCount: number
}

export function buildRunStopSteer(input: RunStopInput): string | undefined {
  const plan = loadPlanSnapshot(input.planPath)
  if (!plan || !plan.autonomous) return undefined
  if (input.loopCount >= plan.maxLoops) {
    return `PlanRun: MAX_LOOPS=${plan.maxLoops}. Review plan and continue manually.`
  }
  if (plan.gate !== 'OK') {
    return plan.gate === 'NO_APPROVAL'
      ? 'PlanRun gate: missing PLAN_APPROVED. Run sprint-plan first.'
      : 'PlanRun gate: PLANNING=true. Complete plan handoff first.'
  }
  const content = readPlanContent(input.planPath)
  if (hasWarningTask(content)) {
    return 'PlanRun: plan has ⚠️ tasks. Re-plan before continuing.'
  }
  const { active, activeStatus, pendingCount } = plan
  if (activeStatus === '🔧' || activeStatus === '⬜') {
    return `PlanRun AUTONOMOUS: continue ACTIVE \`${active}\` in this session — gate-check → implement → task-verify → commit. Do not wait for another run.`
  }
  if (activeStatus === '✅' && pendingCount > 0) {
    const next = nextTaskId(content, active)
    return `PlanRun AUTONOMOUS chain: \`${active}\` done → continue \`${next}\` immediately. No second run unless decision needed.`
  }
  if (!active && pendingCount > 0) {
    const next = nextTaskId(content, '')
    return `PlanRun AUTONOMOUS chain: continue \`${next}\` immediately.`
  }
  if (pendingCount === 0) {
    return 'PlanRun AUTONOMOUS: sprint complete — verify, archive, reconcile plan. Ask user about release if needed.'
  }
  return undefined
}
