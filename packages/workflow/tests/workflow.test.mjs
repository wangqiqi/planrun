import { mkdtempSync, writeFileSync, mkdirSync, rmSync, existsSync } from 'node:fs'
import { join } from 'node:path'
import { tmpdir } from 'node:os'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { ensureGrowth, resolvePlanrunHome } from '../lib/growth.js'
import { apply } from '../lib/index.js'
import { loadPlanSnapshot, nextTaskId } from '../lib/plan-parser.js'
import { buildRunStopSteer } from '../lib/run-stop.js'
import { buildPersonaStartContext, resolvePersonaByQuery } from '../lib/persona.js'
import { createUserMessage } from '../lib/dsh-shim.js'

test('resolvePlanrunHome finds repo templates', () => {
  const repoRoot = join(import.meta.dirname, '../../..')
  const home = resolvePlanrunHome(repoRoot)
  assert.ok(home)
  assert.ok(existsSync(join(home, 'templates/growth/plan.md')))
})

test('ensureGrowth creates plan.md from templates', () => {
  const root = mkdtempSync(join(tmpdir(), 'planrun-growth-'))
  const planrunHome = resolvePlanrunHome(join(import.meta.dirname, '../../..'))
  assert.ok(planrunHome)
  const result = ensureGrowth(root, planrunHome)
  assert.equal(result.created, true)
  // Windows joins with a backslash: comparing against a POSIX literal made this
  // test fail on every Windows checkout.
  assert.ok(result.growthDir.endsWith(join('.dsh', 'growth')), result.growthDir)
  rmSync(root, { recursive: true, force: true })
})

test('loadPlanSnapshot reads ACTIVE and AUTONOMOUS', () => {
  const dir = mkdtempSync(join(tmpdir(), 'planrun-plan-'))
  const planPath = join(dir, 'plan.md')
  writeFileSync(
    planPath,
    `<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-09-08 -->
<!-- AUTONOMOUS: true -->
<!-- ACTIVE: TASK-002 -->
<!-- SPRINT: SPRINT-06 -->
| ID | Task | P | Status | Acc | Target |
| TASK-001 | a | P0 | ✅ | ok | x |
| TASK-002 | b | P0 | ⬜ | ok | y |
**执行顺序**: TASK-001 → TASK-002
`,
  )
  const snap = loadPlanSnapshot(planPath)
  assert.ok(snap)
  assert.equal(snap.active, 'TASK-002')
  assert.equal(snap.autonomous, true)
  assert.equal(snap.gate, 'OK')
  rmSync(dir, { recursive: true, force: true })
})

test('buildRunStopSteer chains to next task', () => {
  const dir = mkdtempSync(join(tmpdir(), 'planrun-stop-'))
  mkdirSync(join(dir, '.dsh/growth'), { recursive: true })
  const planPath = join(dir, '.dsh/growth/plan.md')
  writeFileSync(
    planPath,
    `<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-09-08 -->
<!-- AUTONOMOUS: true -->
<!-- ACTIVE: TASK-001 -->
| TASK-001 | a | P0 | ✅ | ok | x |
| TASK-002 | b | P0 | ⬜ | ok | y |
**执行顺序**: TASK-001 → TASK-002
`,
  )
  const steer = buildRunStopSteer({ planPath, loopCount: 1 })
  assert.match(steer ?? '', /TASK-002/)
  rmSync(dir, { recursive: true, force: true })
})

test('the (none) placeholder is not an approval', () => {
  const dir = mkdtempSync(join(tmpdir(), 'planrun-none-'))
  const planPath = join(dir, 'plan.md')
  writeFileSync(
    planPath,
    `<!-- PLANNING: false -->
<!-- PLAN_APPROVED: (none) -->
<!-- ACTIVE: TASK-001 -->
| TASK-001 | a | P0 | ⬜ | ok | x |
`,
  )
  const snap = loadPlanSnapshot(planPath)
  assert.ok(snap)
  assert.equal(snap.gate, 'NO_APPROVAL', '(none) must not satisfy the run gate')
  assert.equal(snap.active, 'TASK-001')
  rmSync(dir, { recursive: true, force: true })
})

test('the shipped growth template does not pass the run gate', () => {
  const planrunHome = resolvePlanrunHome(join(import.meta.dirname, '../../..'))
  assert.ok(planrunHome)
  const snap = loadPlanSnapshot(join(planrunHome, 'templates/growth/plan.md'))
  assert.ok(snap)
  assert.notEqual(snap.gate, 'OK')
})

test('buildPersonaStartContext uses dashu by default', () => {  const root = mkdtempSync(join(tmpdir(), 'planrun-persona-'))
  const planrunHome = resolvePlanrunHome(join(import.meta.dirname, '../../..'))
  assert.ok(planrunHome)
  const hint = buildPersonaStartContext(root, planrunHome)
  assert.ok(hint)
  assert.match(hint, /dashu/)
  rmSync(root, { recursive: true, force: true })
})

test('resolvePersonaByQuery finds nickname', () => {
  const planrunHome = resolvePlanrunHome(join(import.meta.dirname, '../../..'))
  assert.ok(planrunHome)
  const result = resolvePersonaByQuery('老周', process.cwd(), planrunHome)
  assert.equal(result.status, 'ok')
  if (result.status === 'ok') assert.equal(result.persona.id, 'dashu')
})

test('nextTaskId respects execution order', () => {
  const content = `<!-- SPRINT: SPRINT-06 -->
| TASK-001 | a | P0 | ✅ | ok | x |
| TASK-002 | b | P0 | ⬜ | ok | y |
**执行顺序**: TASK-001 → TASK-002`
  assert.equal(nextTaskId(content, 'TASK-001'), 'TASK-002')
})

// ---- DSH plan mode must win over PlanRun's autonomous chain ----

const PLANRUN_HOME = resolvePlanrunHome(join(import.meta.dirname, '../../..'))

/** An AUTONOMOUS plan whose ACTIVE task is done, so the chain would advance. */
function autonomousPlan() {
  const dir = mkdtempSync(join(tmpdir(), 'planrun-mode-'))
  const planPath = join(dir, 'plan.md')
  writeFileSync(
    planPath,
    `<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-09-08 -->
<!-- AUTONOMOUS: true -->
<!-- ACTIVE: TASK-001 -->
| TASK-001 | a | P0 | ✅ | ok | x |
| TASK-002 | b | P0 | ⬜ | ok | y |
**执行顺序**: TASK-001 → TASK-002
`,
  )
  return { dir, planPath }
}

function harness(planMode) {
  const handlers = new Map()
  const injected = []
  const steered = []
  const agent = {
    session: { header: { cwd: mkdtempSync(join(tmpdir(), 'planrun-cwd-')) } },
    inject: (message) => injected.push(message),
    steer: (message) => steered.push(message),
  }
  const ctx = {
    on: (event, handler) => { handlers.set(event, handler) },
    get: (name) => (name === 'planMode' ? planMode : undefined),
  }
  return { ctx, handlers, agent, injected, steered }
}

const texts = (messages) => messages.map((message) => message.content[0].text).join('\n')

test('plan mode active: no autonomous steer at turn stop', async () => {
  const { dir, planPath } = autonomousPlan()
  const { ctx, handlers, agent, steered } = harness({ get: () => ({ active: true }) })
  apply(ctx, { planrunHome: PLANRUN_HOME, planPath })
  await handlers.get('agent/turn-stopping')({ agent })
  assert.equal(steered.length, 0, 'plan mode must suppress the autonomous steer')
  rmSync(dir, { recursive: true, force: true })
})

test('plan mode active: start context says paused, not implement', () => {
  const { dir, planPath } = autonomousPlan()
  const { ctx, handlers, agent, injected } = harness({ get: () => ({ active: true }) })
  apply(ctx, { planrunHome: PLANRUN_HOME, planPath })
  handlers.get('agent/created')({ agent })
  const text = texts(injected)
  assert.match(text, /paused for DSH plan mode/)
  // The implement instruction is the distinguishing mark: the paused block
  // mentions the autonomous chain only to say it is standing down.
  assert.doesNotMatch(text, /Load `run` skill/)
  rmSync(dir, { recursive: true, force: true })
})

test('pending /plan on already counts as plan mode', async () => {
  const { dir, planPath } = autonomousPlan()
  const { ctx, handlers, agent, steered } = harness({ get: () => ({ active: false, pending: true }) })
  apply(ctx, { planrunHome: PLANRUN_HOME, planPath })
  await handlers.get('agent/turn-stopping')({ agent })
  assert.equal(steered.length, 0)
  rmSync(dir, { recursive: true, force: true })
})

test('no plan mode service: autonomous chain still runs', async () => {
  const { dir, planPath } = autonomousPlan()
  const { ctx, handlers, agent, injected, steered } = harness(undefined)
  apply(ctx, { planrunHome: PLANRUN_HOME, planPath })
  handlers.get('agent/created')({ agent })
  await handlers.get('agent/turn-stopping')({ agent })
  assert.match(texts(injected), /autonomous Sprint chain/)
  assert.match(texts(injected), /Load `run` skill/)
  assert.equal(steered.length, 1)
  assert.match(texts(steered), /TASK-002/)
  rmSync(dir, { recursive: true, force: true })
})

test('plan mode lookup failure degrades to "not in plan mode"', async () => {
  const { dir, planPath } = autonomousPlan()
  const { ctx, handlers, agent, steered } = harness({
    get: () => { throw new Error('session not attached') },
  })
  apply(ctx, { planrunHome: PLANRUN_HOME, planPath })
  await handlers.get('agent/turn-stopping')({ agent })
  assert.equal(steered.length, 1)
  rmSync(dir, { recursive: true, force: true })
})

test('createUserMessage produces a message the DSH session validator accepts', () => {
  const message = createUserMessage({
    content: [{ type: 'text', text: '## PlanRun · Persona hint' }],
    source: { kind: 'planrun-workflow' },
  })
  // This is exactly what DSH's `assertMessageEventShape`
  // (core/session/src/index.ts) demands of a `user/message` event's data.
  // Miss either field and the host rejects the whole stored session on load with
  // "lacks an identified message" — the session becomes unopenable.
  assert.equal(message.role, 'user')
  assert.equal(typeof message.id, 'string')
  assert.ok(message.id.length > 0, 'id must be a non-empty string')
  assert.deepEqual(message.content, [{ type: 'text', text: '## PlanRun · Persona hint' }])
  assert.deepEqual(message.source, { kind: 'planrun-workflow' })
})

test('createUserMessage mints a distinct id per message', () => {
  const build = () => createUserMessage({
    content: [{ type: 'text', text: 'x' }],
    source: { kind: 'planrun-workflow' },
  })
  assert.notEqual(build().id, build().id)
})

// ---- A finished sprint must terminate the autonomous chain ----
//
// Regression: `buildRunStopSteer` had no terminal state. A closed plan with no
// pending tasks kept returning a steer on **every** `agent/turn-stopping`, and
// each steer starts another turn — so the session looped forever: first
// "sprint complete — verify, archive, reconcile plan", then, once `loopCount`
// reached MAX_LOOPS, "MAX_LOOPS=… Review plan and continue manually" on every
// turn with no way out. `.cursor/hooks/run-stop.sh` guards this with
// `plan_autonomous_chain_idle` (placed *before* the MAX_LOOPS branch); the TS
// hook was missing it.

/** A closed, fully reconciled plan — the state a sprint sits in after /release. */
function closedPlan({ sprintStatus = 'closed' } = {}) {
  const dir = mkdtempSync(join(tmpdir(), 'planrun-closed-'))
  const planPath = join(dir, 'plan.md')
  writeFileSync(
    planPath,
    `<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-09-08 -->
<!-- AUTONOMOUS: true -->
<!-- SPRINT: SPRINT-06 -->
<!-- SPRINT_STATUS: ${sprintStatus} -->
<!-- ACTIVE: (none) -->
<!-- NEXT: (none) -->
<!-- MAX_LOOPS: 15 -->
| ID | Task | P | Status | Acc | Target |
| TASK-001 | a | P0 | ✅ | ok | x |
**执行顺序**: TASK-001
`,
  )
  return { dir, planPath }
}

test('loadPlanSnapshot reads SPRINT_STATUS (lower-cased)', () => {
  const { dir, planPath } = closedPlan({ sprintStatus: 'CLOSED' })
  const snap = loadPlanSnapshot(planPath)
  assert.ok(snap)
  assert.equal(snap.sprintStatus, 'closed')
  assert.equal(snap.autonomous, true)
  assert.equal(snap.pendingCount, 0)
  rmSync(dir, { recursive: true, force: true })
})

test('closed sprint with no pending work: no steer at loop 1', () => {
  const { dir, planPath } = closedPlan()
  assert.equal(buildRunStopSteer({ planPath, loopCount: 1 }), undefined)
  rmSync(dir, { recursive: true, force: true })
})

test('closed sprint: no steer past MAX_LOOPS either (the infinite-followup bug)', () => {
  const { dir, planPath } = closedPlan()
  for (const loopCount of [15, 16, 99]) {
    assert.equal(
      buildRunStopSteer({ planPath, loopCount }),
      undefined,
      `loop ${loopCount} must not steer a finished sprint`,
    )
  }
  rmSync(dir, { recursive: true, force: true })
})

test('closed sprint: 20 turn-stops steer nothing (chain is terminal)', async () => {
  const { dir, planPath } = closedPlan()
  const { ctx, handlers, agent, steered } = harness(undefined)
  apply(ctx, { planrunHome: PLANRUN_HOME, planPath })
  handlers.get('agent/created')({ agent })
  for (let turn = 0; turn < 20; turn += 1) {
    await handlers.get('agent/turn-stopping')({ agent })
  }
  assert.equal(steered.length, 0, 'a closed sprint must produce 0 steers, however many turns run')
  rmSync(dir, { recursive: true, force: true })
})

test('running sprint still steers (the guard must not silence live chains)', () => {
  const { dir, planPath } = autonomousPlan()
  assert.match(buildRunStopSteer({ planPath, loopCount: 1 }) ?? '', /TASK-002/)
  rmSync(dir, { recursive: true, force: true })
})

test('closed sprint that still has a pending task keeps steering', () => {
  // Contradictory metadata must not strand work: only `closed` **and** zero
  // pending means "there is no chain left to run".
  const dir = mkdtempSync(join(tmpdir(), 'planrun-closed-pending-'))
  const planPath = join(dir, 'plan.md')
  writeFileSync(
    planPath,
    `<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-09-08 -->
<!-- AUTONOMOUS: true -->
<!-- SPRINT: SPRINT-06 -->
<!-- SPRINT_STATUS: closed -->
| TASK-001 | a | P0 | ⬜ | ok | x |
**执行顺序**: TASK-001
`,
  )
  assert.match(buildRunStopSteer({ planPath, loopCount: 1 }) ?? '', /TASK-001/)
  rmSync(dir, { recursive: true, force: true })
})
