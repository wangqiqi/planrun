---
name: test
description: >-
  Testing checklist — unit, integration, E2E, TDD red-green-refactor. Links
  project verify. Use when writing tests, TDD, or Playwright work.
disable-model-invocation: true
user-invocable: true
---

# test

Prefer commands from `.dsh/growth/plan.md` TASK verify column; else project `./scripts/test.sh` or stack default (e.g. harness `pnpm run test`).

## TDD short loop

1. **Red** — failing test or repro case; run and confirm fail
2. **Green** — minimal implementation
3. **Refactor** — under green tests; no scope creep

Align with **`run`**: no ✅ while red; actually run verify/test.

## Factories and doubles

| Technique | When | Notes |
|-----------|------|-------|
| **Factory** | repeated entity setup | defaults + per-test overrides |
| **Test double** | external I/O, clock, network | inject at boundary |
| **Mock** | assert call patterns | mock behavior, not internals |
| **Stub** | fixed return values | simpler than mock when enough |

- Arrange (factory) · Act (one line) · Assert (one behavior)
- don't over-mock the unit under test
- async: await assertions; fake timers per stack

With **`debug`**: red repro → narrow with doubles → green regression lock.

## Layers

| Type | When |
|------|------|
| Unit | pure logic, utils, hooks |
| Integration | API, DB, module boundaries |
| E2E | critical user paths (Playwright/Cypress if project has them) |

Full release **test report** → **test-report** (v0.2+ defer).

## Verify layers (L0–L3)

- new domain: L1 in task verify; L3 in Sprint Done when or nightly
- stay red at L1 while fixing; don't skip to L3 for ✅
- project coordinates → `.dsh/growth/learn/dev-conventions.md`

## Playwright / E2E (when stack supports)

- test behavior and visible outcomes, not DOM implementation details
- local: `npx playwright test` or project script
- start dev server or use `webServer` config in playwright config

### Local web app pattern (not bundled in npm)

**Use project scripts.** Example harness:

```bash
cd /path/to/deepseek-harness
pnpm run test --filter <package>
```

**Decision tree**:

```
static HTML? → read HTML for selectors → Playwright
dynamic SPA? → start dev server → wait networkidle → scout screenshot/DOM → act
split FE/BE? → start both servers (project compose script) → E2E against FE URL
```

**Scout-then-act** (SPA):

1. `wait_for_load_state('networkidle')`
2. screenshot or list locators
3. interact with discovered selectors

Mother-repo examples: `$PLANRUN_HOME/.cursor/skills/test/scripts/` (contributor checkout only). Install Playwright in **target project**, not via skill-provider package.

With **`debug`**: capture console on UI failures; networkidle before assertions.

## Discipline

- red tests block ✅
- new bugs → regression test first
- pairs with **`debug`**: reproduce → green → commit
