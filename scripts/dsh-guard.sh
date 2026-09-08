#!/usr/bin/env bash
# dsh-guard.sh — workflow guard MVP for planrun (gate-check · plan-check · task-verify · next-task)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SC_SKIP_PREFIXES="${SC_SKIP_PREFIXES:-REV- SPIKE- DOC-}"
HEURISTICS_ENABLED="${DSH_GUARD_HEURISTICS:-true}"
FALLBACK_VERIFY="${DSH_GUARD_FALLBACK_VERIFY:-./scripts/verify-planrun.sh}"

resolve_plan_file() {
  local candidate
  if [[ -n "${DSH_GROWTH_PLAN:-}" ]]; then
    if [[ -f "${DSH_GROWTH_PLAN}" ]]; then
      echo "$(cd "$(dirname "${DSH_GROWTH_PLAN}")" && pwd)/$(basename "${DSH_GROWTH_PLAN}")"
      return 0
    fi
    echo "FAIL: DSH_GROWTH_PLAN 不存在: ${DSH_GROWTH_PLAN}" >&2
    return 1
  fi
  for candidate in "$ROOT/.dsh/growth/plan.md" "$ROOT/.cursorGrowth/plan.md"; do
    if [[ -f "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  echo ""
  return 0
}

PLAN="$(resolve_plan_file)" || exit 1
export SC_SKIP_PREFIXES
# shellcheck source=plan-parse.sh
source "$ROOT/scripts/plan-parse.sh" "$PLAN"

cmd="${1:-status}"

gate_check() {
  local reason
  if [[ -z "$PLAN" || ! -f "$PLAN" ]]; then
    echo "=== dsh-guard gate-check ==="
    echo "BLOCK: plan 不存在（.dsh/growth/plan.md 或 .cursorGrowth/plan.md 或 DSH_GROWTH_PLAN）"
    return 1
  fi
  reason="$(plan_gate_ok || true)"
  echo "=== dsh-guard gate-check ==="
  echo "plan: $PLAN"
  case "$reason" in
    OK)
      echo "OK: PLAN_APPROVED=$(plan_plan_approved) · SPRINT=$(plan_sprint) · ACTIVE=$(plan_active)"
      return 0
      ;;
    PLANNING)
      echo "BLOCK: PLANNING=true — 请先 sprint-plan 完成规划并设 PLANNING:false"
      return 1
      ;;
    NO_APPROVAL)
      echo "BLOCK: 无 PLAN_APPROVED — 请先 sprint-plan 确认规划并写入日期"
      return 1
      ;;
    *)
      echo "BLOCK: 未知闸门状态"
      return 1
      ;;
  esac
}

plan_check() {
  local issues=0
  echo "=== dsh-guard plan-check ==="
  echo "plan: ${PLAN:-（未找到）}"
  if [[ -z "$PLAN" || ! -f "$PLAN" ]]; then
    echo "FAIL: plan 不存在"
    return 1
  fi
  if ! grep -q '| ⬜ |' "$PLAN" 2>/dev/null && ! grep -q '| 🔧 |' "$PLAN" 2>/dev/null \
    && ! grep -qE '\| ACTIVE \|' "$PLAN" 2>/dev/null; then
    if ! plan_sprint_appears_closed; then
      echo "WARN: 无活跃 ⬜/🔧/ACTIVE 任务"
      issues=$((issues + 1))
    fi
  fi
  if [[ -z "$(plan_active)" ]]; then
    if ! plan_sprint_appears_closed; then
      echo "WARN: <!-- ACTIVE --> 未设置且无 ACTIVE 表行"
      issues=$((issues + 1))
    fi
  fi
  if [[ -z "$(plan_sprint)" ]]; then
    echo "WARN: <!-- SPRINT --> 未设置"
    issues=$((issues + 1))
  fi
  if [[ "$(plan_sprint_status)" == "active" ]] && plan_sprint_goal_ritual_only; then
    echo "WARN: Sprint Goal 似仪式/出口动作（非能力交付）"
    echo "      Goal: $(plan_sprint_goal_text)"
    issues=$((issues + 1))
  fi
  if plan_planning; then
    echo "INFO: PLANNING=true — 仅 sprint-plan"
  elif [[ -z "$(plan_plan_approved)" ]]; then
    echo "FAIL: <!-- PLAN_APPROVED --> 未设置（run 硬闸门）"
    issues=$((issues + 1))
  fi
  if ! grep -qE '^\*\*(执行顺序|Order)\*\*' "$PLAN" 2>/dev/null; then
    echo "WARN: 缺 **执行顺序** 行（NEXT 回退靠表序）"
    issues=$((issues + 1))
  fi
  local line cols bad=0
  while IFS= read -r line; do
    [[ "$line" =~ \|[[:space:]]*(⬜|🔧)[[:space:]]*\| ]] || continue
    cols="$(echo "$line" | awk -F'|' '{print NF}')"
    if [[ "$cols" -lt 8 ]]; then
      bad=$((bad + 1))
    fi
  done < <(grep -E '\| (⬜|🔧) \|' "$PLAN" 2>/dev/null || true)
  if [[ "$bad" -gt 0 ]]; then
    echo "WARN: ${bad} 行活跃任务可能缺「验收」或「落点」"
    issues=$((issues + 1))
  fi
  if plan_sprint_appears_closed; then
    local unchecked pending_tasks
    unchecked="$(plan_done_when_unchecked)"
    if [[ "${unchecked:-0}" -gt 0 ]]; then
      echo "WARN: Sprint 已闭合但 Done when 仍有 ${unchecked} 项未 [x]"
      issues=$((issues + 1))
    fi
    if [[ "$(plan_sprint_status)" != "closed" ]]; then
      echo "WARN: <!-- SPRINT_STATUS --> 未设 closed"
      issues=$((issues + 1))
    fi
    pending_tasks="$(grep -cE '\| ⬜ \|' "$PLAN" 2>/dev/null || true)"
    pending_tasks="${pending_tasks:-0}"
    if [[ "$pending_tasks" -gt 0 ]]; then
      echo "WARN: Sprint 已闭合但 TASK 表仍有 ${pending_tasks} 行 ⬜"
      issues=$((issues + 1))
    fi
  fi
  local vmeta vpath
  vmeta="$(plan_verify)"
  if [[ "$vmeta" == *"dsh-guard"* && "$vmeta" == *"verify"* ]]; then
    echo "FAIL: <!-- VERIFY --> 不得为 dsh-guard verify（无限递归）；应写 pnpm run verify 或 ./scripts/verify-planrun.sh"
    issues=$((issues + 1))
  elif [[ "$vmeta" != *" "* && "$vmeta" == ./* ]]; then
    vpath="${vmeta#./}"
    if [[ ! -f "$ROOT/$vpath" ]]; then
      echo "WARN: VERIFY 脚本不存在: $vmeta"
      issues=$((issues + 1))
    fi
  fi
  if [[ "$issues" -eq 0 ]]; then
    echo "OK: handoff 就绪"
    return 0
  fi
  echo "CHECK: ${issues} 项待补齐"
  return 0
}

run_fallback_verify() {
  local script="${FALLBACK_VERIFY#./}"
  if [[ -f "$ROOT/$script" ]]; then
    echo "==> heuristics fallback: $FALLBACK_VERIFY"
    cd "$ROOT"
    bash "$script"
    return $?
  fi
  local verify_cmd
  verify_cmd="$(plan_verify)"
  if [[ -n "$verify_cmd" && "$verify_cmd" != "$FALLBACK_VERIFY" ]]; then
    echo "==> heuristics fallback: $verify_cmd"
    cd "$ROOT"
    # shellcheck disable=SC2086
    eval "$verify_cmd"
    return $?
  fi
  return 1
}

task_verify() {
  local id="${1:-$(plan_active)}"
  local acc loc
  if [[ -z "$PLAN" || ! -f "$PLAN" ]]; then
    echo "FAIL: plan 不存在" >&2
    return 1
  fi
  if [[ -z "$id" || "$id" == "(none)" ]]; then
    echo "FAIL: 无 ACTIVE 任务 ID" >&2
    return 1
  fi
  acc="$(plan_task_acceptance "$id")"
  loc="$(plan_task_landing "$id")"
  echo "=== dsh-guard task-verify: ${id} ==="
  echo "plan: $PLAN"
  echo "验收: ${acc}"
  echo "落点: ${loc}"

  if [[ "$acc" =~ ^(\./|cd |npm |pnpm |npx |pytest |grep |cargo |go test|make |bash ) ]]; then
    echo "==> Running acceptance command"
    cd "$ROOT"
    # shellcheck disable=SC2086
    eval "$acc"
    return $?
  fi

  if [[ "$acc" == grep* ]]; then
    cd "$ROOT"
    # shellcheck disable=SC2086
    eval "$acc"
    return $?
  fi

  if [[ "$HEURISTICS_ENABLED" != "true" ]]; then
    echo "SKIP: heuristics disabled — run acceptance command in plan or verify manually"
    return 0
  fi

  if run_fallback_verify; then
    return 0
  fi

  echo "SKIP: 验收列为描述性文字，请 Agent 按列手动执行；打版前须跑全量 VERIFY"
  echo "TIP: plan 验收列优先写 pnpm run verify / bash scripts/... 等可执行命令"
  return 0
}

print_status() {
  echo "=== dsh-guard status ==="
  echo "plan: ${PLAN:-（未找到）}"
  if [[ -z "$PLAN" || ! -f "$PLAN" ]]; then
    return 1
  fi
  echo "PLANNING:   $(plan_meta PLANNING || echo false)"
  echo "SPRINT:     $(plan_sprint || echo '(none)')"
  echo "APPROVED:   $(plan_plan_approved || echo '(none)')"
  echo "AUTONOMOUS: $(plan_meta AUTONOMOUS || echo false)"
  echo "ACTIVE:     $(plan_active || echo '(none)')"
  local active
  active="$(plan_active)"
  if [[ -n "$active" && "$active" != "(none)" ]]; then
    echo "STATUS:     $(plan_task_status "$active")"
    echo "ACCEPTANCE: $(plan_task_acceptance "$active")"
    echo "NEXT_TASK:  $(plan_next_task)"
  fi
  echo "VERIFY:     $(plan_verify)"
  echo "PENDING:    $(plan_pending_count) tasks"
  local gate
  gate="$(plan_gate_ok || true)"
  echo "GATE:       ${gate}"
}

run_verify() {
  local verify_cmd
  verify_cmd="$(plan_verify)"
  if [[ "$verify_cmd" == *"dsh-guard"* && "$verify_cmd" == *"verify"* ]]; then
    verify_cmd="$FALLBACK_VERIFY"
  fi
  echo "==> Full VERIFY: $verify_cmd"
  cd "$ROOT"
  # shellcheck disable=SC2086
  eval "$verify_cmd"
}

case "$cmd" in
  status)
    print_status
    ;;
  verify)
    run_verify
    ;;
  task-verify)
    task_verify "${2:-}"
    ;;
  gate-check)
    gate_check
    ;;
  next-task)
    plan_next_task
    ;;
  active)
    plan_active
    ;;
  pending)
    plan_pending_count
    ;;
  plan-check)
    plan_check
    ;;
  help|-h|--help)
    cat <<EOF
用法: $0 [status|gate-check|task-verify|verify|plan-check|next-task|...]

  status        Sprint 状态（默认）
  gate-check    run 硬闸门（PLANNING / PLAN_APPROVED）
  task-verify   任务级验收（优先验收列；可传 TASK_ID）
  verify        全量 VERIFY（打版前 / P0 闭合）
  plan-check    plan handoff 结构检查
  next-task     按执行顺序解析下一 ⬜ ID
  active        当前 ACTIVE 任务 ID
  pending       待办 ⬜ 数量

Plan 路径（优先级）:
  1. 环境变量 DSH_GROWTH_PLAN
  2. .dsh/growth/plan.md（目标项目）
  3. .cursorGrowth/plan.md（母版仓开发）

环境变量:
  DSH_GROWTH_PLAN          显式 plan 路径
  DSH_GUARD_HEURISTICS     true（默认）| false
  DSH_GUARD_FALLBACK_VERIFY  描述性验收回退脚本（默认 ./scripts/verify-planrun.sh）
EOF
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
