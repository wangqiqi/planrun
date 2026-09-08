---
name: delivery
description: >-
  Pre-ship delivery checklist (/delivery): visual, i18n, docs, API, UX, production
  readiness. After task-verify green. Universal checklist; project paths in learn/.
disable-model-invocation: true
user-invocable: true
---

# delivery · Pre-ship checklist

**用这个**：功能已绿、上线前 7 维走查。**不是那个**：还在规划导航 → **`ia`** / **`ux`** (v0.2+)；脚本红绿 → project verify + **`run`**。

After **task-verify** is green, before **`release`** (merge/PR) or when Sprint **Done when** requires delivery.

Project-specific paths (design tokens, i18n, OpenAPI) → `.dsh/growth/learn/acceptance.md` (or **`ask_user_question`** / grep conventions).

**Checklists**: [reference/checklist-core.md](reference/checklist-core.md) (§1–7) · [reference/checklist-optional.md](reference/checklist-optional.md) (§8–11)

## When to enter

- user says **`/delivery`** · 「交付验收」「上线前」「生产就绪」
- before **`release`** §branch for UI/feature Sprints (recommended)
- plan **Done when** includes「delivery 无 Blocker」
- `REV-*` scope includes delivery → **`review`** (read-only) + this checklist

## Flow

1. read `.dsh/growth/learn/acceptance.md` if present · scan `.dsh/growth/plan.md` Goal / Done when
2. walk **checklist-core** §1–7 (grep · Read · compare docs/OpenAPI)
3. optional **checklist-optional** §8–11 (long tasks · import · browser · a11y)
4. API subset → **`api`** (v0.2+); production → **`security`** (v0.2+)
5. report; **Blockers** need user decision before **`release`**

## Output format

Same as **`review`** — one line per finding:

```text
severity · file:line · finding · suggestion
```

| Severity | Meaning |
|----------|---------|
| **Blocker** | cannot merge/ship; fix or explicit risk accept |
| **High** | fix this Sprint |
| **Medium** | follow-up issue OK |
| **Low** | nit |

Doc ↔ implementation conflicts → **`Decision needed`**: doc says · code does · suggestion · **await user**.

## Division of labor

| Stage | delivery | not |
|-------|----------|-----|
| **run** | — | implement · verify · audit |
| **delivery** | 7-dim walkthrough · optional §8–11 | no business code unless user steers Blocker fix |
| **release** | Blockers reported first | no skipping verify |

Browser walkthrough (§10) and full a11y (§11) are **optional** — skip with reason in report. No default MCP required in DSH.

PDF / Office deep tools: **not bundled** in skill-provider; use project scripts or upstream skills when user explicitly requests. Markdown **export** to Word → **md2docx-export** (`pip install mddocx` · optional MCP).

## Forbidden

- recommend merge with open **Blockers**
- silent spec or code change on conflicts without **`Decision needed`**
- replace **task-verify** or skip **security** on high-risk diffs

User manual / test report regen → **`user-manual`** · **`test-report`** skills.
