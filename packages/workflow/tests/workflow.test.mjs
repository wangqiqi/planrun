import { mkdtempSync, writeFileSync, mkdirSync, rmSync, existsSync } from 'node:fs'
import { join } from 'node:path'
import { tmpdir } from 'node:os'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { ensureGrowth, resolvePlanrunHome } from '../lib/growth.js'
import { loadPlanSnapshot, nextTaskId } from '../lib/plan-parser.js'
import { buildRunStopSteer } from '../lib/run-stop.js'
import { buildPersonaStartContext, resolvePersonaByQuery } from '../lib/persona.js'

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
  assert.ok(result.growthDir.endsWith('.dsh/growth'))
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

test('buildPersonaStartContext uses dashu by default', () => {
  const root = mkdtempSync(join(tmpdir(), 'planrun-persona-'))
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
