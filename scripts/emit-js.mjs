#!/usr/bin/env node
/**
 * emit-js.mjs — emit runnable ESM beside the type declarations.
 *
 * `tsc` with NodeNext writes `lib/types/*.js` plus `.d.ts`, but DSH loads each
 * package through `exports["."].default = ./lib/index.js`, so the JS has to sit
 * one level up. Run this from a package directory:
 *
 *   tsc -p tsconfig.json && node ../../scripts/emit-js.mjs
 *
 * One implementation, not three copies that drift (the previous per-package
 * `scripts/emit-js.mjs` files were byte-similar but hand-maintained).
 */
import { copyFileSync, existsSync, mkdirSync, readdirSync, rmSync, statSync } from 'node:fs'
import { dirname, join, relative } from 'node:path'
import process from 'node:process'

const packageRoot = process.cwd()
const sourceDir = join(packageRoot, 'lib/types')
const outputDir = join(packageRoot, 'lib')

if (!statSync(sourceDir, { throwIfNoEntry: false })?.isDirectory()) {
  console.error(`emit-js: ${sourceDir} not found — run tsc first`)
  process.exit(1)
}

let copied = 0
function walk(dir) {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry)
    if (statSync(path).isDirectory()) {
      walk(path)
      continue
    }
    if (!entry.endsWith('.js')) continue
    const target = join(outputDir, relative(sourceDir, path))
    mkdirSync(dirname(target), { recursive: true })
    copyFileSync(path, target)
    copied += 1
  }
}

mkdirSync(outputDir, { recursive: true })
walk(sourceDir)

// tsc never deletes stale output, so a removed source used to leave an orphan in
// lib/ that `verify:lib` then reported as "not committed" (the opposite of true).
for (const entry of readdirSync(outputDir)) {
  if (!entry.endsWith('.js')) continue
  const target = join(outputDir, entry)
  if (!statSync(target).isFile()) continue
  if (!existsSync(join(sourceDir, entry))) {
    rmSync(target)
    console.log(`emit-js: removed stale ${entry}`)
  }
}

console.log(`Emitted ${copied} lib/*.js from lib/types`)
