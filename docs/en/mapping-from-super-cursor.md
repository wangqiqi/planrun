# Mapping from Super Cursor

Reference: [`cursor-ai`](../cursor-ai) (Super Cursor v4.x).

Status key: **keep** (bundled or docs) · **rename** · **merge** · **defer** (v0.2+) · **drop**

## Skills (28 bundled · v1.4+)

| Super Cursor | PlanRun | Status |
|---|---|---|
| master | master | **keep** (adapted routes) |
| plan | sprint-plan | **rename** · **keep** |
| run | run | **keep** |
| review | review | **keep** |
| long | long | **keep** (batch-1) |
| learn | learn | **keep** (batch-1) |
| scaffold | scaffold | **keep** (batch-1) |
| git | git | **keep** (batch-1) |
| release | release | **keep** (batch-2) |
| delivery | delivery | **keep** (batch-2) |
| debug | debug | **keep** (batch-2) |
| test | test | **keep** (batch-2) |
| security | security | **keep** (batch-3) |
| api | api | **keep** (batch-3) |
| refactor | refactor | **keep** (batch-3) |
| perf | perf | **keep** (batch-3) |
| user-manual | user-manual | **keep** (batch-4) |
| test-report | test-report | **keep** (batch-4) |
| mcp | mcp | **keep** (batch-4) |
| study | study | **keep** (batch-4) |
| ux, ia, week, disk, maintain, code-stats-viz, pencil-design, md2docx-export | same ids | **keep** (batch-5+ · v1.4+) |

## Rules (48 → ~12 bullets)

| Super Cursor | PlanRun | Status |
|---|---|---|
| core.mdc, workflow.mdc, constitution.mdc | docs/en/discipline.md | **merge** |
| feedback/verify, changelog, release | run + release skills + dsh-pre-push-checks | **merge** |
| execution/* | domain skills (v0.2) | defer |
| tech/* (13 stacks) | per-stack preset packs (v1) | defer |
| super-cursor-persona, cursor-standalone | docs/en/discipline.md §Persona + workflow inject | **merge** |
| roles.json personas (12) | `@planrun/skill-provider/config/roles.json` + `.dsh/growth/session/` | **keep** (v1.4) |

## Runtime

| Super Cursor | PlanRun | Status |
|---|---|---|
| hooks.json | @planrun/workflow plugin | **keep** (v1.1 Cordis plugin) |
| runner.sh | `scripts/dsh-guard.sh` + `pnpm run gate-check` | **keep** (guard MVP) |
| plan.md HTML meta SSOT | `.dsh/growth/plan.md` + guard | **keep** (session todos still parallel) |
| commands/*.md | skill description + user slash | **merge** |
| agents/ship, review, spike | subagent presets + `agents/*.md` | **keep** (v1.6) |

## Install

| Super Cursor | PlanRun |
|---|---|
| copy `.cursor/` | `dsh plugin add @planrun/bundle` |
| `.cursorGrowth/` seeds | `install-planrun.sh` → `.dsh/growth/` |

## Dedup with deepseek-harness

| Topic | Owner |
|---|---|
| Pre-push checks | `dsh-pre-push-checks` skill in harness |
| Doc gates | `dsh-doc`, `doc-sync` |
| Plan mode | `@deepseek-ai/dsh-plan-mode` |
| Skill registry | `@deepseek-ai/dsh-skill` + filesystem provider |

PlanRun skills should **link** to harness gates, not duplicate command lists.
