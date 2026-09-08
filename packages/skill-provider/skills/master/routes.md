# master · Route table (dsh-super)

`ask_user_question` options and keywords → downstream skill. Without that tool: numbered prose options from this table.

## Primary routes (round 1 · ≤7 items)

| id | Intent | Skill | Keywords |
|---|---|---|---|
| `scaffold` | New / empty project | **`scaffold`** | bootstrap, init, empty repo, 脚手架 |
| `sprint-plan` | Sprint / multi-task planning | **`sprint-plan`** | 规划, Sprint, SPIKE, DOC — **not** DSH `/plan` plan mode |
| `run` | Continue implementation | **`run`** | ACTIVE, next task, 继续 |
| `learn` | Learn this repo | **`learn`** | conventions, module-map — **not** `study` (new tech) |
| `long` | Multi-Sprint Epic | **`long`** | Epic, 长程, resume, 多 Sprint |
| `fix` | Bug / verify blocked | `run` / `sprint-plan` | hotfix, verify failed, stuck |
| `more` | Review / git / ship | see below | PR, commit, release |

## `more` sub-routes (round 2)

| id | Intent | Skill |
|---|---|---|
| `review` | Structured PR / code review | **`review`** |
| `git` | Branch, commit, merge | **`git`** |
| `security` | Security audit | `security` (v0.2+) |
| `api` | API design review | `api` (v0.2+) |
| `delivery` | Pre-ship checklist | `delivery` (v0.2+) |
| `test` | TDD / E2E focus | `test` (v0.2+) |
| `debug` | Debug loop | `debug` (v0.2+) |
| `ship` | Release | `release` (v0.2+) |

## DSH-specific notes

| Super Cursor | dsh-super |
|---|---|
| `/plan` slash | DSH **`/plan`** = plan mode (single-task design). Multi-task Sprint → **`sprint-plan`** skill |
| `.cursorGrowth/plan.md` | **`.dsh/growth/plan.md`** (human mirror; session todos are SSOT in v0.3+) |
| `AskQuestion` | **`ask_user_question`** tool |
| `runner.sh gate-check` | Project verify scripts; `@dsh-super/workflow` plugin (v0.3) |

## Bundled skills (v0.2 batch-1)

`master` · `sprint-plan` · `run` · `review` · `learn` · `git` · `scaffold` · `long`
