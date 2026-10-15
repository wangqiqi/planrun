import { hasWarningTask, loadPlanSnapshot, nextTaskId, readPlanContent } from './plan-parser.js';
export function buildRunStopSteer(input) {
    const plan = loadPlanSnapshot(input.planPath);
    if (!plan || !plan.autonomous)
        return undefined;
    // Sprint 已闭合且无待办：自治链无活可派，**必须返回 undefined**。
    //
    // 少了这道守卫，收尾后的会话会被无限带起：`pendingCount === 0` 分支每轮 steer 一次
    // （"sprint complete — verify, archive, reconcile plan"），到 MAX_LOOPS 之后改由
    // MAX_LOOPS 分支继续 steer —— 而**每一条 steer 都会再触发一次 turn-stopping**，
    // 于是 loopCount 只增不减，会话永远停不下来。
    //
    // 与 `.cursor/hooks/run-stop.sh` 的 `plan_autonomous_chain_idle` 同义，且同样
    // **先于 MAX_LOOPS 判定**（那边注释：避免收尾后反复 followup）。
    if (plan.sprintStatus === 'closed' && plan.pendingCount === 0)
        return undefined;
    if (input.loopCount >= plan.maxLoops) {
        return `PlanRun: MAX_LOOPS=${plan.maxLoops}. Review plan and continue manually.`;
    }
    if (plan.gate !== 'OK') {
        return plan.gate === 'NO_APPROVAL'
            ? 'PlanRun gate: missing PLAN_APPROVED. Run sprint-plan first.'
            : 'PlanRun gate: PLANNING=true. Complete plan handoff first.';
    }
    const content = readPlanContent(input.planPath);
    if (hasWarningTask(content)) {
        return 'PlanRun: plan has ⚠️ tasks. Re-plan before continuing.';
    }
    const { active, activeStatus, pendingCount } = plan;
    if (activeStatus === '🔧' || activeStatus === '⬜') {
        return `PlanRun AUTONOMOUS: continue ACTIVE \`${active}\` in this session — gate-check → implement → task-verify → commit. Do not wait for another run.`;
    }
    if (activeStatus === '✅' && pendingCount > 0) {
        const next = nextTaskId(content, active);
        return `PlanRun AUTONOMOUS chain: \`${active}\` done → continue \`${next}\` immediately. No second run unless decision needed.`;
    }
    if (!active && pendingCount > 0) {
        const next = nextTaskId(content, '');
        return `PlanRun AUTONOMOUS chain: continue \`${next}\` immediately.`;
    }
    if (pendingCount === 0) {
        return 'PlanRun AUTONOMOUS: sprint complete — verify, archive, reconcile plan. Ask user about release if needed.';
    }
    return undefined;
}
//# sourceMappingURL=run-stop.js.map