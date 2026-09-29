/** Minimal DSH types for standalone @planrun/workflow builds. */

export interface UserMessage {
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
}

export function createUserMessage(input: {
  content: UserMessage['content']
  source: UserMessage['source']
}): UserMessage {
  return { content: input.content, source: input.source }
}
