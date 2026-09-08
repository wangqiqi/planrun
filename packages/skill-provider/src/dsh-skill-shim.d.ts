/**
 * Minimal skill types for standalone builds. Runtime validation is owned by DSH.
 */
export declare const BUNDLED_SKILL_RANK = 600;
export type SkillSource = 'bundled' | (string & {});
export interface SkillInvocationPolicy {
    readonly modelInvocable: boolean;
    readonly userInvocable: boolean;
}
export interface SkillResourceBase {
    readonly kind: 'directory' | 'url' | 'opaque';
    readonly path?: string;
    readonly url?: string;
    readonly description?: string;
}
export interface SkillSummary {
    readonly name: string;
    readonly description: string;
    readonly whenToUse?: string;
    readonly invocation: SkillInvocationPolicy;
    readonly source: SkillSource;
    readonly provider: string;
    readonly resourceBase?: SkillResourceBase;
}
export interface SkillCandidate extends SkillSummary {
    readonly rank: number;
    readonly locator: unknown;
    readonly path?: string;
}
export interface SkillDefinition extends SkillSummary {
    readonly content: string;
    readonly path?: string;
}
export interface SkillProvider {
    readonly name: string;
    readonly list: () => Promise<readonly SkillCandidate[]>;
    readonly get: (candidate: SkillCandidate) => Promise<SkillDefinition | undefined>;
}
export interface SkillRegistry {
    registerProvider: (create: () => SkillProvider) => () => void;
}
export interface Context {
    skills: SkillRegistry;
}
/** Whether `name` is valid kebab-case skill id. */
export declare function isSkillName(name: string): boolean;
//# sourceMappingURL=dsh-skill-shim.d.ts.map