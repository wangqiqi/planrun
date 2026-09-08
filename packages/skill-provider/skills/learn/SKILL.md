---
name: learn
description: >-
  Learn this repo (/learn): absorb CHANGELOG, git, archive into .dsh/growth/learn/.
  Not study (new tech). Writes project conventions only — not harness SOP changes.
disable-model-invocation: true
user-invocable: true
---

# learn

**用这个**：沉淀**本仓库**约定 → `.dsh/growth/learn/`。**不是那个**：学 Rust/新框架等通用技术 → **`study`**（v0.2+，或 `SPIKE-*` 只读调研）。

Standing discipline: [docs/discipline.md](../../../docs/discipline.md)

## Growth boundary

| Layer | Rule |
|-------|------|
| **Write** | This skill outputs `.dsh/growth/learn/` only (plus **`sprint-plan`** / **`run`** writing plan · archive) |
| **Read** | **`run`** may read existing `learn/`; **`learn`** absorbs local `archive/` · plan mirror — **project context only** |
| **Not** | Treating archive as install payload; embedding growth paths in bundled npm code |

## Bootstrap

1. **`install-planrun.sh`** — copies `templates/growth/` → target `.dsh/growth/`
2. First **`learn`** run fills seed files and absorbs CHANGELOG / archive / plan mirror

| File | Content |
|------|---------|
| `plan-conventions.md` | archive naming · optional plan sections — for **`sprint-plan`** / **`run`** |
| `dev-conventions.md` | naming, layout, test/verify commands, branch policy |
| `module-map.md` | module boundaries, entrypoints, dependency direction |
| `release-rhythm.md` | release cadence, who tags, CHANGELOG habits |
| `changelog-insights.md` | recent user-visible change summary |
| `last-sync.md` | last sync time, sources, open questions |
| `acceptance.md` | (optional) design tokens · i18n · OpenAPI — for **`delivery`** (v0.2+) |

Templates: [templates/growth/learn/README.md](../../../templates/growth/learn/README.md)

## When to run

| Timing | Action |
|--------|--------|
| New project onboarding | first **`learn`** builds skeleton |
| Sprint close | absorb archive **Goal**, decisions, **Out of scope** |
| After large refactor | update `module-map` |
| After release | update `release-rhythm` + `changelog-insights` |
| Repeated patch cluster | user asks or dense follow-ups → §CHANGELOG pattern audit |
| Convention gap | user asks「该加规则吗」or same pitfall twice → §suggest convention |
| Unexpected verify failure | **ERRORS** summary → §experience capture |
| User correction | **LEARNINGS** → §experience capture |

## Experience capture (optional mid-task)

| Type | What to write | Default target |
|------|---------------|----------------|
| **ERRORS** | failure context · root cause · verified fix | `dev-conventions.md` or `changelog-insights.md` |
| **LEARNINGS** | preference · correction · reusable pattern | same; cross-module → `module-map.md` one-liner |

**Promotion gate**: repeat ≥2 or broadly applicable → §suggest convention → **user confirms** → `learn/` only; do **not** auto-edit harness or bundled skills without a **`sprint-plan`** TASK.

## Suggest convention (distilled)

| Evidence | Suggested shape | Target |
|----------|-----------------|--------|
| archive · plan Out of scope | one line「本仓不做什么」 | `learn/plan-conventions.md` or `dev-conventions.md` |
| naming / verify commands | executable convention | `learn/dev-conventions.md` |
| module boundary | dependency direction | `learn/module-map.md` |

Output format for user confirmation:

```
建议约定：
- 证据：…（CHANGELOG / archive / file:line）
- 建议条文：…
- 落点：learn/…
```

**Forbidden**: evidence-free suggestions; stuffing generic tech notes here (use **`study`**).

## CHANGELOG pattern audit (optional)

When user says「重复工作」or too many follow-up patches:

1. Read `CHANGELOG.md` recent window
2. Cluster symptom keywords
3. Update `.dsh/growth/learn/changelog-insights.md` §重复工作模式（project symbols only）
4. Suggest next Sprint candidate via **`sprint-plan`**, not silent scope expansion

## Merge principles

- **Incremental merge**: mark `（已废弃）` instead of silent delete
- **Uncertain** → `（待确认）`
- **Do not commit** `.dsh/growth/` (usually gitignored)
- Read order: project docs → **learn/** → skills

## Evolution loop

| Change type | Where | Who writes |
|-------------|-------|------------|
| project conventions | `.dsh/growth/learn/` | **learn** |
| bundled skill text | plan TASK + user intent | **`sprint-plan`** / **`run`** |
| Sprint decisions | `.dsh/growth/archive/` + plan mirror | **`sprint-plan`** closeout |
