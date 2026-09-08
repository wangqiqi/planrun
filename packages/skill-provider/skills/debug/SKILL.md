---
name: debug
description: >-
  Systematic debug loop: reproduce → hypothesize → isolate → verify → record.
  No fix without root cause. Use when tests fail or behavior is unexplained.
disable-model-invocation: true
user-invocable: true
---

# debug

**用这个**：测试红 / 异常行为 / 要找根因再改。**不是那个**：已知 TASK 继续实现 → **`run`**；重排 scope → **`sprint-plan`**；上线走查 → **`delivery`**.

Conclusions need **file:line** and reproducible steps.

## Iron rule

**No fix without investigation.** No blind changes; symptomatic patches count as failure.

## System loop (in order)

| Step | Action | Done when |
|------|--------|-----------|
| **1 Reproduce** | fixed steps / minimal case; read full error + stack | stable trigger, or「cannot reproduce → gather evidence」 |
| **2 Hypothesize** | 1–3 falsifiable causes (recent change, env) | written before editing |
| **3 Isolate** | narrow to one layer/file | evidence at failure boundary |
| **4 Verify** | minimal diff + project test/verify | green with focused regression |
| **5 Record** | user-visible → `CHANGELOG ### Fixed`; process gap → **`learn`** | auditable |

Cross-boundary (API↔DB, CI↔scripts): diagnose at boundary first; don't patch everywhere.

## Isolation tactics

1. minimal repro or failing test
2. disable suspect block (stash mindset)
3. run verify/test before vs after
4. binary search scope

## Pattern clustering

- fix same root cause once, not many patches
- separate env vs code (config, version, paths)

## Agent introspection (tool/session failures)

| Symptom | Likely cause | First action |
|---------|--------------|--------------|
| tool errors repeat | wrong schema/args/permissions | read full output; retry one step |
| answer ≠ repo facts | stale context | re-`Read`/`Grep`; don't reuse unverified claims |
| green then red again | stacked symptomatic fixes | stop expanding diff; back to **Reproduce** |
| same command fails 3× | cwd/sandbox/path wrong | print cwd, command, exit code |

**Introspection report** (3–5 lines to user): root cause · evidence · verified fix · `Decision needed` if unsure.

Propose **`learn`** §ERRORS for repeated agent mistakes; don't auto-edit bundled skills.

## Escalation (with run)

- **`run`** self-fix ≤2 rounds still red → mark `⚠️` in plan mirror → **`sprint-plan`**
- hotfix: small diff + CHANGELOG `### Fixed`; still reproduce first
- same symptom ≥2 released patches → no third symptomatic hotfix; **`sprint-plan`** Follow-up or `SPIKE-*`

## Network / fetch (in-task)

| Scenario | Prefer | On failure |
|----------|--------|------------|
| static URL | fetch tool | explain 403/CAPTCHA; don't fake success |
| search needed | web search | ask user for better keywords |
| JS/login/interactive | browser automation if user authorized | **`delivery`** §10 or project E2E |

## Browser E2E debugging

**Route**: write tests / start server → **`test`**; ship walkthrough → **`delivery`** §10.

| Symptom | Check |
|---------|-------|
| element missing | wait for network idle before DOM query |
| flaky | server not ready; use project dev script + retry |
| JS errors | capture console in Playwright (project test setup) |
| unstable selector | screenshot/DOM scout, then tighten selector |

Harness example: `cd deepseek-harness && pnpm run test` (focused package/test file).

Mother-repo Playwright helpers live under planrun `.cursor/skills/test/scripts/` (contributor checkout only — **not** bundled in npm).
