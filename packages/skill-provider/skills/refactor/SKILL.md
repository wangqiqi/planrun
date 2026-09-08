---
name: refactor
description: >-
  Safe refactoring — small steps, minimal diff, verify after each step. Includes
  dead-code deletion protocol. Use for rename/extract/cleanup without behavior change.
disable-model-invocation: true
user-invocable: true
---

# refactor

**用这个**：行为不变的重构、去重、死代码删除。**不是那个**：新功能 → **`run`**；scope 重排 → **`sprint-plan`**；专项只读回顾 → **`review`**.

Standing discipline: [docs/en/discipline.md](../../../docs/en/discipline.md)

## Principles

- Behavior-neutral refactors separate from feature commits
- After each step: `pnpm run task-verify` or project test green
- Match user scope or plan `REV-*` rows when present

## Common moves

- Extract functions/modules; rename via IDE/tooling
- Deduplicate; shrink public API surface

## Dead-code deletion protocol

Before removing components, hooks, APIs, or routes:

1. **grep production paths** — route tables · page imports · OpenAPI/client SDK · server router registration
2. **Distinguish** test-only vs production references (test-only → delete tests/mocks too)
3. **Phased** — UI round then API round (avoid half-clean); large removals → `SPIKE-*` + product confirm via **`sprint-plan`**
4. **Verify** — `pnpm run verify` / full tests after delete; CHANGELOG `### Removed` one-line summary

For error-path refactors, align with **`debug`** (don't swallow inner errors with generic outer messages).

## Forbidden

- Drive-by unrelated file edits
- Large untested rewrites ( **`sprint-plan`** first)
- Deleting “unused” exports without production-path grep

## Related skills

| Topic | Skill |
|-------|-------|
| Execute TASK | **`run`** |
| Tests while refactoring | **`test`** |
| Security-sensitive delete | **`security`** |
