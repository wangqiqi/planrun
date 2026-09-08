# Changelog

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
