#!/usr/bin/env node
/**
 * skills-manifest.mjs — the bundled skill catalog, in one place.
 *
 * The 28-name list used to be written out verbatim in `verify-planrun.sh` and
 * `verify-dogfood.sh`, and the count was hardcoded a third time in
 * `verify-plugin-e2e.sh`. Adding one skill meant editing three files, and
 * forgetting one produced a confusing "catalog length" failure instead of a
 * missing-name failure.
 *
 * Run directly for shell consumption:
 *   node scripts/skills-manifest.mjs              # space-separated names
 *   node scripts/skills-manifest.mjs --model-invocable
 *   node scripts/skills-manifest.mjs --count
 */
import { fileURLToPath, pathToFileURL } from 'node:url'

/** Every skill directory that must ship in @planrun/skill-provider. */
export const SKILLS = [
  'master',
  'sprint-plan',
  'run',
  'review',
  'learn',
  'git',
  'scaffold',
  'long',
  'release',
  'delivery',
  'debug',
  'test',
  'security',
  'api',
  'refactor',
  'perf',
  'mcp',
  'study',
  'user-manual',
  'test-report',
  'ux',
  'ia',
  'week',
  'disk',
  'maintain',
  'code-stats-viz',
  'pencil-design',
  'md2docx-export',
]

/**
 * Skills the model may load by itself. The rest stay user-invocable on purpose:
 * they either run destructive or host-specific work (release, scaffold) or are
 * tool wrappers whose descriptions would only add noise to the catalog.
 */
export const MODEL_INVOCABLE_SKILLS = [
  'master',
  'sprint-plan',
  'run',
  'review',
  'debug',
  'test',
  'delivery',
  'release',
]

export const SKILL_COUNT = SKILLS.length

function main() {
  const flag = process.argv[2]
  if (flag === '--model-invocable') {
    console.log(MODEL_INVOCABLE_SKILLS.join(' '))
    return
  }
  if (flag === '--count') {
    console.log(String(SKILL_COUNT))
    return
  }
  console.log(SKILLS.join(' '))
}

// Only print when executed, not when imported.
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main()
}
