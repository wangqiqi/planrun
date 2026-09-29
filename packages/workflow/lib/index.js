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
const loopCounts = new WeakMap();
function projectCwd(agent) {
    return agent.session.header.cwd;
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
        const cwd = projectCwd(agent);
        ensureGrowth(cwd, planrunHome);
        const planPath = resolvePlanPath(cwd, config.planPath);
        const blocks = [
            buildPersonaStartContext(cwd, planrunHome),
            buildRunStartContext(loadPlanSnapshot(planPath)),
        ].filter(Boolean);
        if (blocks.length)
            injectContext(agent, blocks.join('\n\n'));
    });
    ctx.on('agent/pre-step', async ({ agent }, next) => {
        ensureGrowth(projectCwd(agent), planrunHome);
        return next();
    });
    ctx.on('agent/turn-stopping', async ({ agent }) => {
        const planPath = resolvePlanPath(projectCwd(agent), config.planPath);
        const loops = (loopCounts.get(agent) ?? 0) + 1;
        loopCounts.set(agent, loops);
        const steer = buildRunStopSteer({ planPath, loopCount: loops });
        if (steer)
            steerContext(agent, steer);
    });
}
//# sourceMappingURL=index.js.map