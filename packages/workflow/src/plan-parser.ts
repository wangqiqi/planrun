import { readFileSync, existsSync } from 'node:fs'

const SKIP_PREFIXES = ['REV-', 'SPIKE-', 'DOC-']

export interface PlanSnapshot {
  readonly path: string
  readonly planning: boolean
  readonly planApproved: string
  readonly autonomous: boolean
  readonly sprint: string
  /**
   * `SPRINT_STATUS` meta, lower-cased. `closed` is the documented value a sprint
   * carries once it is archived and reconciled (see the shipped plan template and
   * `skills/plan/reference/autonomy-chain.md`). `run-stop` reads it to tell a
   * finished sprint from a running one — without it the autonomous chain has no
   * terminal state and steers the session forever.
   */
  readonly sprintStatus: string
  readonly active: string
  readonly activeStatus: string
  readonly pendingCount: number
  readonly gate: 'OK' | 'PLANNING' | 'NO_APPROVAL'
  readonly verifyCmd: string
  readonly maxLoops: number
}

function meta(content: string, key: string): string {
  const re = new RegExp(`<!--\\s*${key}:\\s*([^>]+)\\s*-->`)
  const match = content.match(re)
  return match?.[1]?.trim() ?? ''
}

/**
 * `(none)` is the placeholder the shipped plan templates carry, and it is a
 * non-empty string, so a gate that only tests emptiness accepted it as a
 * written approval date. Treat it as unset everywhere.
 */
function metaValue(content: string, key: string): string {
  const value = meta(content, key)
  return value === '(none)' ? '' : value
}

function shouldSkip(id: string): boolean {
  return SKIP_PREFIXES.some((prefix) => id.startsWith(prefix))
}

function taskRow(content: string, id: string): string[] | undefined {
  const lines = content.split('\n')
  for (const line of lines) {
    if (!line.includes(`| ${id} |`) && !line.includes(`| **${id}** |`)) continue
    return line.split('|').map((cell) => cell.trim())
  }
  return undefined
}

function taskStatus(content: string, id: string): string {
  const row = taskRow(content, id)
  if (!row || row.length < 6) return ''
  const status = row[4] ?? ''
  switch (status) {
    case 'ACTIVE':
    case 'BLOCKED':
      return '🔧'
    case 'TODO':
      return '⬜'
    case 'DONE':
      return '✅'
    default:
      return status
  }
}

function pendingCount(content: string): number {
  return (content.match(/\| ⬜ \|/g) ?? []).length
}

function orderLine(content: string): string {
  const match = content.match(/^\*\*(?:执行顺序|Order)\*\*[:：]\s*(.+)$/m)
  return match?.[1]?.trim() ?? ''
}

function orderTokens(line: string): string[] {
  return line
    .split('→')
    .map((part) => part.replace(/`/g, '').trim())
    .filter(Boolean)
}

function nextPendingId(content: string): string {
  for (const line of content.split('\n')) {
    if (!line.includes('| ⬜ |')) continue
    const id = line.split('|')[1]?.replace(/\*/g, '').trim() ?? ''
    if (!id || shouldSkip(id)) continue
    return id
  }
  return ''
}

function nextInOrder(content: string, afterId: string, sprint: string): string {
  const line = orderLine(content)
  if (!line) return nextPendingId(content)
  const tokens = orderTokens(line)
  let found = false
  for (const token of tokens) {
    const resolved = token.match(/^[A-Za-z][A-Za-z0-9_-]*$/)
      ? token
      : sprint && /^\d+-\d+$/.test(token)
        ? `${sprint}-${token}`
        : token
    if (!resolved || shouldSkip(resolved)) continue
    if (found) {
      const status = taskStatus(content, resolved)
      if (status === '⬜' || status === '🔧') return resolved
    }
    if (resolved === afterId) found = true
  }
  return nextPendingId(content)
}

export function nextTaskId(content: string, anchor: string): string {
  const nextMeta = meta(content, 'NEXT')
  if (nextMeta && nextMeta !== '(none)') {
    const status = taskStatus(content, nextMeta)
    if (status === '⬜' || status === '🔧') return nextMeta
  }
  if (anchor) {
    const status = taskStatus(content, anchor)
    if (status === '✅') return nextInOrder(content, anchor, meta(content, 'SPRINT'))
  }
  return nextPendingId(content)
}

export function resolvePlanPath(cwd: string, explicit?: string): string {
  if (explicit && existsSync(explicit)) return explicit
  const envPlan = process.env.DSH_GROWTH_PLAN
  if (envPlan && existsSync(envPlan)) return envPlan
  const candidates = [
    `${cwd}/.dsh/growth/plan.md`,
    `${cwd}/.cursorGrowth/plan.md`,
  ]
  for (const candidate of candidates) {
    if (existsSync(candidate)) return candidate
  }
  return candidates[0]
}

export function loadPlanSnapshot(planPath: string): PlanSnapshot | undefined {
  if (!existsSync(planPath)) return undefined
  const content = readFileSync(planPath, 'utf8')
  const planning = meta(content, 'PLANNING') === 'true'
  const planApproved = metaValue(content, 'PLAN_APPROVED')
  const autonomous = meta(content, 'AUTONOMOUS') === 'true'
  const sprint = meta(content, 'SPRINT')
  const sprintStatus = meta(content, 'SPRINT_STATUS').toLowerCase()
  let active = metaValue(content, 'ACTIVE')
  if (!active) {
    const activeRow = content.match(/\| (?:ACTIVE|🔧) \|/)
    if (activeRow) {
      const line = content.split('\n').find((l) => l.includes('| ACTIVE |') || l.includes('| 🔧 |'))
      active = line?.split('|')[1]?.replace(/\*/g, '').trim() ?? ''
    }
  }
  const gate = planning ? 'PLANNING' : planApproved ? 'OK' : 'NO_APPROVAL'
  const verify = metaValue(content, 'VERIFY') || './scripts/verify-planrun.sh'
  const maxLoops = Number.parseInt(meta(content, 'MAX_LOOPS') || '15', 10)
  return {
    path: planPath,
    planning,
    planApproved,
    autonomous,
    sprint,
    sprintStatus,
    active,
    activeStatus: active ? taskStatus(content, active) : '',
    pendingCount: pendingCount(content),
    gate,
    verifyCmd: verify,
    maxLoops: Number.isFinite(maxLoops) ? maxLoops : 15,
  }
}

export function hasWarningTask(content: string): boolean {
  return content.includes('| ⚠️ |')
}

export function readPlanContent(planPath: string): string {
  return existsSync(planPath) ? readFileSync(planPath, 'utf8') : ''
}
