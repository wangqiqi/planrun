# Changelog

## [Unreleased]

### Fixed

- `bundle-super` 使用 `file:../skill-provider` 依赖，修复 `dsh plugin add file:…` 在 profile 外安装时的 `WORKSPACE_PKG_NOT_FOUND`（`sprint-01-followup`）

### Changed

- `docs/quickstart.zh.md`：补充 dogfood 步骤、`dump-config` 验证与双挂载避坑

## 0.1.0 — 2026-09-08

Initial scaffold:

- `@dsh-super/skill-provider` with MVP skills: `master`, `sprint-plan`, `run`, `review`
- `@dsh-super/bundle-super` profile bundle patch
- Growth templates under `templates/growth/`
- `install-super-dsh.sh` and `verify-super-dsh.sh`
- Documentation: mapping, naming, quickstart
