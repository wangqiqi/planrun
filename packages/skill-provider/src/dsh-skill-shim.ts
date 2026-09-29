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
export const PLANRUN_SKILL_RANK = 650

export type SkillSource = 'bundled' | (string & {})

export interface SkillInvocationPolicy {
  readonly modelInvocable: boolean
  readonly userInvocable: boolean
}

export interface SkillResourceBase {
  readonly kind: 'directory' | 'url' | 'opaque'
  readonly path?: string
  readonly url?: string
  readonly description?: string
}

export interface SkillSummary {
  readonly name: string
  readonly description: string
  readonly whenToUse?: string
  readonly invocation: SkillInvocationPolicy
  readonly source: SkillSource
  readonly provider: string
  readonly resourceBase?: SkillResourceBase
}

export interface SkillCandidate extends SkillSummary {
  readonly rank: number
  readonly locator: unknown
  readonly path?: string
}

export interface SkillDefinition extends SkillSummary {
  readonly content: string
  readonly path?: string
}

export interface SkillProvider {
  readonly name: string
  readonly list: () => Promise<readonly SkillCandidate[]>
  readonly get: (candidate: SkillCandidate) => Promise<SkillDefinition | undefined>
}

export interface SkillRegistry {
  registerProvider: (create: () => SkillProvider) => () => void
}

export interface Context {
  skills: SkillRegistry
}

const SKILL_NAME = /^[a-z0-9]+(?:-[a-z0-9]+)*$/

/** Whether `name` is valid kebab-case skill id. */
export function isSkillName(name: string): boolean {
  return SKILL_NAME.test(name)
}
