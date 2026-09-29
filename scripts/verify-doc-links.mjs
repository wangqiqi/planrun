#!/usr/bin/env node
/**
 * verify-doc-links.mjs — every repo-relative markdown link must resolve.
 *
 * Catches the failure mode that a bulk `docs/` → `docs/en/` move produces:
 * links whose relative depth no longer matches the file's location, and links
 * that escape the repository (a sibling checkout path that only exists on the
 * author's machine).
 *
 * Skipped on purpose:
 *   * `docs/_redirects/` — the stub links are redirect targets, not files
 *     beside the stub.
 *   * `.cursor/` — the Super Cursor mother pack; its placeholders and
 *     user-local rule paths are outside this repo's contract.
 *   * targets containing `<` or `...` — prose placeholders such as
 *     `<assets_dir>/<file>.png`.
 */
import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs'
import { dirname, join, relative, resolve, sep } from 'node:path'
import { fileURLToPath } from 'node:url'

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const SKIP_DIRS = new Set([
  'node_modules', '.git', 'lib', 'dist', 'dist-local', '.pnpm-store',
  '.vitepress', '_redirects', '.cursor',
])

function* markdownFiles(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith('.') && entry.name !== '.github') continue
    if (SKIP_DIRS.has(entry.name)) continue
    const path = join(dir, entry.name)
    if (entry.isDirectory()) yield* markdownFiles(path)
    else if (entry.name.endsWith('.md')) yield path
  }
}

const LINK = /\]\(([^)\s]+)\)/g
const failures = []
let checked = 0

for (const file of markdownFiles(ROOT)) {
  const text = readFileSync(file, 'utf8')
  for (const match of text.matchAll(LINK)) {
    const raw = match[1]
    if (/^(?:https?:|mailto:|#)/.test(raw)) continue
    const target = raw.split('#')[0]
    if (target === '' || target.includes('<') || target.includes('...')) continue
    checked += 1
    const resolved = resolve(dirname(file), target)
    const shown = relative(ROOT, file)
    if (resolved !== ROOT && !resolved.startsWith(ROOT + sep)) {
      failures.push(`${shown}: ${raw} escapes the repository`)
    } else if (!existsSync(resolved)) {
      failures.push(`${shown}: ${raw} does not exist`)
    }
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL: ${failure}`)
  console.error(`verify-doc-links: ${failures.length} broken link(s) of ${checked}`)
  process.exit(1)
}
console.log(`OK: ${checked} markdown links resolve`)
