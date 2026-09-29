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

// Home hero actions are frontmatter, so VitePress resolves them against `base`
// only: a bare `link: install` becomes /planrun/install (404) instead of
// /planrun/zh/install. Require locale-absolute links that resolve to a page.
for (const locale of ['en', 'zh']) {
  const file = join(ROOT, 'docs', locale, 'index.md')
  if (!existsSync(file)) continue
  const shown = `docs/${locale}/index.md`
  let inActions = false
  for (const line of readFileSync(file, 'utf8').split('\n')) {
    if (/^\s*actions:\s*$/.test(line)) { inActions = true; continue }
    if (inActions && /^\S/.test(line)) inActions = false
    if (!inActions) continue
    const value = line.match(/^\s*link:\s*(\S+)\s*$/)?.[1]
    if (value === undefined || /^https?:/.test(value)) continue
    if (!value.startsWith(`/${locale}/`)) {
      failures.push(`${shown}: hero link "${value}" must start with /${locale}/ (VitePress adds only the base)`)
      continue
    }
    checked += 1
    if (!existsSync(join(ROOT, 'docs', `${value}.md`))) {
      failures.push(`${shown}: hero link "${value}" has no docs${value}.md`)
    }
  }
}

// VitePress normalizes `base` for nav/sidebar/markdown links but NOT for
// `logoLink`: a bare '/zh/' shipped a live 404 at znza.top/zh/. Anything the
// framework leaves alone must carry the deployment path itself.
const configPath = join(ROOT, 'docs/.vitepress/config.ts')
if (existsSync(configPath)) {
  const config = readFileSync(configPath, 'utf8')
  const base = config.match(/^const BASE = '([^']+)'/m)?.[1]
  if (base === undefined) {
    failures.push('docs/.vitepress/config.ts: declare the deployment path once as `const BASE = ...`')
  } else {
    const logoLinks = [...config.matchAll(/logoLink:\s*([`'"])(.*?)\1/g)].map((match) => match[2])
    if (logoLinks.length === 0) failures.push('docs/.vitepress/config.ts: no logoLink to check')
    for (const value of logoLinks) {
      checked += 1
      if (value.startsWith('${BASE}') || value.startsWith(base)) continue
      failures.push(`docs/.vitepress/config.ts: logoLink "${value}" must start with ${base} (VitePress does not add the base here)`)
    }
    // The root redirect is a static file VitePress never rewrites, so it has to
    // carry the same base by hand.
    const redirect = join(ROOT, 'docs/public/index.html')
    if (existsSync(redirect)) {
      checked += 1
      if (!readFileSync(redirect, 'utf8').includes(`'${base}'`)) {
        failures.push(`docs/public/index.html: root redirect must assign base '${base}' (keep it in sync with BASE)`)
      }
    }
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL: ${failure}`)
  console.error(`verify-doc-links: ${failures.length} broken link(s) of ${checked}`)
  process.exit(1)
}
console.log(`OK: ${checked} markdown links resolve`)
