---
name: perf
description: >-
  Performance investigation — measure first, one change at a time, document
  before/after. Use when latency, throughput, or bundle size is the issue.
disable-model-invocation: true
user-invocable: true
---

# perf

**用这个**：慢、卡、bundle 大 — 先测量再改。**不是那个**：功能 bug → **`debug`**；新功能交付 → **`run`**.

Standing discipline: [docs/discipline.md](../../../docs/discipline.md)

## Order (always)

1. **Measure** — profiler, slow-query log, LCP/FCP (frontend), load test baseline
2. **Hypothesis** → one change → measure again
3. **Document** before/after numbers in PR or TASK notes

## Common bottlenecks

- N+1 queries; missing indexes
- Sync I/O on hot paths
- Oversized bundles; missing code splitting / lazy routes
- Unbounded pagination or list fetch

## Output

- Bottleneck at **file:line** (or query/trace id)
- Recommendation + trade-off; no premature optimization
- If fix needs API/schema change → **`api`** + **`test`** in same change set

## Related skills

| Topic | Skill |
|-------|-------|
| Repro before fix | **`debug`** |
| Regression tests | **`test`** |
| Ship measured improvement | **`release`** |
