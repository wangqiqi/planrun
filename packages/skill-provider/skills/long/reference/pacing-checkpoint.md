# long · pacing, checkpoint, resume

Risks: **quota / session timeout**, **context bloat**, **over-splitting**. Defines when to run fast, pause, and resume.

## Pacing

| layer | driver | sleep? |
|-------|--------|--------|
| **Task** | event (verify green → next ACTIVE) | ❌ |
| **Sprint end** | after checkpoint | ✅ optional 60–180s |
| **Epic phase** | user confirm or external loop | ✅ longer on failure backoff |
| **CI / deploy wait** | event watcher | use host loop; no tight poll |

**Use**: zero-gap **run** chain inside a Sprint. **Not**: sleep after every TASK.

## Limits

| mechanism | config | behavior |
|-----------|--------|----------|
| Epic `max_sprints` | long-state (default 5) | replan Epic if exceeded |
| failure fuse | **run** · **debug** | ≤2 self-fix rounds → `⚠️` stop |

Do not weaken verify to avoid limits; use **checkpoint + resume**.

## Checkpoint (end of each Sprint)

1. project verify (Sprint Done when)
2. Sprint notes → `.dsh/growth/archive/` (`YYYYMMDD_HHMMSS_<topic>.md`)
3. update **long-state.json** (below)
4. **plan mirror reconciliation** — remove closed Active block from `.dsh/growth/plan.md`
5. optional short break or new session for next Sprint

## long-state.json

Path: **`.dsh/growth/long-state.json`** (gitignored, beside plan mirror).

```json
{
  "epic_id": "EPIC-001",
  "goal": "one-line Epic Goal",
  "done_when": ["verifiable items"],
  "status": "planning | active | paused | completed",
  "autonomous": true,
  "max_sprints": 5,
  "sprints": [
    {
      "id": "SPRINT-02",
      "goal": "…",
      "status": "pending | active | done",
      "plan_sprint_meta": "SPRINT-02"
    }
  ],
  "active_sprint_index": 0,
  "last_checkpoint": "2026-09-08T13:00:00+08:00",
  "last_done_task": "TASK-005",
  "interrupt_reason": null
}
```

| field | meaning |
|-------|---------|
| `status: paused` | decision interrupt · user pause |
| `active_sprint_index` | current `sprints[]` entry |
| `interrupt_reason` | read before resume |

**Resume**: user says「继续长程」→ read long-state + plan mirror → continue ACTIVE or next Sprint **`sprint-plan`** handoff.

**SSOT note (v0.1)**: DSH session todos are authoritative for in-flight work; long-state and plan mirror are **human-auditable** copies. v0.3 `@planrun/workflow` may unify gates.

## Host loop (optional)

For multi-day Epics, an external heartbeat may poll long-state and invoke **`run`** when `status=active` and plan has open rows. Decision points still stop the chain.

## Modes

| mode | fit | user |
|------|-----|------|
| **same session** | 2–3 Sprints · hours | one **`long`** invocation |
| **checkpoint resume** | multi-day · high risk | review diff each Sprint |
| **external loop** | unattended tendency | loop + **`long`**; decisions still pause |

## References

- hierarchy → [hierarchy.md](hierarchy.md)
- **`sprint-plan`** handoff · **`run`** Sprint closeout
