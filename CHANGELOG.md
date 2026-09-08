# Changelog

## [Unreleased]

### Fixed

- `bundle-super` 使用 `file:../skill-provider` 依赖，修复 `dsh plugin add file:…` 在 profile 外安装时的 `WORKSPACE_PKG_NOT_FOUND`（`sprint-01-followup`）

### Added

- **Workflow guard MVP**: `scripts/dsh-guard.sh` (`gate-check` · `plan-check` · `task-verify` · `next-task`)
- `pnpm run gate-check` · `plan-check` · `task-verify` · `next-task` · `guard` npm scripts
- `docs/workflow-guard.md` — guard usage and plan HTML metadata
- Bundled skills **v0.2 batch-1**: `learn`, `git`, `scaffold`, `long` (+ `long/reference/`, `scaffold/catalog.md`)
- Bundled skills **v0.2 batch-2**: `release`, `delivery`, `debug`, `test` (+ `delivery/reference/` checklists)
- `verify-super-dsh.sh` checks 12 skills and DSH adaptation tokens

### Changed

- `sprint-plan` · `run` skills — `pnpm run gate-check` as hard gate; AUTONOMOUS + `next-task` alignment
- `templates/growth/plan.md` — full HTML metadata block + Super Cursor–compatible TASK table
- `verify-super-dsh.sh` — guard script and npm script checks
- `master/routes.md` — full v0.2 route table
- `docs/mapping-from-super-cursor.md` · `docs/naming.md` · `README.md` · `quickstart.zh.md` — 12 skill inventory

## 0.1.0 — 2026-09-08

Initial scaffold:

- `@dsh-super/skill-provider` with MVP skills: `master`, `sprint-plan`, `run`, `review`
- `@dsh-super/bundle-super` profile bundle patch
- Growth templates under `templates/growth/`
- `install-super-dsh.sh` and `verify-super-dsh.sh`
- Documentation: mapping, naming, quickstart
