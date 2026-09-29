/**
 * PlanRun workflow Cordis plugin — DSH hooks parity for growth-init, run-start, run-stop.
 *
 * @module @planrun/workflow
 */
import { createUserMessage } from './dsh-shim.js';
import { ensureGrowth, resolvePlanrunHome } from './growth.js';
import { buildRunStartContext } from './run-start.js';
import { buildRunStopSteer } from './run-stop.js';
import { loadPlanSnapshot, resolvePlanPath } from './plan-parser.js';
import { buildPersonaStartContext } from './persona.js';
// Session format v4 refuses the retired catch-all `kind: 'plugin'` wrapper and
// requires a producer-owned kind; see assertV4MessageSources in dsh itself.
const PLUGIN_SOURCE = { kind: 'planrun-workflow' };
export const name = 'planrun-workflow';
/** DSH's plan-mode exit tool (`@deepseek-ai/dsh-plan-mode`). */
const EXIT_PLAN_MODE = 'exit_plan_mode';
const loopCounts = new WeakMap();
function projectCwd(agent) {
    return agent.session.header.cwd;
}
/**
 * Whether DSH plan mode owns this agent's turn.
 *
 * Plan mode's policy is "explore and plan, do not implement". PlanRun's
 * autonomous chain says the opposite ("continue ACTIVE, commit"), so both the
 * run-start injection and the turn-stopping steer must stand down while plan
 * mode is in force — otherwise the two policies fight inside one turn.
 *
 * Looked up through `ctx.get` instead of `inject`: a profile without
 * `@deepseek-ai/dsh-plan-mode` must still mount the workflow plugin. A pending
 * `/plan on` counts as active so the turn it applies to is not steered.
 */
function planModeActive(ctx, agent) {
    const planMode = ctx.get('planMode');
    if (planMode === undefined)
        return false;
    try {
        const state = planMode.get(agent);
        return state.active || state.pending === true;
    }
    catch {
        return false;
    }
}
/** What PlanRun injects at `agent/created`, given the current mode. */
function startBlocks(ctx, agent, planrunHome, config) {
    const cwd = projectCwd(agent);
    const persona = buildPersonaStartContext(cwd, planrunHome);
    if (planModeActive(ctx, agent)) {
        return [
            persona,
            '## PlanRun · paused for DSH plan mode\n'
                + '- Plan mode owns this turn: plan only, do not implement\n'
                + '- PlanRun will not push the autonomous Sprint chain until plan mode ends\n'
                + `- Finish the plan, exit plan mode (\`${EXIT_PLAN_MODE}\` or \`/plan off\`), then load \`run\``,
        ].filter(Boolean);
    }
    const planPath = resolvePlanPath(cwd, config.planPath);
    return [persona, buildRunStartContext(loadPlanSnapshot(planPath))].filter(Boolean);
}
function steerContext(agent, text) {
    agent.steer(createUserMessage({
        content: [{ type: 'text', text }],
        source: PLUGIN_SOURCE,
    }));
}
function injectContext(agent, text) {
    agent.inject(createUserMessage({
        content: [{ type: 'text', text }],
        source: PLUGIN_SOURCE,
    }));
}
export function apply(ctx, config = {}) {
    if (config.enabled === false)
        return;
    const planrunHome = resolvePlanrunHome(config.planrunHome);
    // DSH renamed this lifecycle hook from `agent/session-start` to
    // `agent/created` on 2026-09-09; the old name is never emitted.
    ctx.on('agent/created', ({ agent }) => {
        loopCounts.set(agent, 0);
        ensureGrowth(projectCwd(agent), planrunHome);
        const blocks = startBlocks(ctx, agent, planrunHome, config);
        if (blocks.length)
            injectContext(agent, blocks.join('\n\n'));
    });
    ctx.on('agent/pre-step', async ({ agent }, next) => {
        ensureGrowth(projectCwd(agent), planrunHome);
        return next();
    });
    ctx.on('agent/turn-stopping', async ({ agent }) => {
        // Plan mode plans; the autonomous chain implements. Never both.
        if (planModeActive(ctx, agent))
            return;
        const planPath = resolvePlanPath(projectCwd(agent), config.planPath);
        const loops = (loopCounts.get(agent) ?? 0) + 1;
        loopCounts.set(agent, loops);
        const steer = buildRunStopSteer({ planPath, loopCount: loops });
        if (steer)
            steerContext(agent, steer);
    });
}
//# sourceMappingURL=index.js.map