---
name: review
description: >-
  Structured PR and code review for dsh-super (REV-* tasks). Dual-axis Standards
  and Spec checklist. Read-only — use subagent with readonly preset when delegating.
disable-model-invocation: true
user-invocable: true
---

# review

**Use for:** `REV-*`, pre-merge review, complexity / smell scan.

**Not for:** security deep-dive (`security` v0.2), ship checklist (`delivery` v0.2), active debugging (`debug` v0.2).

## Dual-axis review

| Axis | Question | Evidence |
|---|---|---|
| **Standards** | Matches documented project conventions? | `AGENTS.md`, package READMEs, `.dsh/growth/learn/dev-conventions.md` |
| **Spec** | Meets Goal / issue / PR intent? | PR body, `.dsh/growth/plan.md` Target, acceptance commands |

Each axis: **Pass / Concern / Blocker** + `file:line` + one-line rationale.

## Priority (human reviewer)

1. Architecture and context fit
2. Correctness and bugs
3. Security (when triggered)
4. Missing tests
5. Style nits (lowest)

## Output format

Severity (Blocker / High / Medium / Low) · `file:line` · finding · suggestion · axis (Standards / Spec)

## Checklist (abbreviated)

### Scope

- [ ] Matches PR / REV description; no drive-by refactor
- [ ] Aligns with plan Target when applicable

### Correctness

- [ ] Failure paths handled; no silent catch
- [ ] Concurrency / null / idempotency considered when relevant

### Tests

- [ ] Behavior change has focused test or snapshot evidence

### Docs

- [ ] Public API / config changes update README or docs

## Delegation

When using DSH subagents: spawn a **readonly** child with this skill loaded in the prompt. Do not mutate files in review-only mode.

## deepseek-harness projects

Follow `packages/AGENTS.md` and run relevant checks from `dsh-pre-push-checks` — report only commands actually executed.
