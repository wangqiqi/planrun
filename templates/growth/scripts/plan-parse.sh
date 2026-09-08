#!/usr/bin/env bash
# Parse plan.md — dsh-guard (ported from Super Cursor plan-parse)
set -euo pipefail

PLAN_FILE="${1:-plan.md}"
SC_SKIP_PREFIXES="${SC_SKIP_PREFIXES:-REV- SPIKE- DOC-}"

plan_id_should_skip() {
  local id="$1" prefix
  for prefix in $SC_SKIP_PREFIXES; do
    [[ "$id" == "$prefix"* ]] && return 0
  done
  return 1
}

plan_meta() {
  local key="$1"
  if [[ ! -f "$PLAN_FILE" ]]; then
    echo ""
    return 0
  fi
  grep -E "<!-- ${key}:" "$PLAN_FILE" 2>/dev/null | head -1 | sed -E "s/.*<!-- ${key}:[[:space:]]*([^>]+)[[:space:]]*-->.*/\1/" | sed 's/[[:space:]]*$//' || true
}

plan_pending_count() {
  grep -c '| ⬜ |' "$PLAN_FILE" 2>/dev/null || echo "0"
}

plan_active() {
  local meta
  meta="$(plan_meta "ACTIVE")"
  if [[ -n "$meta" && "$meta" != "(none)" ]]; then
    echo "$meta"
    return 0
  fi
  # Fallback: table row with ACTIVE status (growth template style)
  grep -E '\| (ACTIVE|🔧) \|' "$PLAN_FILE" 2>/dev/null | head -1 \
    | awk -F'|' '{gsub(/^[ \t*]+|[ \t*]+$/, "", $2); print $2}' || true
}

plan_verify() {
  local v
  v="$(plan_meta "VERIFY")"
  if [[ -n "$v" ]]; then
    echo "$v"
  else
    echo "./scripts/verify-planrun.sh"
  fi
}

plan_autonomous() {
  local a
  a="$(plan_meta "AUTONOMOUS")"
  [[ "$a" == "true" ]]
}

plan_planning() {
  local p
  p="$(plan_meta "PLANNING")"
  [[ "$p" == "true" ]]
}

plan_sprint() {
  plan_meta "SPRINT"
}

plan_sprint_goal_text() {
  if [[ ! -f "$PLAN_FILE" ]]; then
    echo ""
    return 0
  fi
  grep -E '^\*\*Goal\*\*' "$PLAN_FILE" 2>/dev/null | head -1 | sed -E 's/^\*\*Goal\*\*[:：][[:space:]]*//' | sed 's/[[:space:]]*$//' || true
}

plan_sprint_goal_ritual_only() {
  local goal lower
  goal="$(plan_sprint_goal_text)"
  [[ -z "$goal" ]] && return 1
  lower="$(printf '%s' "$goal" | tr '[:upper:]' '[:lower:]')"
  if ! printf '%s' "$lower" | grep -qiE '(打版|发版|release|打[[:space:]]*tag|打tag|merge|合并|开[[:space:]]*pr|changelog|归档|verify|验收|commit|提交|push|发版)'; then
    return 1
  fi
  if printf '%s' "$lower" | grep -qiE '(实现|模块|功能|接入|引擎|插件|重构|迁移|交付|mvp|api|服务|client|skill|tts|long|架构|接口)'; then
    return 1
  fi
  return 0
}

plan_plan_approved() {
  plan_meta "PLAN_APPROVED"
}

plan_max_loops() {
  local m
  m="$(plan_meta "MAX_LOOPS")"
  if [[ -n "$m" ]]; then
    echo "$m"
  else
    echo "15"
  fi
}

plan_task_row_field() {
  local id="$1"
  local col="$2"
  grep -E "\| \*\*${id}\*\* \||\| ${id} \|" "$PLAN_FILE" 2>/dev/null | head -1 | awk -F'|' -v c="$col" '{
    gsub(/^[ \t]+|[ \t]+$/, "", $c);
    print $c;
  }'
}

plan_task_status() {
  local status
  status="$(plan_task_row_field "$1" 5)"
  case "$status" in
    ACTIVE|TODO|DONE|BLOCKED)
      case "$status" in
        ACTIVE) echo "🔧" ;;
        TODO) echo "⬜" ;;
        DONE) echo "✅" ;;
        BLOCKED) echo "🔧" ;;
      esac
      ;;
    *)
      echo "$status"
      ;;
  esac
}

plan_task_acceptance() {
  plan_task_row_field "$1" 6
}

plan_task_landing() {
  plan_task_row_field "$1" 7
}

plan_last_done() {
  plan_meta "LAST_DONE"
}

plan_sprint_status() {
  plan_meta "SPRINT_STATUS"
}

plan_sprint_appears_closed() {
  local active last status
  status="$(plan_sprint_status)"
  [[ "$status" == "closed" ]] && return 0
  active="$(plan_active)"
  last="$(plan_last_done)"
  if [[ "$active" == "(none)" || -z "$active" ]]; then
    [[ -n "$last" && "$last" != "(none)" ]] && return 0
  fi
  return 1
}

plan_done_when_unchecked() {
  if [[ ! -f "$PLAN_FILE" ]]; then
    echo "0"
    return 0
  fi
  awk '
    /^### Done when/ { in_done=1; next }
    /^### / && in_done { exit }
    in_done && /^- \[ \]/ { count++ }
    END { print count+0 }
  ' "$PLAN_FILE" 2>/dev/null || echo "0"
}

plan_next_meta() {
  plan_meta "NEXT"
}

plan_resolve_task_id() {
  local token="$1"
  local sprint="$2"
  token="$(echo "$token" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [[ -z "$token" ]] && return 0
  if [[ "$token" =~ ^P[0-9]+$ ]]; then
    echo ""
    return 0
  fi
  if [[ "$token" =~ ^[A-Za-z][A-Za-z0-9_-]*$ ]]; then
    echo "$token"
    return 0
  fi
  if [[ -n "$sprint" && "$token" =~ ^[0-9]+-[0-9]+$ ]]; then
    echo "${sprint}-${token}"
    return 0
  fi
  echo "$token"
}

plan_order_line() {
  grep -E '^\*\*(执行顺序|Order)\*\*' "$PLAN_FILE" 2>/dev/null | head -1 || true
}

plan_order_tokens() {
  local line="$1"
  echo "$line" | sed -E 's/^\*\*(执行顺序|Order)\*\*[：:][[:space:]]*//' \
    | tr '→' '\n' \
    | sed -E 's/`([^`]+)`/\1/g;s/^[[:space:]]+//;s/[[:space:]]+$//'
}

plan_next_in_order() {
  local after_id="${1:-}"
  local sprint line token resolved status
  sprint="$(plan_sprint)"
  line="$(plan_order_line)"
  if [[ -z "$line" ]]; then
    plan_next_pending_id
    return 0
  fi
  local found=0
  while IFS= read -r token; do
    [[ -z "$token" ]] && continue
    resolved="$(plan_resolve_task_id "$token" "$sprint")"
    [[ -z "$resolved" ]] && continue
    if [[ "$found" -eq 1 ]]; then
      status="$(plan_task_status "$resolved")"
      if [[ "$status" == "⬜" || "$status" == "🔧" ]]; then
        echo "$resolved"
        return 0
      fi
    fi
    if [[ "$resolved" == "$after_id" ]]; then
      found=1
    fi
  done < <(plan_order_tokens "$line")

  plan_next_pending_id
}

plan_next_pending_id() {
  local line id
  while IFS= read -r line; do
    id="$(echo "$line" | awk -F'|' '{gsub(/^[ \t*]+|[ \t*]+$/, "", $2); print $2}')"
    [[ -z "$id" ]] && continue
    plan_id_should_skip "$id" && continue
    echo "$id"
    return 0
  done < <(grep '| ⬜ |' "$PLAN_FILE" 2>/dev/null || true)
  echo ""
}

plan_next_task() {
  local next meta anchor status
  meta="$(plan_next_meta)"
  if [[ -n "$meta" && "$meta" != "(none)" ]]; then
    status="$(plan_task_status "$meta")"
    if [[ "$status" == "⬜" || "$status" == "🔧" ]]; then
      echo "$meta"
      return 0
    fi
  fi
  anchor="$(plan_active)"
  if [[ -z "$anchor" ]]; then
    anchor="$(plan_last_done)"
  fi
  if [[ -n "$anchor" && "$anchor" != "(none)" ]]; then
    status="$(plan_task_status "$anchor")"
    if [[ "$status" == "✅" ]]; then
      plan_next_in_order "$anchor"
      return 0
    fi
  fi
  plan_next_pending_id
}

plan_gate_ok() {
  if plan_planning; then
    echo "PLANNING"
    return 1
  fi
  if [[ -z "$(plan_plan_approved)" ]]; then
    echo "NO_APPROVAL"
    return 1
  fi
  echo "OK"
  return 0
}
