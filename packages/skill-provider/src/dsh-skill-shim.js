/**
 * Minimal skill types for standalone builds. Runtime validation is owned by DSH.
 */
export const BUNDLED_SKILL_RANK = 600;
const SKILL_NAME = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
/** Whether `name` is valid kebab-case skill id. */
export function isSkillName(name) {
    return SKILL_NAME.test(name);
}
//# sourceMappingURL=dsh-skill-shim.js.map