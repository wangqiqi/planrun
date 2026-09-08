#!/usr/bin/env node
/**
 * Merge PlanRun guard npm scripts into a target package.json (idempotent).
 * Usage: node merge-guard-package-json.mjs <project-root>
 */
import { readFileSync, writeFileSync, existsSync } from 'node:fs'
import { join } from 'node:path'

const root = process.argv[2]
if (!root) {
  console.error('usage: merge-guard-package-json.mjs <project-root>')
  process.exit(1)
}

const pkgPath = join(root, 'package.json')
if (!existsSync(pkgPath)) {
  console.log('SKIP: no package.json — guard scripts copied to scripts/ only')
  process.exit(0)
}

const guardScripts = {
  'gate-check': 'bash scripts/dsh-guard.sh gate-check',
  'plan-check': 'bash scripts/dsh-guard.sh plan-check',
  'task-verify': 'bash scripts/dsh-guard.sh task-verify',
  'next-task': 'bash scripts/dsh-guard.sh next-task',
  guard: 'bash scripts/dsh-guard.sh status',
}

const pkg = JSON.parse(readFileSync(pkgPath, 'utf8'))
pkg.scripts = { ...(pkg.scripts ?? {}), ...guardScripts }
writeFileSync(pkgPath, `${JSON.stringify(pkg, null, 2)}\n`)
console.log('OK: merged PlanRun guard scripts into package.json')
