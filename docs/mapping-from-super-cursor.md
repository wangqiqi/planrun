# Mapping from Super Cursor

Reference: [`cursor-ai`](../cursor-ai) (Super Cursor v4.x).

Status key: **keep** (bundled or docs) · **rename** · **merge** · **defer** (v0.2+) · **drop**

## Skills (27 → v0.1: 4)

| Super Cursor | dsh-super | Status |
|---|---|---|
| master | master | **keep** (adapted routes) |
| plan | sprint-plan | **rename** |
| run | run | **keep** |
| long | long | defer |
| learn | learn | defer |
| scaffold | scaffold | defer |
| release | release | defer |
| git | git | defer |
| delivery | delivery | defer |
| user-manual | user-manual | defer |
| test-report | test-report | defer |
| review | review | **keep** |
| debug, test, security, api, refactor, perf, mcp, study | same ids | defer |
| ux, ia, week, disk, maintain, code-stats-viz, pencil-design | same ids | defer |

## Rules (48 → ~12 bullets)

| Super Cursor | dsh-super | Status |
|---|---|---|
| core.mdc, workflow.mdc, constitution.mdc | docs/discipline.md | **merge** |
| feedback/verify, changelog, release | run + release skills + dsh-pre-push-checks | **merge** |
| execution/* | domain skills (v0.2) | defer |
| tech/* (13 stacks) | per-stack preset packs (v1) | defer |
| super-cursor-persona, cursor-standalone | — | **drop** |
| roles.json personas | — | **drop** |

## Runtime

| Super Cursor | dsh-super | Status |
|---|---|---|
| hooks.json | @dsh-super/workflow plugin | defer v0.3 |
| runner.sh | guard plugin + pnpm scripts | defer v0.3 |
| plan.md HTML meta SSOT | session todos + plan mirror | defer v0.3 |
| commands/*.md | skill description + user slash | **merge** |
| agents/ship, review, spike | subagent preset (v0.2) | defer |

## Install

| Super Cursor | dsh-super |
|---|---|
| copy `.cursor/` | `dsh plugin add @dsh-super/bundle-super` |
| `.cursorGrowth/` seeds | `install-super-dsh.sh` → `.dsh/growth/` |

## Dedup with deepseek-harness

| Topic | Owner |
|---|---|
| Pre-push checks | `dsh-pre-push-checks` skill in harness |
| Doc gates | `dsh-doc`, `doc-sync` |
| Plan mode | `@deepseek-ai/dsh-plan-mode` |
| Skill registry | `@deepseek-ai/dsh-skill` + filesystem provider |

dsh-super skills should **link** to harness gates, not duplicate command lists.
