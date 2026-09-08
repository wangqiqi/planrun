/**
 * Bundled planrun skill provider.
 *
 * @module @planrun/skill-provider
 */
import { bundledSkillMap, loadBundledSkills, PROVIDER_NAME, toDefinition, } from './load-bundled-skills.ts';
const records = loadBundledSkills();
const byName = bundledSkillMap(records);
const candidates = records.map((record) => record.candidate);
const provider = {
    name: PROVIDER_NAME,
    list: () => Promise.resolve(candidates),
    async get(candidate) {
        const record = byName.get(candidate.name);
        if (record === undefined || record.candidate.locator !== candidate.locator) {
            return undefined;
        }
        return toDefinition(record);
    },
};
/** Cordis plugin name. */
export const name = 'planrun-skill-provider';
/** Registers on the skill registry. */
export const inject = ['skills'];
/** Register bundled Super Cursor–adapted skills on `ctx.skills`. */
export function apply(ctx) {
    ctx.skills.registerProvider(() => provider);
}
//# sourceMappingURL=index.js.map