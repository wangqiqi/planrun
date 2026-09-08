# master · Route table (planrun)

`ask_user_question` options and keywords → downstream skill. Without that tool: numbered prose options from this table.

## Primary routes (round 1 · ≤7 items)

| id | Intent | Skill | Keywords |
|---|---|---|---|
| `scaffold` | New / empty project | **`scaffold`** | bootstrap, init, empty repo, 脚手架 |
| `sprint-plan` | Sprint / multi-task planning | **`sprint-plan`** | 规划, Sprint, SPIKE, DOC — **not** DSH `/plan` plan mode |
| `run` | Continue implementation | **`run`** | ACTIVE, next task, 继续 |
| `learn` | Learn this repo | **`learn`** | conventions, module-map — **not** `study` (new tech) |
| `long` | Multi-Sprint Epic | **`long`** | Epic, 长程, resume, 多 Sprint |
| `fix` | Bug / verify blocked | **`run`** / **`debug`** / **`sprint-plan`** | hotfix, verify failed, stuck |
| `more` | Review / ship / quality | see below | PR, release, test, delivery, security, api |

## `more` sub-routes (round 2)

| id | Intent | Skill |
|---|---|---|
| `review` | Structured PR / code review | **`review`** |
| `git` | Branch, commit, merge | **`git`** |
| `release` | Merge, PR, tag, ship | **`release`** |
| `delivery` | Pre-ship checklist | **`delivery`** |
| `test` | TDD / E2E focus | **`test`** |
| `debug` | Debug loop | **`debug`** |
| `security` | Security audit | **`security`** |
| `api` | API design review | **`api`** |
| `refactor` | Safe refactor / dead code | **`refactor`** |
| `perf` | Performance investigation | **`perf`** |

## DSH-specific notes

| Super Cursor | planrun |
|---|---|
| `/plan` slash | DSH **`/plan`** = plan mode (single-task design). Multi-task Sprint → **`sprint-plan`** skill |
| `.dsh/growth/plan.md` | Human plan mirror; session todos parallel in DSH |
| User choices | **`ask_user_question`** tool |
| Gate before run | `pnpm run gate-check` · [workflow-guard.md](../../../docs/workflow-guard.md) |

## Bundled skills (16)

`master` · `sprint-plan` · `run` · `review` · `learn` · `git` · `scaffold` · `long` · `release` · `delivery` · `debug` · `test` · `security` · `api` · `refactor` · `perf`
