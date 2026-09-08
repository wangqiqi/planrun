/** Minimal DSH types for standalone @planrun/workflow builds. */

export interface UserMessage {
  readonly content: ReadonlyArray<{ readonly type: 'text'; readonly text: string }>
  readonly source: { readonly kind: 'plugin'; readonly plugin: string }
}

export interface Agent {
  readonly session: { readonly header: { readonly cwd: string } }
  inject(message: UserMessage): void
  steer(message: UserMessage): void
}

export interface Context {
  on(event: 'agent/session-start', handler: (payload: { agent: Agent }) => void): void
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
