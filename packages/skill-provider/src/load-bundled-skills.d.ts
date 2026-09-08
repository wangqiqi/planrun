/**
 * Parse bundled skill directories and build immutable provider candidates.
 *
 * @module @planrun/skill-provider/load-bundled-skills
 */
import { type SkillCandidate, type SkillDefinition } from './dsh-skill-shim.ts';
declare const PROVIDER_NAME = "planrun";
interface BundledSkillRecord {
    candidate: SkillCandidate;
    bodyPath: string;
    resourceBasePath: string;
}
/** Load every valid skill bundle under `skills/`. */
export declare function loadBundledSkills(): readonly BundledSkillRecord[];
/** Build a lookup map from loaded bundled skills. */
export declare function bundledSkillMap(records: readonly BundledSkillRecord[]): Map<string, BundledSkillRecord>;
/** Read the current markdown body for one bundled skill. */
export declare function readSkillBody(record: BundledSkillRecord): string;
/** Materialize a full skill definition from a bundled record. */
export declare function toDefinition(record: BundledSkillRecord): SkillDefinition;
export { PROVIDER_NAME };
//# sourceMappingURL=load-bundled-skills.d.ts.map