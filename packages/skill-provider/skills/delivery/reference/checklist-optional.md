# delivery · checklist §8–11 (optional)

### Analytics (product)

- [ ] core funnel events (enter → action → complete/drop)
- [ ] event names/properties unambiguous in PRD or tracking spec
- [ ] failure paths measurable or logged
- [ ] QA can verify (query/debug panel — path in `learn/acceptance.md`)

Skip for internal-only tools — state in report.

### 8. Long-running tasks (optional)

- [ ] completion state visible after 100%
- [ ] lists refresh with new data after success
- [ ] decision modals not blocked by progress layer
- [ ] failures show understandable message, not stuck 0%
- [ ] cancel/retry available

### 9. Import / destructive ops (optional)

- [ ] preview/dry-run before overwrite
- [ ] destructive overwrite needs explicit confirm
- [ ] failed writes leave no half-imported state
- [ ] conflict policy documented (skip/overwrite/merge)

### 10. Browser walkthrough (optional · UI Sprint)

**When**: UI/feature Sprint, user-visible pages, before **`release`** (recommended).  
**When skip**: backend-only, no reachable URL, no browser/automation in session — **state reason**.

- [ ] open target URL (from `learn/acceptance.md` or **`ask_user_question`**)
- [ ] main CTA/forms/lists visible
- [ ] no unhandled console errors (note known third-party noise)
- [ ] no failed critical API calls
- [ ] light a11y: keyboard reaches primary actions
- [ ] if skipped: 「§10 skipped: …」

### 11. Accessibility (optional · UI Sprint)

- [ ] keyboard: Tab order, no traps, visible focus
- [ ] semantic labels / aria on icon buttons
- [ ] contrast visibly OK on body/CTA (flag Medium+ if suspect)
- [ ] if skipped: 「§11 skipped: …」

UI Sprints: recommend §8 before **`release`**; §9 if import/restore; §10–11 when pages ship.
