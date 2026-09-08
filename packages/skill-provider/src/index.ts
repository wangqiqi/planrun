/**
 * Bundled dsh-super skill provider.
 *
 * @module @dsh-super/skill-provider
 */

import type { Context, SkillCandidate, SkillDefinition, SkillProvider } from './dsh-skill-shim.js'
import {
  bundledSkillMap,
  loadBundledSkills,
  PROVIDER_NAME,
  toDefinition,
} from './load-bundled-skills.js'

const records = loadBundledSkills()
const byName = bundledSkillMap(records)
const candidates: readonly SkillCandidate[] = records.map((record) => record.candidate)

const provider: SkillProvider = {
  name: PROVIDER_NAME,
  list: () => Promise.resolve(candidates),
  async get(candidate): Promise<SkillDefinition | undefined> {
    const record = byName.get(candidate.name)
    if (record === undefined || record.candidate.locator !== candidate.locator) {
      return undefined
    }
    return toDefinition(record)
  },
}

/** Cordis plugin name. */
export const name = 'dsh-super-skill-provider'

/** Registers on the skill registry. */
export const inject = ['skills']

/** Register bundled Super Cursor–adapted skills on `ctx.skills`. */
export function apply(ctx: Context): void {
  ctx.skills.registerProvider(() => provider)
}
