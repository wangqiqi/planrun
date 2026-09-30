/** Minimal DSH types for standalone @planrun/workflow builds. */
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
export function createUserMessage(input) {
    return { ...input, role: 'user', id: globalThis.crypto.randomUUID() };
}
//# sourceMappingURL=dsh-shim.js.map