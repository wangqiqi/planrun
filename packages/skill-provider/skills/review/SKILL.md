---
name: review
description: >-
  Structured PR and code review for planrun (REV-* tasks). Dual-axis Standards
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

When the **planrun** preset is installed (`install-planrun.sh --preset`) and the session uses preset **planrun** (or a copy with the same delegation rows):

| Tool | Use |
|------|-----|
| `subagent_review` | Readonly PR/diff review — loads this skill |
| `subagent_spike` | Readonly SPIKE-* research |
| `subagent_ship` | Autonomous release after verify green |

Example (foreground one-shot review):

```
subagent_review(
  label: "REV-001 api diff",
  prompt: "Load review skill. Scope: packages/workflow/src/*.ts since main. Dual-axis output.",
  run_in_background: false
)
```

Preset **planrun-review** / **planrun-spike** are dedicated readonly sessions (no bash/write tools). Agent definitions ship in `@planrun/skill-provider/agents/review.md`.

Do not mutate files in review-only mode.

## deepseek-harness projects

Follow `packages/AGENTS.md` and run relevant checks from `dsh-pre-push-checks` — report only commands actually executed.
