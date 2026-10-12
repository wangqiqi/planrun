#!/usr/bin/env node
/**
 * verify-preset-required-config.mjs — build-time guard for the failure mode that
 * showed all four planrun presets as 「加载失败」 in the DSH Web UI.
 *
 * `@deepseek-ai/dsh-tool-fs-search` declares `sampleOverCapGlobResults` as
 * `z.boolean().required()` — no default. A preset row that names the plugin and
 * omits the key mounts with
 *
 *   invalid config: $.sampleOverCapGlobResults missing required value
 *
 * and the registry then reports the whole preset as broken. DSH only discovers
 * that at mount time inside a running app, so it cannot be reproduced here; this
 * script keeps the required keys as data and scans the preset sources instead.
 *
 * Extend REQUIRED when a named plugin grows a required config key. Source of
 * truth: the plugin's `Config` schema in the deepseek-harness checkout
 * (`grep -n 'required()' packages/<...>/src/index.ts`).
 *
 * Usage: node scripts/verify-preset-required-config.mjs presets/&lt;id&gt;/plugins.yml
 */
import { readFileSync } from 'node:fs'

/** Plugin module → config keys its schema requires (no default). */
const REQUIRED = {
  '@deepseek-ai/dsh-tool-fs-search': ['sampleOverCapGlobResults'],
  '@deepseek-ai/dsh-persona': ['prefix'],
  '@deepseek-ai/dsh-tool-subagent': ['provider'],
}

// Split on row boundaries so a key in a neighbouring row cannot satisfy the check.
const splitRows = (text) => text.split(/(?:^|\n)(?=- )/)

let failed = 0
let checked = 0
for (const file of process.argv.slice(2)) {
  for (const row of splitRows(readFileSync(file, 'utf8'))) {
    const name = /\n\s+name:\s*'([^']+)'/.exec(`\n${row}`)?.[1]
    const keys = name === undefined ? undefined : REQUIRED[name]
    if (keys === undefined) continue
    checked += 1
    for (const key of keys) {
      if (!new RegExp(`^\\s+${key}:`, 'm').test(row)) {
        console.error(`FAIL: ${file}: row for ${name} omits required config ${key}`)
        failed = 1
      }
    }
  }
}

if (failed === 0) {
  console.log(`OK: preset rows carry required config (${checked} rows across ${Object.keys(REQUIRED).length} tracked plugins)`)
}
process.exit(failed)
