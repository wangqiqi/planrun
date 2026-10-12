#!/usr/bin/env bash
# guard-fixtures.sh — regression matrix for the dsh-guard gates.
#
# Every case below passed silently on the pre-2026-10 guard:
#   bad-plan       `PLAN_APPROVED: (none)` satisfied the run gate, a missing task
#                  row killed task-verify with exit 1 and zero output, and
#                  plan-check never returned non-zero
#   fallback-fail  a failing heuristic fallback was reported as SKIP with exit 0
#   backtick-acc   the template's `command` acceptance never matched the
#                  executable branch, so the command never ran
#   parity         the shell and TS plan parsers answered differently on the
#                  same plan (skip prefixes, pending count, `(none)` VERIFY)
#   doctor         nothing proved *which* PlanRun version seeded a project, so a
#                  hand-edited guard, a stale template schema, a skewed package
#                  version and a missing manifest all had to start reporting
#
# Usage: bash scripts/guard-fixtures.sh [bad-plan|fallback-fail|backtick-acc|parity|doctor|all]
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
GUARD="$ROOT/scripts/dsh-guard.sh"
BASH_BIN="${BASH:-$(command -v bash 2>/dev/null || command -v sh)}"
MODE="${1:-all}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASSED=0
FAILED=0
pass() { PASSED=$((PASSED + 1)); echo "  ok    $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  FAIL  $1" >&2; }

OUT=""
RC=0
run_guard() {
  local plan="$1"
  shift
  OUT="$(DSH_GROWTH_PLAN="$plan" \
    DSH_GUARD_HEURISTICS="${FIX_HEURISTICS:-true}" \
    DSH_GUARD_FALLBACK_VERIFY="${FIX_FALLBACK:-}" \
    DSH_GUARD_EXEC="${FIX_EXEC:-true}" \
    "$BASH_BIN" "$GUARD" "$@" 2>&1)"
  RC=$?
}

# A Windows-style path for the Node side: Node cannot read `/e/plan/x`, and MSYS
# rewrites argv but not every env value.
win_path() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$1"
  else
    printf '%s' "$1"
  fi
}

node_parity() { # node_parity <plan> <next|pending|verify> [anchor]
  local plan="$1" kind="$2" anchor="${3:-}"
  PLAN_FIX="$(win_path "$plan")" KIND_FIX="$kind" ANCHOR_FIX="$anchor" \
    node --input-type=module -e '
      import { readFileSync } from "node:fs"
      const parser = await import("./packages/workflow/lib/plan-parser.js")
      const path = process.env.PLAN_FIX
      const content = readFileSync(path, "utf8")
      const kind = process.env.KIND_FIX
      if (kind === "next") {
        process.stdout.write(parser.nextTaskId(content, process.env.ANCHOR_FIX ?? ""))
      } else if (kind === "pending") {
        process.stdout.write(String(parser.loadPlanSnapshot(path)?.pendingCount ?? -1))
      } else {
        process.stdout.write(parser.loadPlanSnapshot(path)?.verifyCmd ?? "")
      }
    '
}

# ---------------------------------------------------------------- bad-plan ---
case_bad_plan() {
  local none="$TMP/none.md" missing="$TMP/missing.md" noappr="$TMP/noappr.md" good="$TMP/good.md"

  cat >"$none" <<'EOF'
<!-- PLANNING: false -->
<!-- PLAN_APPROVED: (none) -->
<!-- SPRINT: SPRINT-FIX -->
<!-- ACTIVE: TASK-001 -->

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | a | P0 | ⬜ | bash -c "exit 0" | x |

**执行顺序**: `TASK-001`
EOF
  run_guard "$none" gate-check
  if [[ "$RC" -ne 0 ]]; then
    pass "(none) 占位符不再算批准（gate-check rc=$RC）"
  else
    fail "(none) 占位符仍能过 gate-check：$OUT"
  fi

  cat >"$missing" <<'EOF'
<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-10-09 -->
<!-- ACTIVE: TASK-999 -->

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | a | P0 | ⬜ | bash -c "exit 0" | x |
EOF
  run_guard "$missing" task-verify TASK-999
  if [[ "$RC" -ne 0 && -n "$OUT" ]]; then
    pass "缺任务行：非零退出且给出原因（rc=$RC）"
  else
    fail "缺任务行：rc=$RC 输出字节=${#OUT}"
  fi

  cat >"$noappr" <<'EOF'
<!-- PLANNING: false -->
<!-- ACTIVE: TASK-001 -->

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | a | P0 | ⬜ | bash -c "exit 0" | x |
EOF
  run_guard "$noappr" plan-check
  if [[ "$RC" -ne 0 ]]; then
    pass "plan-check 对缺 PLAN_APPROVED 返回非零（rc=$RC）"
  else
    fail "plan-check 仍然永远返回 0：$OUT"
  fi

  cat >"$good" <<'EOF'
<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-10-09 -->
<!-- SPRINT: SPRINT-FIX -->
<!-- ACTIVE: TASK-001 -->

**Goal:** 交付一个可验证的能力模块。

**Done when:**

- [x] 能力可用

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | a | P0 | 🔧 | bash -c "exit 0" | x |

**执行顺序**: `TASK-001`
EOF
  run_guard "$good" plan-check
  if [[ "$RC" -eq 0 ]]; then
    pass "健康 plan 上 plan-check 依旧绿"
  else
    fail "健康 plan 被 plan-check 拦下（rc=$RC）：$OUT"
  fi
  run_guard "$good" gate-check
  if [[ "$RC" -eq 0 ]]; then
    pass "健康 plan 上 gate-check 依旧绿"
  else
    fail "健康 plan 被 gate-check 拦下（rc=$RC）：$OUT"
  fi
  run_guard "$good" task-verify
  if [[ "$RC" -eq 0 ]]; then
    pass "可执行验收列会跑并返回它的退出码（rc=0）"
  else
    fail "可执行验收列 rc=$RC：$OUT"
  fi
}

# ----------------------------------------------------------- fallback-fail ---
case_fallback_fail() {
  local plan="$TMP/fallback.md" failing="$TMP/failing.sh" ok="$TMP/ok.sh"
  printf '#!/usr/bin/env bash\nexit 3\n' >"$failing"
  printf '#!/usr/bin/env bash\nexit 0\n' >"$ok.sh"

  cat >"$plan" <<EOF
<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-10-09 -->
<!-- ACTIVE: TASK-001 -->
<!-- VERIFY: bash $failing -->

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | a | P0 | ⬜ | 人工确认 diff | x |
EOF
  FIX_FALLBACK=./no-such-fallback.sh
  run_guard "$plan" task-verify
  if [[ "$RC" -eq 3 ]]; then
    pass "回退校验失败会传播到 task-verify（rc=3）"
  else
    fail "回退校验失败被吞：rc=$RC，输出：$OUT"
  fi

  cat >"$plan" <<EOF
<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-10-09 -->
<!-- ACTIVE: TASK-001 -->
<!-- VERIFY: bash $ok.sh -->

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | a | P0 | 🔧 | 人工确认 diff | x |
EOF
  FIX_FALLBACK=./no-such-fallback.sh
  run_guard "$plan" task-verify
  if [[ "$RC" -eq 0 ]]; then
    pass "回退校验通过时 task-verify 仍为 0"
  else
    fail "回退校验通过却失败：rc=$RC，输出：$OUT"
  fi
  FIX_FALLBACK=""

  # No fallback script at all stays an explicit SKIP, not a failure.
  cat >"$plan" <<'EOF'
<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-10-09 -->
<!-- ACTIVE: TASK-001 -->
<!-- VERIFY: (none) -->

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | a | P0 | 🔧 | 人工确认 diff | x |
EOF
  FIX_HEURISTICS=false
  run_guard "$plan" task-verify
  if [[ "$RC" -eq 0 && "$OUT" == *SKIP* ]]; then
    pass "关掉启发式时是显式 SKIP（rc=0）"
  else
    fail "关掉启发式时期望 SKIP/rc=0，实得 rc=$RC：$OUT"
  fi
  FIX_HEURISTICS=""
}

# ------------------------------------------------------------ backtick-acc ---
case_backtick_acc() {
  local plan="$TMP/backtick.md"

  cat >"$plan" <<'EOF'
<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-10-09 -->
<!-- ACTIVE: TASK-001 -->

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | a | P0 | 🔧 | `bash -c "exit 7"` | x |
EOF
  run_guard "$plan" task-verify
  if [[ "$RC" -eq 7 ]]; then
    pass "反引号包起来的验收命令会被执行（rc=7）"
  else
    fail "反引号验收命令没有执行：rc=$RC，输出：$OUT"
  fi

  FIX_EXEC=false
  run_guard "$plan" task-verify
  if [[ "$RC" -eq 0 && "$OUT" == *"DSH_GUARD_EXEC"* ]]; then
    pass "DSH_GUARD_EXEC=false 时只打印不执行（rc=0）"
  else
    fail "DSH_GUARD_EXEC=false 未生效：rc=$RC，输出：$OUT"
  fi
  FIX_EXEC=""
}

# ----------------------------------------------------------------- parity ---
case_parity() {
  local plan="$TMP/parity.md" shell_next ts_next shell_pending ts_pending shell_verify ts_verify

  cat >"$plan" <<'EOF'
<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-10-09 -->
<!-- SPRINT: SPRINT-FIX -->
<!-- ACTIVE: TASK-001 -->
<!-- VERIFY: (none) -->

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | a | P0 | ✅ | bash -c "exit 0" | x |
| SPIKE-001 | spike | P1 | ⬜ | - | x |
| TASK-002 | b | P0 | ⬜ | bash -c "exit 0" | y |

**执行顺序**: `TASK-001` → `SPIKE-001` → `TASK-002`
EOF

  shell_next="$(DSH_GROWTH_PLAN="$plan" "$BASH_BIN" "$GUARD" next-task)"
  ts_next="$(node_parity "$plan" next TASK-001)"
  if [[ "$shell_next" == "TASK-002" ]]; then
    pass "顺序链跳过 SPIKE- 行（next = TASK-002）"
  else
    fail "顺序链没有跳过 SPIKE-：$shell_next"
  fi
  if [[ "$shell_next" == "$ts_next" ]]; then
    pass "shell 与 TS 的 next-task 一致（$shell_next）"
  else
    fail "shell 与 TS 的 next-task 不一致：shell=$shell_next ts=$ts_next"
  fi

  shell_pending="$(DSH_GROWTH_PLAN="$plan" "$BASH_BIN" "$GUARD" pending)"
  ts_pending="$(node_parity "$plan" pending)"
  if [[ "$shell_pending" == "$ts_pending" ]]; then
    pass "shell 与 TS 的待办计数一致（$shell_pending）"
  else
    fail "待办计数不一致：shell=$shell_pending ts=$ts_pending"
  fi

  shell_verify="$(. "$ROOT/scripts/plan-parse.sh" "$plan"; plan_verify)"
  ts_verify="$(node_parity "$plan" verify)"
  if [[ "$shell_verify" == "$ts_verify" ]]; then
    pass "VERIFY:(none) 两侧都回落到默认脚本（$shell_verify）"
  else
    fail "VERIFY:(none) 回落不一致：shell=$shell_verify ts=$ts_verify"
  fi

  # `**Done when:**` (the shipped template's spelling) used to be invisible to
  # the awk, making the closed-sprint check dead code.
  local done_plan="$TMP/done.md" unchecked
  cat >"$done_plan" <<'EOF'
<!-- PLANNING: false -->

**Done when:**

- [ ] one
- [x] two

**Out of scope:** nope
EOF
  unchecked="$(. "$ROOT/scripts/plan-parse.sh" "$done_plan"; plan_done_when_unchecked)"
  if [[ "$unchecked" == "1" ]]; then
    pass "Done when 检查认得 **Done when:**（未勾 1 项）"
  else
    fail "Done when 计数=$unchecked（期望 1）"
  fi

  # Zero pending must print exactly one 0.
  local zero_plan="$TMP/zero.md" zero_out
  cat >"$zero_plan" <<'EOF'
<!-- PLANNING: false -->
<!-- PLAN_APPROVED: 2026-10-09 -->

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | a | P0 | DONE | bash -c "exit 0" | x |
EOF
  zero_out="$(DSH_GROWTH_PLAN="$zero_plan" "$BASH_BIN" "$GUARD" pending)"
  if [[ "$zero_out" == "0" ]]; then
    pass "待办为 0 时只输出一个 0"
  else
    fail "待办为 0 时输出：$(printf '%q' "$zero_out")"
  fi
}

doctor_project() { # doctor_project <name> — fresh temp project with a real install
  local dir="$TMP/doctor-$1"
  rm -rf "$dir"
  mkdir -p "$dir/.git"
  printf '{"name":"doctor-fixture","scripts":{}}\n' >"$dir/package.json"
  "$BASH_BIN" "$ROOT/scripts/install-planrun.sh" "$dir" --copy-plan >/dev/null 2>&1
  printf '%s' "$dir"
}

run_doctor() { # run_doctor <project> [extra args...]
  OUT="$(node "$ROOT/scripts/planrun-doctor.mjs" --project "$1" --source "$ROOT" --no-profile "${@:2}" 2>&1)"
  RC=$?
}

expect_doctor_drift() { # expect_doctor_drift <label> <project> <needle>
  local label="$1" dir="$2" needle="$3"
  run_doctor "$dir"
  if [[ "$RC" -ne 1 ]]; then
    fail "doctor ${label}: 期望 exit 1，实得 ${RC}"
    echo "$OUT" >&2
    return
  fi
  if [[ "$OUT" != *"$needle"* ]]; then
    fail "doctor ${label}: 输出里没看到「${needle}」"
    echo "$OUT" >&2
    return
  fi
  pass "doctor ${label}: exit 1 · 命中「${needle}」"
}

case_doctor() {
  echo "==> doctor: 版本漂移体检（干净 + 四类漂移 + 非项目）"
  local dir json

  # 1) 干净安装：exit 0，且 --json 的四项检查一致
  dir="$(doctor_project clean)"
  if [[ ! -f "$dir/.dsh/growth/.planrun-manifest.json" ]]; then
    fail "doctor clean: 安装没写出版本清单"
  else
    run_doctor "$dir"
    if [[ "$RC" -ne 0 ]]; then
      fail "doctor clean: 期望 exit 0，实得 ${RC}"
      echo "$OUT" >&2
    else
      pass "doctor clean: exit 0（无漂移）"
    fi
    json="$(node "$ROOT/scripts/planrun-doctor.mjs" --project "$dir" --source "$ROOT" --no-profile --json 2>&1)"
    if printf '%s' "$json" | node -e '
        let raw = ""
        process.stdin.on("data", (chunk) => { raw += chunk })
        process.stdin.on("end", () => {
          const report = JSON.parse(raw)
          if (report.exitCode !== 0) throw new Error(`exitCode ${report.exitCode}`)
          if (!Array.isArray(report.checks) || report.checks.length !== 4) throw new Error("checks != 4")
        })
      '; then
      pass "doctor clean: --json 输出 4 项检查 · exitCode 0"
    else
      fail "doctor clean: --json 输出不可用"
      echo "$json" >&2
    fi
  fi

  # 2) guard 脚本装后被改动（清单 hash 对不上）
  dir="$(doctor_project guard-drift)"
  printf '\n# tampered\n' >>"$dir/scripts/dsh-guard.sh"
  expect_doctor_drift "guard-drift" "$dir" "安装后被改动"

  # 3) 模板 schema 漂移（清单记录的 schema 落后于当前构建）
  dir="$(doctor_project schema-drift)"
  node -e '
    const fs = require("node:fs")
    const file = process.argv[1]
    const manifest = JSON.parse(fs.readFileSync(file, "utf8"))
    manifest.planTemplateSchema = 0
    fs.writeFileSync(file, JSON.stringify(manifest, null, 2))
  ' "$dir/.dsh/growth/.planrun-manifest.json"
  expect_doctor_drift "schema-drift" "$dir" "模板 schema 漂移"

  # 4) 包版本漂移（装着的 planrun 与项目记录的版本不一致 —— 就是本 Sprint 的现场）
  dir="$(doctor_project package-drift)"
  mkdir -p "$dir/node_modules/planrun"
  printf '{"name":"planrun","version":"1.8.1"}\n' >"$dir/node_modules/planrun/package.json"
  expect_doctor_drift "package-drift" "$dir" "不一致"

  # 5) 清单缺失（装过，但证明不了版本）
  dir="$(doctor_project no-manifest)"
  rm -f "$dir/.dsh/growth/.planrun-manifest.json"
  expect_doctor_drift "no-manifest" "$dir" "没有 .dsh/growth/.planrun-manifest.json"

  # 6) 非 PlanRun 项目 → 无法判定 exit 2
  dir="$TMP/doctor-not-a-project"
  rm -rf "$dir"
  mkdir -p "$dir"
  run_doctor "$dir"
  if [[ "$RC" -eq 2 ]]; then
    pass "doctor not-a-project: exit 2（无法判定）"
  else
    fail "doctor not-a-project: 期望 exit 2，实得 ${RC}"
    echo "$OUT" >&2
  fi
}

case "${MODE}" in
  bad-plan) case_bad_plan ;;
  fallback-fail) case_fallback_fail ;;
  backtick-acc) case_backtick_acc ;;
  parity) case_parity ;;
  doctor) case_doctor ;;
  all)
    case_bad_plan
    case_fallback_fail
    case_backtick_acc
    case_parity
    case_doctor
    ;;
  *)
    echo "Unknown mode: ${MODE}（bad-plan|fallback-fail|backtick-acc|parity|doctor|all）" >&2
    exit 2
    ;;
esac

echo "guard-fixtures[${MODE}]: ${PASSED} passed · ${FAILED} failed"
[[ "$FAILED" -eq 0 ]]
