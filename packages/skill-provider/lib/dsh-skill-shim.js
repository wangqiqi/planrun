/**
 * Minimal skill types for standalone builds. Runtime validation is owned by DSH.
 */
/**
 * Provider rank for PlanRun's bundled skills.
 *
 * DSH ranks bundled skills at 600 and lower ranks win duplicate names, so this
 * sits above 600: if a future DSH bundled skill shares a name, the official one
 * wins deterministically instead of depending on provider registration order.
 * Project skills (100/200) and user skills (400/500) still override PlanRun.
 */
export const PLANRUN_SKILL_RANK = 650;
const SKILL_NAME = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
/** Whether `name` is valid kebab-case skill id. */
export function isSkillName(name) {
    return SKILL_NAME.test(name);
}
//# sourceMappingURL=dsh-skill-shim.js.map