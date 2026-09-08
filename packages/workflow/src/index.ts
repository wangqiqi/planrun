/**
 * PlanRun workflow Cordis plugin — DSH hooks parity for growth-init, run-start, run-stop.
 *
 * @module @planrun/workflow
 */

import type { Agent, Context } from './dsh-shim.js'
import { createUserMessage } from './dsh-shim.js'
import { ensureGrowth, resolvePlanrunHome } from './growth.js'
import { buildRunStartContext } from './run-start.js'
import { buildRunStopSteer } from './run-stop.js'
import { loadPlanSnapshot, resolvePlanPath } from './plan-parser.js'
import { buildPersonaStartContext } from './persona.js'

const PLUGIN_SOURCE = { kind: 'plugin' as const, plugin: 'planrun-workflow' }

export interface Config {
  /** When false, register no listeners (guard scripts remain baseline). */
  enabled?: boolean
  /** Override PlanRun repo root for growth templates. */
  planrunHome?: string
  /** Explicit plan.md path override. */
  planPath?: string
}

export const name = 'planrun-workflow'

export const inject = ['sessionProjections']

const loopCounts = new WeakMap<Agent, number>()

function projectCwd(agent: Agent): string {
  return agent.session.header.cwd
}

function steerContext(agent: Agent, text: string): void {
  agent.steer(
    createUserMessage({
      content: [{ type: 'text', text }],
      source: PLUGIN_SOURCE,
    }),
  )
}

function injectContext(agent: Agent, text: string): void {
  agent.inject(
    createUserMessage({
      content: [{ type: 'text', text }],
      source: PLUGIN_SOURCE,
    }),
  )
}

export function apply(ctx: Context, config: Config = {}): void {
  if (config.enabled === false) return
  const planrunHome = resolvePlanrunHome(config.planrunHome)

  ctx.on('agent/session-start', ({ agent }) => {
    loopCounts.set(agent, 0)
    const cwd = projectCwd(agent)
    ensureGrowth(cwd, planrunHome)
    const planPath = resolvePlanPath(cwd, config.planPath)
    const blocks = [
      buildPersonaStartContext(cwd, planrunHome),
      buildRunStartContext(loadPlanSnapshot(planPath)),
    ].filter(Boolean) as string[]
    if (blocks.length) injectContext(agent, blocks.join('\n\n'))
  })

  ctx.on('agent/pre-step', async ({ agent }, next) => {
    ensureGrowth(projectCwd(agent), planrunHome)
    return next()
  })

  ctx.on('agent/turn-stopping', async ({ agent }) => {
    const planPath = resolvePlanPath(projectCwd(agent), config.planPath)
    const loops = (loopCounts.get(agent) ?? 0) + 1
    loopCounts.set(agent, loops)
    const steer = buildRunStopSteer({ planPath, loopCount: loops })
    if (steer) steerContext(agent, steer)
  })
}
