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
| `more` | Review / ship / quality / UX / tools | see below | PR, release, test, delivery, security, api, UX, 周报 |

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
| `mcp` | Build MCP server / tool design | **`mcp`** |
| `study` | Learn new tech (not this repo) | **`study`** |
| `ux` | UX unclear — route to ia / delivery / sprint-plan | **`ux`** |
| `ia` | Navigation, role home, workflow branches | **`ia`** |
| `pencil` | Pencil CLI mockup / .pen design | **`pencil-design`** |
| `md2docx` | Markdown → DOCX / export Word | **`md2docx-export`** |
| `week` | Multi-repo CHANGELOG weekly summary | **`week`** |
| `disk` | Disk usage snapshot and diff | **`disk`** |
| `maintain` | Linux dev environment cleanup | **`maintain`** |
| `code-stats` | Git line counts / language / commit heatmap | **`code-stats-viz`** |
| `manual` | User manual / screenshot regen | **`user-manual`** |
| `report` | Test report / verify summary | **`test-report`** |

## DSH-specific notes

| Super Cursor | PlanRun |
|---|---|
| `/plan` slash | DSH **`/plan`** = plan mode (single-task design). Multi-task Sprint → **`sprint-plan`** skill |
| `.dsh/growth/plan.md` | Human plan mirror; session todos parallel in DSH |
| User choices | **`ask_user_question`** tool |
| Gate before run | `pnpm run gate-check` · [workflow-guard.md](../../../docs/workflow-guard.md) |

## Persona · 呼叫（12 人格）

**用这个**：用户说「呼叫老周」「切换御姐」「叫小妮」→ 解析人格、写 session、改语气。**不是那个**：每句自报人设名开场。

| 字段 | 含义 |
|---|---|
| `given_name` | 用户点名匹配（如「呼叫老周」） |
| `voice_cues` | 落地语气：称呼、句长、语气词 |
| `speech_examples` | 句式锚点（≥3 条） |

**默认人格**: `dashu`（老周）· catalog: `@planrun/skill-provider/config/roles.json`

### 呼叫流程

1. `bash scripts/resolve-persona.sh '<称呼>' [项目根]` — 唯一命中 → JSON persona；exit 2 → `ask_user_question` 消歧
2. **唯一命中** → 写 `.dsh/growth/session/persona.json`（`persona_id` · `resolved_via` · `updated_at` ISO8601）
3. **本会话**改用该人格语气（`skills` 仍 full；**禁止**因人设跳过 verify / gate-check）
4. **禁止**以 `given_name` 或 nicknames 开场（`speech_rules.forbid_self_name_opener`）

项目昵称覆盖：`.dsh/growth/session/aliases.json`（优先于 roles.json nicknames）。

`@planrun/workflow` 在 `session-start` 注入 Persona hint（含 `voice_cues` · `emotion_cues`）。

## Subagents · ship · review · spike

**用这个**：委派专用子任务。**不是那个**：日常实现仍在 **`run`**。

| id | Tool / preset | Skill |
|---|---|---|
| `subagent_review` | preset **planrun** 或 **planrun-review** | **`review`** |
| `subagent_spike` | preset **planrun** 或 **planrun-spike** | **`sprint-plan`** SPIKE |
| `subagent_ship` | preset **planrun** 或 **planrun-ship** | **`release`** |

Install: `install-planrun.sh --preset` · [subagents.md](../../../docs/subagents.md) · bundled `agents/*.md` in `@planrun/skill-provider`.

## Bundled skills (28)

`master` · `sprint-plan` · `run` · `review` · `learn` · `git` · `scaffold` · `long` · `release` · `delivery` · `debug` · `test` · `security` · `api` · `refactor` · `perf` · `mcp` · `study` · `user-manual` · `test-report` · `ux` · `ia` · `pencil-design` · `md2docx-export` · `week` · `disk` · `maintain` · `code-stats-viz`
