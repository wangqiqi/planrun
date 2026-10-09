/**
 * Copy the repo's growth templates into this package so the npm tarball carries
 * them.
 *
 * `resolvePlanrunHome` used to walk up three levels from `lib/`, which only
 * finds `templates/growth` for the `github:` channel (there the repo root is the
 * package). An npm install put the templates nowhere, so `ensureGrowth` never
 * seeded `.dsh/growth/plan.md` even though `verify-npm-install.sh` asserts it.
 *
 * Runs as the last step of `build`; when the package is installed (no repo next
 * to it) there is nothing to copy and it exits 0.
 */
import { cpSync, existsSync, rmSync } from 'node:fs'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'

const packageRoot = join(fileURLToPath(new URL('.', import.meta.url)), '..')
const source = join(packageRoot, '..', '..', 'templates', 'growth')
const target = join(packageRoot, 'templates')

if (!existsSync(source)) {
  console.log('SKIP: no repo templates/ beside the package (installed copy)')
  process.exit(0)
}

rmSync(target, { recursive: true, force: true })
cpSync(source, join(target, 'growth'), { recursive: true })
console.log('Copied templates/growth into @planrun/workflow')
