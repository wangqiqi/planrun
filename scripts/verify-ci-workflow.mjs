#!/usr/bin/env node
/**
 * verify-ci-workflow.mjs — the CI gate must stay a gate, on every platform.
 *
 * Two regressions this catches, both of which actually happened:
 *   * the workflow only ran ubuntu, so the Windows-only breakage (bash shim,
 *     `python3`, CRLF, cmd.exe script shell) reached users before CI noticed;
 *   * `pnpm run build` carried `continue-on-error: true`, so a broken build kept
 *     the badge green.
 */
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { parse } from 'yaml'

const ROOT = join(fileURLToPath(new URL('.', import.meta.url)), '..')
const WORKFLOW = join(ROOT, '.github/workflows/verify.yml')
const REQUIRED_OS = ['ubuntu-latest', 'windows-latest', 'macos-latest']

const failures = []
let checked = 0

let doc
try {
  doc = parse(readFileSync(WORKFLOW, 'utf8'))
} catch (error) {
  console.error(`FAIL: cannot parse .github/workflows/verify.yml (${error.message})`)
  process.exit(1)
}

const jobs = doc?.jobs ?? {}
const verify = jobs.verify
if (verify === undefined) {
  failures.push('jobs.verify is missing')
} else {
  const matrix = verify.strategy?.matrix?.os
  if (!Array.isArray(matrix)) {
    failures.push('jobs.verify must declare a strategy.matrix.os list')
  } else {
    for (const os of REQUIRED_OS) {
      checked += 1
      if (!matrix.includes(os)) failures.push(`jobs.verify matrix is missing ${os}`)
    }
  }
  if (verify['continue-on-error'] === true) {
    failures.push('jobs.verify must not be continue-on-error — the gate has to block')
  }
  const runs = (verify.steps ?? [])
    .map((step) => String(step.run ?? ''))
    .filter(Boolean)
  checked += 1
  if (!runs.some((command) => /pnpm run verify\b/.test(command))) {
    failures.push('jobs.verify must run `pnpm run verify`')
  }
  for (const [index, step] of (verify.steps ?? []).entries()) {
    if (step['continue-on-error'] === true && String(step.run ?? '').includes('pnpm run')) {
      failures.push(`jobs.verify step #${index} marks a package script continue-on-error`)
    }
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL: ${failure}`)
  console.error(`verify-ci-workflow: ${failures.length} problem(s)`)
  process.exit(1)
}
console.log(`OK: CI matrix covers ${REQUIRED_OS.join(' · ')} and the verify gate blocks`)
