# Changelog

## [Unreleased]

### Added

- **`doctor` proves what an install actually is.** `install-planrun.sh` now records
  `.dsh/growth/.planrun-manifest.json` (PlanRun version · guard sha256 · template schema ·
  install time), and `pnpm run doctor` reads it back to report whether the installed guard
  scripts, the growth template, the installed `planrun` / `@planrun/*` packages and that
  record still agree. Exit codes are `0` no drift · `1` drift · `2` cannot determine; every
  FAIL prints a `FIX:` line, and a check with no reference to compare against is `SKIP`
  rather than a fabricated failure — the unpublished npm channel must not read as drift.
  This closes the gap that started the sprint: a DSH profile running 1.9.0 alongside 1.8.1
  guard scripts had no way to say so. Covered by seven new guard fixtures
  (`guard-fixtures.sh doctor`) and the `verify:dogfood` install-seed check.

### Fixed

- **A TASK row whose field count drifts from the header now fails closed.** A bare `|`
  inside a cell (`docs/en|zh`) added a field and shifted the positional columns, so
  `task-verify` read the status cell as the acceptance, skipped the executable-command
  branch and reported a passing heuristic fallback — "acceptance never ran" read as
  "passed". `plan-check` had only looked for *missing* columns (`NF < 8`) and let the extra
  one through. Both now compare every row against the header: `plan-check` prints the line,
  the TASK id and the field counts, and `task-verify` refuses to verify that row instead of
  guessing which column was meant. Covered by the `table-shape` guard fixtures.

## [1.9.0] - 2026-10-09

### Fixed

- **The plan gates could not fail** — four independent holes let a plan pass that should have
  blocked. `PLAN_APPROVED: (none)` (the placeholder the shipped templates carry) is a non-empty
  string, so `gate-check` reported `OK: PLAN_APPROVED=(none)`; a task id with no table row made
  `plan_task_row_field`'s pipeline return 1 under `set -euo pipefail`, killing `task-verify` with
  exit 1 and *zero output*; `plan-check` printed its `FAIL:` lines and then returned 0, so the
  documented handoff gate could not block; and `task-verify` reported `SKIP` with exit 0 when its
  heuristic fallback verify had actually failed — "verify never ran" read as "verify passed".
  `(none)` is now normalized to unset in both the shell and TypeScript parsers, the row lookup is
  awk-based and reports a missing row, `plan-check` exits non-zero on a hard failure, and a failed
  fallback propagates its exit code.
- **`pnpm run verify` did not run on Windows** — `verify-planrun.sh` aborted at the persona check
  because `python3` resolves to the Microsoft Store stub there (exit 49, every later check skipped);
  POSIX `$ROOT` was embedded inside `node -e` script text (Node resolves `/e/repo/...` against the
  current drive root); `core.autocrlf` made `gen-presets --check` report a false "stale"; and
  `pnpm run verify` / `verify:publish` / `verify:dogfood` used bare `./scripts/x.sh` paths, which
  cmd.exe cannot execute. The checks now use `node`, pass paths as argv, normalize CRLF before
  comparing, ship a `.gitattributes` that keeps sources LF, and name `bash` explicitly.
- **The registry channel lost the growth seed and the persona catalog** — `@planrun/workflow`
  resolves `templates/growth` by walking up three levels, which only works for the `github:`
  channel; an npm install therefore never seeded `.dsh/growth/plan.md`. It also found
  `roles.json` only when both scoped packages sat side by side, so an isolated layout silently
  dropped the persona hint. The build now copies the templates into the package, both are
  resolved package-relative (`createRequire` for the catalog), and the dependency is declared.
- **`verify-publish.sh` could not fail on a packed `workspace:` range** — it only inspected the
  source manifest and the tarball's entry names, and an unguarded `npm pack` aborted the script
  before its own error branch. It now packs with `pnpm pack` (the only packer that rewrites
  `workspace:^`), reads the packed manifest through a POSIX tar path, and asserts on real content.
- **`bash` on `PATH` was a hard requirement, and on Windows it was often the wrong `bash`** —
  every npm entry script now runs through `scripts/run-bash.mjs`, which probes for a shell that
  actually starts (`<shell> -c "exit 0"`), skips the `%LOCALAPPDATA%\Microsoft\WindowsApps`
  Store alias, consults `HKLM\SOFTWARE\GitForWindows\InstallPath` when Git is installed but not
  exported to `PATH`, falls back to WSL with a `/mnt` path mapping, and says *why* it failed —
  "found but could not start" is now distinct from "not installed". Nested `bash` calls inside the
  verify scripts use the resolved `$BASH` instead of relying on `PATH`.
- **Bundled skills linked outside their own package** — 23 markdown links used
  `../../../../docs/...` / `templates/...`, which resolve in the repo but point at
  `<profile>/node_modules/docs/...` once `@planrun/skill-provider` is installed from npm. They now
  point at the published docs site, at the in-project `.dsh/growth/...` path, or describe the
  target inline. A dangling `**plan**` skill name (renamed to `sprint-plan`), the retired
  `session-start` hook name, two citations of a non-existent `docs/library-index.md`, a
  `.cursorGrowth` literal in a bundled Python script, and a plan template that hardcoded
  `pnpm run verify` for arbitrary projects are fixed with it.
- **`plan` parsing drifted between the two implementations** — the shell walk of the
  `**执行顺序**` line skipped the `SPIKE-`/`DOC-`/`REV-` filter the TypeScript parser applies,
  `**Done when:**` (the shipped template's spelling) was invisible to the closed-sprint check,
  `pending` printed two `0`s, and `VERIFY: (none)` produced a bash syntax error. A shared fixture
  matrix now drives both parsers over the same plans and fails when they disagree.
- **The doc-link guard could not see packaging-only breakage** — it resolves links in-repo, so a
  link that escapes a published package looked valid. It now fails when a file inside
  `packages/*` links outside that package.

### Changed

- **Core workflow skills are model-invocable** — all 28 bundled skills shipped
  `disable-model-invocation: true`, so the model could never load one and the documented
  "load skills by situation" flow only worked when a user typed the name. `master`, `sprint-plan`,
  `run`, `review`, `debug`, `test`, `delivery` and `release` now opt in; tool skills stay
  user-only on purpose, and `verify-planrun.sh` asserts the split.
- **One `emit-js` implementation instead of three** — the per-package copies were hand-maintained
  and could drift; `scripts/emit-js.mjs` runs from a package directory, removes stale output that
  `tsc` leaves behind, and every package's `files` now uses `lib/**/*.js` so a nested emitter
  cannot be silently dropped from the tarball.
- **CI is a gate on three operating systems** — the workflow matrix is now
  `ubuntu-latest` / `windows-latest` / `macos-latest`, `pnpm run verify` blocks, and the
  `continue-on-error` on the build step is gone. `scripts/verify-ci-workflow.mjs` keeps it that way.
- **Distribution docs match reality** — the npm channel is marked unpublished (all three packages
  404 on `registry.npmjs.org`), the GitHub tag is the documented install path and is pinned
  everywhere, and the example profile no longer re-inserts a plugin its own bundle already mounts.
- **The bundled skill catalog lives in one place** — `scripts/skills-manifest.mjs` feeds the
  verify scripts, so adding a skill no longer means editing the same 28-name list in three files.

### Added

- **`scripts/guard-fixtures.sh`** — a 17-case regression matrix (`bad-plan`, `fallback-fail`,
  `backtick-acc`, `parity`) for the gates, wired into `pnpm run verify`
- **`scripts/run-bash.mjs`** — cross-platform POSIX-shell launcher used by every npm entry script
- **`scripts/verify-ci-workflow.mjs`** and **`scripts/skills-manifest.mjs`** — CI and catalog guards
- **`DSH_GUARD_EXEC`** — `false` prints the acceptance/VERIFY command instead of `eval`-ing plan
  text; an acceptance cell wrapped in backticks (the template's own spelling) is now recognized

## [1.8.2] - 2026-09-30

### Fixed

- **Injected context made the stored session unloadable** — `createUserMessage` in
  `packages/workflow/src/dsh-shim.ts` returned `{ content, source }` only, so every message
  PlanRun injected (the persona hint at `agent/created`, and the plan-mode / run-start blocks)
  was persisted as a `user/message` event with no `id` and no `role`. DSH validates a
  `user/message` event's data as an *identified* message (`assertMessageEventShape` in
  `@deepseek-ai/dsh-session`), so the whole session failed to load with
  `lacks an identified message` — the user could no longer open that conversation at all.
  The shim now mirrors DSH's own factory (`createUserMessage` in `@deepseek-ai/dsh-llm`,
  which fills in `role: 'user'` and mints an `id`): it spreads the input and adds
  `role: 'user'` plus `id: globalThis.crypto.randomUUID()`. The `UserMessage` interface
  declares both fields, so a future regression fails to compile rather than silently
  producing unloadable sessions.

## [1.8.1] - 2026-09-29

### Fixed

- **PlanRun's autonomous chain fought DSH plan mode** — with `AUTONOMOUS: true` the workflow
  plugin injected "load `run`: gate-check → implement → commit" at `agent/created`, and steered
  the same at `agent/turn-stopping`, while plan mode's policy is "explore and plan, do not
  implement". PlanRun now reads `ctx.planMode` through `ctx.get` (optional lookup, so profiles
  without `@deepseek-ai/dsh-plan-mode` still mount the plugin) and stands down whenever plan mode
  is active or a `/plan` selection is still pending: `agent/created` injects a "paused for DSH
  plan mode" block instead of the chain, and `agent/turn-stopping` never steers. Leaving plan mode
  resumes the chain — no configuration needed.

### Added

- **`packages/workflow/tests/workflow.test.mjs`** — five cases for the stand-down (active ·
  pending selection · service absent · lookup failure) plus existing steer chaining; `pnpm run
  verify` now runs them via `pnpm --filter @planrun/workflow run test`
- **Command-surface guard widened** — the bundled-skill name check covers the whole `/` palette
  (`file` · `goal` · `plan` · `feedback` · `compact` · `permission` · `model` · `export`) so a
  future skill cannot silently be shadowed by a host command

### Changed

- **docs/{en,zh}/naming.md** — new "DSH `/plan` vs PlanRun `sprint-plan`" section: different
  scopes, different artifacts, and a shared `/name` resolving to the host command first
- **docs/{en,zh}/workflow-hooks-map.md** — the rename note had split the hooks table in two (a
  blockquote between table rows); moved below the table and documented the plan-mode stand-down
- **README** · **README.zh** — state that `/plan` and `sprint-plan` are different scopes rather
  than alternatives, and that the autonomous chain stands down under plan mode

## [1.8.0] - 2026-09-29

### Added

- **GitHub-install channel** — the repository root is now itself a DSH bundle
  (`dsh.bundle.patch` = `cordis.patch.yml` + `packages/bundle-planrun/presets.patch.yml`), so
  `dsh plugin --profile web add "github:wangqiqi/planrun#v1.8.0"` works without npm. The root
  patch uses paths relative to itself, which DSH turns into `file://` URLs, so no registry
  lookup and no `workspace:^` resolution is involved.
- **Committed runtime for the git channel** — `packages/*/lib/*.js` are now tracked (runtime
  entry points only; declarations and maps stay ignored) and the root declares no `prepare`, so
  a git install runs **no build script**: no `allowBuilds` permission and no local toolchain.
  `yaml` becomes a root dependency so the installed provider can parse skill frontmatter.
- **`scripts/verify-lib-sync.sh`** (`pnpm run verify:lib`) — rebuilds and fails when the
  committed runtime is stale or a runtime module is missing from git; wired into `pnpm run verify`.
- **`scripts/verify-github-install.sh`** (`pnpm run verify:github`) — installs the git spec into
  a throwaway profile **without granting any build permission**, asserts the committed runtime is
  present, asserts the root patch and preset declarations composed, and boots headless.
  `PLANRUN_GIT_SPEC=git+file:///path/to/checkout#ref` checks an unpushed local commit.

### Changed

- **README** · **README.zh** · **docs/{en,zh}/{install,quickstart,publish}.md** — document the
  GitHub path (Paths A and A′ are mutually exclusive) and the committed-runtime invariant.
- **Roadmap** — v1.8 row.

## [1.7.2] - 2026-09-29

### Fixed

- **Bundled skills still pointed at the removed preset install path** — `master/routes.md`,
  `run/SKILL.md` and `review/SKILL.md` told users to run `install-planrun.sh --preset`, which
  v1.7 removed. They now state that the presets ship with `@planrun/bundle`.
- **Bundled skills had broken relative doc links** — the move to `docs/{en,zh}/` left 22 links
  one directory level short (two in `skills/*/reference/`), so every `docs/…` and
  `templates/…` reference inside a skill 404'd. All re-anchored to the file's real depth.
- **`cordis.patch.yml` kept an obsolete preset-root comment** — it still described registering
  `$DSH_HOME/.agent-presets` through a `roots:` config that no longer exists; replaced with the
  `presets.patch.yml` note.
- **Super Cursor links were machine-local** — `README.md`, `README.zh.md` and
  `docs/en/mapping-from-super-cursor.md` linked `../cursor-ai`, a sibling checkout that only
  exists on the author's machine. Now the GitHub URL.
- **`.cursor/skills/scaffold/catalog.md` shipped merge-conflict markers** — resolved to the true
  state: 7 stacks plus the optional `apply-bundle user-manual` · `test-report` bundles.

### Added

- **`scripts/verify-doc-links.mjs`** (`pnpm run verify:links`) — every repo-relative markdown
  link must resolve and must not escape the repository
- **Retired-surface guard** in `verify-planrun.sh` — fails when a bundled skill references
  `install-planrun.sh --preset`, `.agent-presets` or `agent/session-start`; it scans every
  bundled markdown file, including `master/routes.md`, which the Cursor-token loop skips

## [1.7.1] - 2026-09-29

### Changed

- **README.md · README.zh.md** — split by language: `README.md` is English-only, `README.zh.md` is Chinese-only, each linking only to its own `docs/<locale>/` pages; both now share the same section order, 20-row skill table, checks list, roadmap and docs index

## [1.7.0] - 2026-09-29

### Fixed

- **Published packages shipped only `lib/index.js`** — `files` omitted the runtime siblings
  (`load-bundled-skills.js`, `growth.js`, `persona.js`, …), so every install failed at plugin
  import with `ERR_MODULE_NOT_FOUND`. `verify-publish.sh` now asserts every emitted
  `lib/*.js` is in the tarball.
- **`@planrun/workflow` was disabled by DSH** — peer ranges `>=1.0.0` cannot match the
  0.1.x preview runtime; DSH refuses the row regardless of `peerDependenciesMeta.optional`.
  Ranges are now `>=0.1.0-0` (agent) and `>=0.0.1-0` (llm).
- **`agent/session-start` no longer exists** — DSH renamed it to `agent/created` on
  2026-09-09, so persona/run-start injection silently never ran. Also dropped the unused
  `inject = ['sessionProjections']`.
- **Message source `kind: 'plugin'` is rejected by session format v4** — the injected
  context now declares the producer kind `planrun-workflow`.
- **Local install path was broken** — the raw package directory carries `workspace:^` deps,
  which `file:`/git installs never rewrite. New `scripts/pack-local.sh` stages prebuilt
  copies into `dist-local/` with `file:` deps; README · quickstart · install · dogfood
  updated.
- **Agent presets used a directory format DSH no longer reads** — `presets/<id>/`
  (`preset.yml` + `agent.cordis.yml`) copied to `$DSH_HOME/.agent-presets/` was dead. The
  four presets are now official `@deepseek-ai/dsh-agent-preset` declarations in
  `packages/bundle-planrun/presets.patch.yml`, shipped by the bundle's `dsh.bundle.patch`
  list. `install-planrun.sh --preset` removed.
- **PlanRun skill rank tied with DSH's bundled rank** — both were 600, so a future
  same-name skill would resolve by provider registration order. PlanRun now ranks at 650:
  official bundled skills win deterministically, while project (100/200) and user (400/500)
  skills still override PlanRun.
- **Stale compiler output committed under `packages/skill-provider/src/`** (`.js` · `.d.ts` ·
  `.map`, one importing `./dsh-skill-shim.ts`) removed and gitignored; `verify` fails if it
  reappears.
- **CI / docs deploy** — enable GitHub Pages (`build_type: workflow`); `configure-pages@v5` · Node 24 · artifact v4

### Added

- **VitePress 文档站** — `docs/en/` · `docs/zh/` 中英文分目录；根路径语言选择；`pnpm run docs:dev` / `docs:build`；GitHub Pages（`wangqiqi.github.io/planrun`）
- **`scripts/verify-plugin-e2e.sh`** (`pnpm run verify:e2e`) — build → stage → install into a
  throwaway profile → compose config → import skill catalog → boot headless → boot again with
  the `planrun` agent preset selected to prove the declaration mounts
- **`scripts/pack-local.sh`** (`pnpm run pack:local`) — local install staging
- **`scripts/gen-presets.mjs`** — generates `presets.patch.yml` from `presets/<id>/`;
  `--check` mode keeps it in sync under `pnpm run verify`
- **Skill-conflict guard** in `verify-planrun.sh` — fails when a bundled skill name matches an
  official DSH skill (`dsh-badge` · `office-*` · `cordis-*`) or command (`plan` · `compact` ·
  `goal` · `feedback`), or when frontmatter `name` drifts from its directory
- **`docs/en/install.md`** · **`docs/zh/install.md`** — platform-neutral install guide (npm · source · Super Cursor paths)
- **`scripts/verify-docs-paths.sh`** — docs must not contain machine-specific paths

### Changed

- **VitePress 站点** — 根路径跳转至 `/zh/` 或 `/en/` 主页；排除 `_redirects/` 桩页面；Logo/首页样式优化；GitHub About 链到 `/zh/`
- **VitePress i18n** — `en/` · `zh/` 镜像同路径页面；顶栏语言切换保持当前页
- **Docs 目录重构** — `docs/{en,zh}/` 双语分目录；旧路径由 `docs/_redirects/` 承接
- **README** · **README.zh** · **subagents.md** · **quickstart** · **install.md** ·
  **publish.md** · **mapping-from-super-cursor.md** — preset install is now "install the
  bundle", not "copy a directory"; bundle manifest documented as an ordered `patch` list
- **README** · **quickstart** — who fits / prerequisites / DSH vs Cursor table; links to install.md
- **dogfood.md** — bundled skills count 28

## [1.6.1] - 2026-09-08

### Added

- **`md2docx-export`** skill — Markdown → DOCX via PyPI `mddocx` (CLI + optional MCP); routes in **master** · **run** · **delivery** · `library-index.md`

### Changed

- Bundled skills **27 → 28** (`verify-planrun.sh` · README · docs index)

## [1.6.0] - 2026-09-08

### Added

- **Subagent presets** — `planrun` · `planrun-review` · `planrun-spike` · `planrun-ship` under `presets/`
- **Named delegation tools** — `subagent_review` · `subagent_spike` · `subagent_ship` (`toolFilter` readonly for review/spike)
- **`packages/skill-provider/agents/{ship,review,spike}.md`** — bundled agent definitions
- **`docs/subagents.md`** — install, tool names, examples

### Changed

- `install-planrun.sh --preset` copies all `presets/planrun*` directories
- Skills **review** · **release** · **run** · **sprint-plan** · **master/routes** — delegation spawn examples
- `docs/mapping-from-super-cursor.md` — agents row → **keep** (v1.6)
- `verify-planrun.sh` — preset + agents structure checks

## [1.5.0] - 2026-09-08

### Added

- **npm publish path** — `@planrun/skill-provider` · `@planrun/workflow` · **`@planrun/bundle`** (`prepare` · `publishConfig` · `pnpm run publish:packages` · `verify:publish`)
- **`docs/publish.md`** — maintainer + user install guide
- **Target project guard seed** — `templates/growth/scripts/` · `install-planrun.sh` copies `dsh-guard.sh` + merges `package.json` scripts

### Changed

- **Breaking (rename)**: npm bundle package **`@planrun/bundle-planrun` → `@planrun/bundle`** (directory still `packages/bundle-planrun/`)
- **`dsh-guard.sh`** — resolve `plan.md` by walking up from **cwd** (aligned with `@planrun/workflow`)
- Bundle dependencies use **`workspace:^`** (rewritten to semver on `pnpm publish`)
- README · quickstart — `dsh plugin add @planrun/bundle` as primary install

## [1.4.0] - 2026-09-08

### Added

- **12 personas** — `@planrun/skill-provider/config/roles.json`（default **`dashu`**）· `.dsh/growth/session/persona.json` · `aliases.json` templates
- **`resolve-persona`** — `packages/workflow/src/persona.ts` · `scripts/resolve-persona.sh` · session-start Persona hint inject
- Bundled skills **batch-5**: `ux` · `ia` · `week` · `disk` · `maintain` · `code-stats-viz` · `pencil-design`

### Changed

- `master/routes.md` — §人格·呼叫 + 7 new routes; **27** bundled skills
- `docs/discipline.md` — §Persona（voice only · verify 不糊弄）
- `install-planrun.sh` — seeds `session/`; `ensureGrowth` copies persona templates
- README · `docs/mapping-from-super-cursor.md` — personas **keep** · **v1.4**

## [1.3.0] - 2026-09-08

### Added

- Bundled skills **batch-4**: `mcp`, `study`, `user-manual`, `test-report` (+ `reference/` for mcp · user-manual · test-report)
- DSH adaptations: `ask_user_question`, `.dsh/growth/`, `GetDynamicTools` / `CallDynamicTool` in **mcp**

### Changed

- `master/routes.md` — routes for manual · report · mcp · study; **20** bundled skills
- `verify-planrun.sh` · `verify-dogfood.sh` — expect **20** skills
- Removed「v0.2+ defer」footnotes from **learn** · **long** · **test** · **delivery**
- README · `docs/mapping-from-super-cursor.md` — **v1.3** · 20-skill inventory

## [1.2.0] - 2026-09-08

### Added

- **`scripts/verify-dogfood.sh`** + `pnpm run verify:dogfood` — structural harness dogfood (bundle · 16 skills · guard loop · install seed)
- `templates/dogfood/plan-fixture.md` — guard fixture SSOT for automated dogfood
- `docs/dogfood.md` — environment variables · verify commands · manual `dsh web` notes

### Changed

- `docs/quickstart.md` · `docs/quickstart.zh.md` — link structural dogfood before interactive walkthrough
- README Roadmap — **v1.2** harness dogfood ✅

## [1.1.0] - 2026-09-08

### Added

- **`@planrun/workflow`** Cordis plugin — DSH hooks parity for **growth-init** · **run-start** · **run-stop**
- `docs/workflow-hooks-map.md` — Super Cursor `hooks.json` → DSH extension point mapping
- `bundle-planrun` mounts `@planrun/workflow` alongside `@planrun/skill-provider`

### Changed

- `verify-planrun.sh` — checks workflow package and bundle patch
- README Roadmap — **v1.1** workflow hooks ✅

## [1.0.0] - 2026-09-08

### Breaking

- **Rebrand `dsh-super` → PlanRun** — repository, product name, and npm scope
- `@dsh-super/*` → **`@planrun/skill-provider`** · **`@planrun/bundle-planrun`**
- `packages/bundle-super/` → **`packages/bundle-planrun/`**
- `DSH_SUPER_HOME` → **`PLANRUN_HOME`**
- `install-super-dsh.sh` / `verify-super-dsh.sh` → **`install-planrun.sh`** / **`verify-planrun.sh`**
- `presets/super` · `profiles/super` → **`presets/planrun`** · **`profiles/planrun`**

### Added

- Bundled skills **v0.2 batch-3**: `security`, `api`, `refactor`, `perf`
- **Workflow guard MVP**: `scripts/dsh-guard.sh` (`gate-check` · `plan-check` · `task-verify` · `next-task`)
- `pnpm run gate-check` · `plan-check` · `task-verify` · `next-task` · `guard` npm scripts
- `docs/workflow-guard.md` — guard usage and plan HTML metadata
- Bundled skills **v0.2 batch-1**: `learn`, `git`, `scaffold`, `long` (+ `long/reference/`, `scaffold/catalog.md`)
- Bundled skills **v0.2 batch-2**: `release`, `delivery`, `debug`, `test` (+ `delivery/reference/` checklists)
- `verify-planrun.sh` checks **16** skills and DSH adaptation tokens

### Changed

- `master/routes.md` — batch-3 routes (`security` · `api` · `refactor` · `perf`)
- `sprint-plan` · `run` skills — `pnpm run gate-check` as hard gate; AUTONOMOUS + `next-task` alignment
- `templates/growth/plan.md` — full HTML metadata block + Super Cursor–compatible TASK table
- `verify-planrun.sh` — guard script and npm script checks
- `master/routes.md` — full v0.2 route table
- `docs/mapping-from-super-cursor.md` · `docs/naming.md` · `README.md` · `quickstart.zh.md` — 16 skill inventory
- PlanRun naming polish (`sprint-09-followup`): comparison tables use **PlanRun**; `quickstart.md` cordis id `planrun-skills`; README roadmap **v1.1** for `@planrun/workflow`; bundled skill copy aligned

### Fixed

- `bundle-planrun` 使用 `file:../skill-provider` 依赖，修复 `dsh plugin add file:…` 在 profile 外安装时的 `WORKSPACE_PKG_NOT_FOUND`（`sprint-01-followup`）

## 0.1.0 — 2026-09-08

Initial scaffold (superseded by **1.0.0** PlanRun rebrand):

- `@dsh-super/skill-provider` with MVP skills: `master`, `sprint-plan`, `run`, `review`
- `@dsh-super/bundle-super` profile bundle patch
- Growth templates under `templates/growth/`
- `install-super-dsh.sh` and `verify-super-dsh.sh`
- Documentation: mapping, naming, quickstart
