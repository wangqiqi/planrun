/**
 * Emit runnable ESM beside type declarations (NodeNext emits only to lib/types).
 */
import { copyFileSync, mkdirSync, readdirSync, statSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = join(fileURLToPath(new URL('.', import.meta.url)), '..')
const srcDir = join(root, 'lib/types')
const outDir = join(root, 'lib')

function walk(dir) {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry)
    if (statSync(path).isDirectory()) {
      walk(path)
      continue
    }
    if (!entry.endsWith('.js')) continue
    const rel = path.slice(srcDir.length + 1)
    const target = join(outDir, rel)
    mkdirSync(dirname(target), { recursive: true })
    copyFileSync(path, target)
  }
}

mkdirSync(outDir, { recursive: true })
walk(srcDir)
console.log('Emitted lib/*.js from lib/types')
