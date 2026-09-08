import { cpSync, existsSync, mkdirSync, readdirSync, statSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

function copyTree(src: string, dest: string): void {
  mkdirSync(dest, { recursive: true })
  for (const entry of readdirSync(src)) {
    const from = join(src, entry)
    const to = join(dest, entry)
    if (statSync(from).isDirectory()) {
      copyTree(from, to)
    } else {
      mkdirSync(dirname(to), { recursive: true })
      cpSync(from, to)
    }
  }
}

/** Resolve PlanRun repo root (templates/growth). */
export function resolvePlanrunHome(explicit?: string): string | undefined {
  const candidates = [
    explicit,
    process.env.PLANRUN_HOME,
    join(fileURLToPath(new URL('.', import.meta.url)), '../../..'),
  ].filter(Boolean) as string[]
  for (const root of candidates) {
    if (existsSync(join(root, 'templates/growth'))) return root
  }
  return undefined
}

export interface EnsureGrowthResult {
  readonly growthDir: string
  readonly created: boolean
}

/** Idempotent `.dsh/growth/` bootstrap (Super Cursor growth-init for DSH). */
export function ensureGrowth(projectRoot: string, planrunHome?: string): EnsureGrowthResult {
  const growthDir = join(projectRoot, '.dsh/growth')
  const templateDir = planrunHome ? join(planrunHome, 'templates/growth') : undefined
  let created = false
  if (!existsSync(growthDir)) {
    mkdirSync(growthDir, { recursive: true })
    created = true
  }
  mkdirSync(join(growthDir, 'learn'), { recursive: true })
  mkdirSync(join(growthDir, 'archive'), { recursive: true })
  const sessionDir = join(growthDir, 'session')
  mkdirSync(sessionDir, { recursive: true })
  if (templateDir && existsSync(templateDir)) {
    if (!existsSync(join(growthDir, 'plan.md'))) {
      cpSync(join(templateDir, 'plan.md'), join(growthDir, 'plan.md'))
      created = true
    }
    if (!existsSync(join(growthDir, 'learn/README.md')) && existsSync(join(templateDir, 'learn/README.md'))) {
      cpSync(join(templateDir, 'learn/README.md'), join(growthDir, 'learn/README.md'))
    }
    if (!existsSync(join(growthDir, 'archive/README.md')) && existsSync(join(templateDir, 'archive/README.md'))) {
      cpSync(join(templateDir, 'archive/README.md'), join(growthDir, 'archive/README.md'))
    }
    const sessionTemplate = join(templateDir, 'session')
    if (existsSync(sessionTemplate)) {
      for (const name of ['persona.json', 'aliases.json']) {
        const from = join(sessionTemplate, name)
        const to = join(sessionDir, name)
        if (existsSync(from) && !existsSync(to)) {
          cpSync(from, to)
          created = true
        }
      }
    }
  }
  return { growthDir, created }
}
