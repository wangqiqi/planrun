#!/usr/bin/env node
/**
 * Merge PlanRun guard npm scripts into a target package.json (idempotent).
 * Usage: node merge-guard-package-json.mjs <project-root>
 *
 * The launcher instead of a bare `bash`: on Windows `bash` may be missing
 * entirely or resolve to the Store shim that fails with E_ACCESSDENIED.
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

const guard = (command) => `node scripts/run-bash.mjs scripts/dsh-guard.sh ${command}`
const guardScripts = {
  'gate-check': guard('gate-check'),
  'plan-check': guard('plan-check'),
  'task-verify': guard('task-verify'),
  'next-task': guard('next-task'),
  doctor: guard('doctor'),
  guard: guard('status'),
}

let pkg
try {
  pkg = JSON.parse(readFileSync(pkgPath, 'utf8'))
} catch (error) {
  console.error(`FAIL: ${pkgPath} is not valid JSON — guard scripts not merged (${error.message})`)
  process.exit(1)
}

// Never overwrite a script the project already defines; report what was kept.
const existing = pkg.scripts ?? {}
const added = {}
const kept = []
for (const [name, command] of Object.entries(guardScripts)) {
  if (existing[name] === undefined) added[name] = command
  else kept.push(name)
}

if (Object.keys(added).length === 0) {
  console.log(`OK: PlanRun guard scripts already present (kept: ${kept.join(', ')})`)
  process.exit(0)
}

pkg.scripts = { ...existing, ...added }
writeFileSync(pkgPath, `${JSON.stringify(pkg, null, 2)}\n`)
console.log(`OK: merged PlanRun guard scripts (${Object.keys(added).join(', ')})`)
if (kept.length > 0) console.log(`SKIP: kept existing scripts (${kept.join(', ')})`)
