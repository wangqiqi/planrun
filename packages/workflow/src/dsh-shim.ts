/** Minimal DSH types for standalone @planrun/workflow builds. */

export interface UserMessage {
  /**
   * Stable identity preserved across every representation boundary. DSH's session
   * validator rejects a `user/message` event whose message has no non-empty `id`
   * ("lacks an identified message"), so the producer must mint one.
   */
  readonly id: string
  readonly role: 'user'
  readonly content: ReadonlyArray<{ readonly type: 'text'; readonly text: string }>
  /**
   * Producer-owned source kind. Session format v4 rejects the retired
   * catch-all `kind: 'plugin'` wrapper, so this must name the producer.
   */
  readonly source: { readonly kind: string }
}

export interface Agent {
  readonly session: { readonly header: { readonly cwd: string } }
  inject(message: UserMessage): void
  steer(message: UserMessage): void
}

export interface Context {
  on(event: 'agent/created', handler: (payload: { agent: Agent }) => void): void
  on(
    event: 'agent/pre-step',
    handler: (payload: { agent: Agent }, next: () => Promise<unknown>) => Promise<unknown>,
  ): void
  on(event: 'agent/turn-stopping', handler: (payload: { agent: Agent }) => void | Promise<void>): void
  /**
   * Optional service lookup — undefined when the composed profile does not
   * mount the provider. Used for DSH plan mode, which a minimal profile omits.
   */
  get(name: string): unknown
}

/**
 * Build one injectable user message, mirroring DSH's own factory.
 *
 * DSH's `createUserMessage` (`@deepseek-ai/dsh-llm`) fills in `role: 'user'` and mints an
 * `id`; this standalone shim must do the same, or every message it injects produces a
 * session event the host refuses to load. `globalThis.crypto.randomUUID` is used so the
 * shim stays free of a Node-only import and works in browsers too.
 * @param input - producer-supplied content and source kind.
 * @returns an identified user message carrying `role: 'user'`.
 */
export function createUserMessage(input: {
  content: UserMessage['content']
  source: UserMessage['source']
}): UserMessage {
  return { ...input, role: 'user', id: globalThis.crypto.randomUUID() }
}
