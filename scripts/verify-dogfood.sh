#!/usr/bin/env bash
# verify-dogfood.sh — structural dogfood checks against a deepseek-harness checkout
#
# Requires DEEPSEEK_HARNESS_HOME (no default path). Optional PLANRUN_HOME (defaults to repo root).
#
# Usage:
#   export DEEPSEEK_HARNESS_HOME=/path/to/deepseek-harness
#   export PLANRUN_HOME=/path/to/planrun   # optional
#   ./scripts/verify-dogfood.sh
#   pnpm run verify:dogfood
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLANRUN_HOME="${PLANRUN_HOME:-$ROOT}"
FIXTURE="${PLANRUN_HOME}/templates/dogfood/plan-fixture.md"
SKILLS="${PLANRUN_HOME}/packages/skill-provider/skills"
EXPECTED=(master sprint-plan run review learn git scaffold long release delivery debug test security api refactor perf mcp study user-manual test-report ux ia week disk maintain code-stats-viz pencil-design)
FAIL=0

usage() {
  cat <<EOF
用法: $0

环境变量（必须）:
  DEEPSEEK_HARNESS_HOME   deepseek-harness git checkout 根目录

环境变量（可选）:
  PLANRUN_HOME            planrun 仓库根（默认: 本脚本上级目录）

说明:
  - 显式运行本脚本时未设 DEEPSEEK_HARNESS_HOME → 退出码 1
  - pnpm run verify 不会调用本脚本（CI 无 harness 时不失败）
EOF
}

require_harness_home() {
  if [[ -z "${DEEPSEEK_HARNESS_HOME:-}" ]]; then
    echo "FAIL: DEEPSEEK_HARNESS_HOME 未设置"
    echo "      export DEEPSEEK_HARNESS_HOME=/path/to/deepseek-harness"
    return 1
  fi
  if [[ ! -d "$DEEPSEEK_HARNESS_HOME" ]]; then
    echo "FAIL: DEEPSEEK_HARNESS_HOME 不存在: $DEEPSEEK_HARNESS_HOME"
    return 1
  fi
  if [[ ! -d "$DEEPSEEK_HARNESS_HOME/.git" ]]; then
    echo "FAIL: DEEPSEEK_HARNESS_HOME 不是 git checkout（缺 .git）"
    return 1
  fi
  echo "OK: harness checkout → $DEEPSEEK_HARNESS_HOME"
  return 0
}

check_harness_layout() {
  echo "==> Checking harness layout"
  if [[ ! -f "$DEEPSEEK_HARNESS_HOME/package.json" && ! -f "$DEEPSEEK_HARNESS_HOME/AGENTS.md" ]]; then
    echo "FAIL: harness 根目录缺少 package.json 或 AGENTS.md"
    FAIL=1
  else
    echo "OK: harness root markers"
  fi
}

check_plan_fixture() {
  echo "==> Checking dogfood plan fixture"
  if [[ ! -f "$FIXTURE" ]]; then
    echo "MISSING: templates/dogfood/plan-fixture.md"
    FAIL=1
    return
  fi
  for key in PLAN_APPROVED ACTIVE SPRINT; do
    if ! grep -q "<!-- ${key}:" "$FIXTURE"; then
      echo "MISSING: fixture HTML meta ${key}"
      FAIL=1
    else
      echo "OK: fixture <!-- ${key} -->"
    fi
  done
  if ! grep -q '| ⬜ |' "$FIXTURE"; then
    echo "MISSING: fixture TASK table with ⬜"
    FAIL=1
  fi
}

check_guard_loop() {
  echo "==> Checking guard loop on plan fixture"
  if [[ ! -f "$FIXTURE" ]]; then
    echo "SKIP: no fixture"
    FAIL=1
    return
  fi
  export DSH_GROWTH_PLAN="$FIXTURE"
  if ! bash "$ROOT/scripts/dsh-guard.sh" gate-check; then
    echo "FAIL: gate-check on fixture"
    FAIL=1
  fi
  if ! bash "$ROOT/scripts/dsh-guard.sh" plan-check; then
    echo "FAIL: plan-check on fixture"
    FAIL=1
  fi
  local next
  next="$(bash "$ROOT/scripts/dsh-guard.sh" next-task)"
  if [[ -z "$next" || "$next" == "(none)" ]]; then
    echo "FAIL: next-task returned empty on fixture"
    FAIL=1
  else
    echo "OK: next-task → $next"
  fi
  unset DSH_GROWTH_PLAN
}

check_bundle_artifacts() {
  echo "==> Checking bundle build artifacts"
  local bundle_lib="${PLANRUN_HOME}/packages/bundle-planrun/lib/index.js"
  local workflow_lib="${PLANRUN_HOME}/packages/workflow/lib/index.js"
  local provider_lib="${PLANRUN_HOME}/packages/skill-provider/lib/index.js"

  if [[ ! -f "$bundle_lib" ]]; then
    echo "MISSING: packages/bundle-planrun/lib/index.js — run: pnpm run build"
    FAIL=1
  else
    echo "OK: bundle-planrun lib"
  fi
  if [[ ! -f "$workflow_lib" ]]; then
    echo "MISSING: packages/workflow/lib/index.js — run: pnpm run build"
    FAIL=1
  else
    echo "OK: workflow lib"
  fi
  if [[ ! -f "$provider_lib" ]]; then
    echo "MISSING: packages/skill-provider/lib/index.js — run: pnpm run build"
    FAIL=1
  else
    echo "OK: skill-provider lib"
  fi

  if ! grep -q '@planrun/skill-provider' "${PLANRUN_HOME}/packages/bundle-planrun/cordis.patch.yml"; then
    echo "MISSING: cordis.patch skill-provider"
    FAIL=1
  fi
  if ! grep -q '@planrun/workflow' "${PLANRUN_HOME}/packages/bundle-planrun/cordis.patch.yml"; then
    echo "MISSING: cordis.patch workflow"
    FAIL=1
  else
    echo "OK: cordis.patch.yml"
  fi
}

check_skill_inventory() {
  echo "==> Checking bundled skills (${#EXPECTED[@]}) vs master/routes.md"
  local name
  for name in "${EXPECTED[@]}"; do
    if [[ ! -f "$SKILLS/$name/SKILL.md" ]]; then
      echo "MISSING: skills/$name/SKILL.md"
      FAIL=1
    fi
  done
  if [[ -f "$SKILLS/master/routes.md" ]]; then
    for name in "${EXPECTED[@]}"; do
      if [[ "$name" == "master" ]]; then
        continue
      fi
      if ! grep -q "\`$name\`" "$SKILLS/master/routes.md"; then
        echo "MISSING: master/routes.md reference → $name"
        FAIL=1
      fi
    done
    echo "OK: master/routes.md covers ${#EXPECTED[@]} skills"
  else
    echo "MISSING: master/routes.md"
    FAIL=1
  fi
}

check_install_seed() {
  echo "==> Checking install-planrun.sh seeds growth (temp git root)"
  local tmp
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/.git"
  if ! PLANRUN_HOME="$PLANRUN_HOME" bash "$ROOT/scripts/install-planrun.sh" "$tmp" --copy-plan >/dev/null; then
    echo "FAIL: install-planrun.sh"
    rm -rf "$tmp"
    FAIL=1
    return
  fi
  if [[ ! -f "$tmp/.dsh/growth/plan.md" ]]; then
    echo "FAIL: .dsh/growth/plan.md not created"
    FAIL=1
  else
    echo "OK: install-planrun.sh → .dsh/growth/plan.md"
  fi
  if [[ ! -f "$tmp/scripts/dsh-guard.sh" ]]; then
    echo "FAIL: scripts/dsh-guard.sh not created"
    FAIL=1
  else
    echo "OK: install-planrun.sh → scripts/dsh-guard.sh"
  fi
  rm -rf "$tmp"
}

main() {
  case "${1:-}" in
    -h|--help) usage; exit 0 ;;
  esac

  echo "==> verify-dogfood (PlanRun structural harness dogfood)"
  echo "    PLANRUN_HOME=$PLANRUN_HOME"

  if ! require_harness_home; then
    exit 1
  fi

  check_harness_layout
  check_plan_fixture
  check_guard_loop
  check_bundle_artifacts
  check_skill_inventory
  check_install_seed

  if [[ "$FAIL" -ne 0 ]]; then
    echo "verify-dogfood: FAIL"
    exit 1
  fi
  echo "verify-dogfood: OK"
}

main "$@"
