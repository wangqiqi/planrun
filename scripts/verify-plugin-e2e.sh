#!/usr/bin/env bash
# verify-plugin-e2e.sh — prove @planrun/* actually loads in a real DSH profile.
#
# Chain: build → stage local packages → install into a throwaway profile →
#        compose config → import the plugin → boot headless.
#
# Catches the failure classes that structural checks miss:
#   * a published tarball whose `files` omit runtime siblings (import fails)
#   * dsh peer ranges the running DSH refuses (row silently disabled)
#   * a listener on a lifecycle event DSH no longer emits
#
# Requires a deepseek-harness checkout with a built CLI. Set
# DEEPSEEK_HARNESS_HOME, or keep the checkout beside this repo. Without one the
# script prints SKIP and exits 0, so `pnpm run verify` stays green.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

fail() { echo "FAIL: $*" >&2; FAIL=1; }
ok() { echo "OK: $*"; }

HARNESS="${DEEPSEEK_HARNESS_HOME:-}"
if [[ -z "$HARNESS" ]]; then
  for candidate in "$ROOT/../deepseek-harness" "$ROOT/../../deepseek-harness"; do
    if [[ -f "$candidate/apps/cli/lib/bin.js" ]]; then HARNESS="$(cd "$candidate" && pwd)"; break; fi
  done
fi
DSH_BIN="${HARNESS:+$HARNESS/apps/cli/lib/bin.js}"

if [[ -z "$HARNESS" || ! -f "$DSH_BIN" ]]; then
  echo "SKIP: deepseek-harness checkout not found (set DEEPSEEK_HARNESS_HOME with a built apps/cli)"
  exit 0
fi

if [[ -n "${PLANRUN_E2E_WORK:-}" ]]; then
  WORK="$PLANRUN_E2E_WORK"
  rm -rf "$WORK"; mkdir -p "$WORK"
  CLEANUP=false
else
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/planrun-e2e.XXXXXX")"
  CLEANUP=true
fi
cleanup() { [[ "$CLEANUP" == true ]] && rm -rf "$WORK"; return 0; }
trap cleanup EXIT

STORE="${PLANRUN_PNPM_STORE:-$ROOT/.pnpm-store}"
STORE_ARGS=()
[[ -d "$STORE" ]] && STORE_ARGS=(--store-dir "$STORE")

echo "==> build + stage"
if ! PLANRUN_PACK_OUT="$WORK/stage" "$ROOT/scripts/pack-local.sh" >"$WORK/pack.log" 2>&1; then
  fail "pack-local.sh failed"; tail -20 "$WORK/pack.log" >&2; exit 1
fi
ok "staged $(ls "$WORK/stage" | tr '\n' ' ')"

echo "==> install into throwaway profile"
PROFILE="$WORK/home/profiles/e2e"
mkdir -p "$PROFILE"
cat > "$PROFILE/package.json" <<JSON
{
  "name": "dsh-profile-e2e",
  "private": true,
  "dependencies": { "@planrun/bundle": "file:$WORK/stage/bundle-planrun" },
  "dsh": {
    "profile": {
      "bundles": [
        "@deepseek-ai/dsh-base",
        "@planrun/bundle",
        "@deepseek-ai/dsh-headless"
      ]
    }
  }
}
JSON
printf 'packages:\n  - .\n\nnodeLinker: hoisted\nautoInstallPeers: false\n' > "$PROFILE/pnpm-workspace.yaml"
printf '[]\n' > "$PROFILE/cordis.patch.yml"

if ! (cd "$PROFILE" && pnpm install "${STORE_ARGS[@]}" --prefer-offline >"$WORK/install.log" 2>&1); then
  fail "pnpm install failed"; tail -20 "$WORK/install.log" >&2; exit 1
fi
if [[ ! -d "$PROFILE/node_modules/@planrun/skill-provider/skills" ]]; then
  fail "skill-provider skills not hoisted into the profile"
else
  ok "profile resolves @planrun/skill-provider"
fi

echo "==> compose config"
dump="$(DSH_HOME="$WORK/home" node "$DSH_BIN" --profile e2e --dump-config 2>&1 || true)"
for row in 'id: planrun-skills' 'id: planrun-workflow' '@planrun/skill-provider' '@planrun/workflow' \
  'id: preset-planrun' 'id: preset-planrun-review' 'id: preset-planrun-spike' 'id: preset-planrun-ship' \
  '@deepseek-ai/dsh-agent-preset'; do
  grep -q -- "$row" <<< "$dump" || fail "dump-config missing $row"
done
[[ "$FAIL" == 0 ]] && ok "bundle rows + preset declarations appear in the composed profile"

echo "==> import plugin + skill catalog"
cat > "$WORK/smoke.mjs" <<'JS'
import { apply } from '@planrun/skill-provider'
let provider
const ctx = { skills: { registerProvider: (create) => { provider = create(); return () => {} } } }
apply(ctx)
const catalog = await provider.list()
if (catalog.length !== 28) throw new Error(`expected 28 skills, got ${catalog.length}`)
const master = await provider.get(catalog.find((candidate) => candidate.name === 'master'))
if (master === undefined || master.content.length === 0) throw new Error('master skill body did not load')
console.log(`skill-provider: ${catalog.length} skills, master ${master.content.length} chars`)
JS
if ! (cd "$PROFILE" && node "$WORK/smoke.mjs") >"$WORK/smoke.log" 2>&1; then
  fail "plugin import / catalog failed"; tail -20 "$WORK/smoke.log" >&2
else
  ok "$(cat "$WORK/smoke.log")"
fi

echo "==> boot headless"
mkdir -p "$WORK/project"
RUN=(node "$DSH_BIN" --profile e2e "reply with the single word ok")
command -v timeout >/dev/null 2>&1 && RUN=(timeout 90 "${RUN[@]}")

# Shared boot assertions: nothing retired, unresolvable, or rejected.
check_boot() {
  local label="$1" output="$2" code="$3" forbidden pending
  while IFS= read -r forbidden; do
    [[ -z "$forbidden" ]] && continue
    grep -q -- "$forbidden" <<< "$output" && fail "$label reported: $forbidden"
  done <<'PATTERNS'
failed to import
incompatible with dsh
disabling profile plugin row
format v4
producer-owned source kind
PATTERNS
  # A pending row is only expected for the preset declarations, and only on a
  # surface without the preset registry (headless); anything else is a failure.
  pending="$(grep -E '^[A-Za-z0-9@/_.-]+ \(.+\): pending' <<< "$output" \
    | grep -v '(@deepseek-ai/dsh-agent-preset): pending (waiting for service: agentPresets)' || true)"
  if [[ -n "$pending" ]]; then
    fail "$label has rows waiting on unexpected services"
    printf '%s\n' "$pending" >&2
  fi
  if [[ "$code" -ne 0 ]] && ! grep -q 'MISSING_CREDENTIAL' <<< "$output"; then
    fail "$label exited $code without reaching the model call"
    printf '%s\n' "$output" | tail -20 >&2
  fi
}

set +e
boot_out="$(cd "$WORK/project" && DSH_HOME="$WORK/home" PLANRUN_HOME="$ROOT" "${RUN[@]}" 2>&1)"
boot_code=$?
set -e
check_boot "boot" "$boot_out" "$boot_code"
[[ "$FAIL" == 0 ]] && ok "plugins loaded (boot stopped only at the model call)"

if [[ -f "$WORK/project/.dsh/growth/plan.md" ]]; then
  ok "workflow plugin seeded .dsh/growth/plan.md"
else
  fail "workflow plugin did not seed .dsh/growth/plan.md — its listeners may not be firing"
fi

echo "==> boot headless with the planrun agent preset selected"
# Mount the preset registry the Web bundle normally supplies, with `planrun` as
# the default. A declaration that is missing or broken makes the registry log
# the preset as broken and this boot fail — headless has no preset picker, so a
# selected default is the only way to exercise the declaration end to end.
cat > "$PROFILE/cordis.patch.yml" <<'YAML'
- insert:
    - id: agent-preset-registry
      name: '@deepseek-ai/dsh-agent-preset-registry'
      config:
        default: planrun
YAML
mkdir -p "$WORK/project-preset"
set +e
preset_out="$(cd "$WORK/project-preset" && DSH_HOME="$WORK/home" PLANRUN_HOME="$ROOT" "${RUN[@]}" 2>&1)"
preset_code=$?
set -e
check_boot "preset boot" "$preset_out" "$preset_code"
if grep -qE 'agent preset planrun|Unknown agent preset' <<< "$preset_out"; then
  fail "planrun preset declaration did not activate"
  printf '%s\n' "$preset_out" | tail -20 >&2
elif [[ "$preset_code" -ne 0 ]] && ! grep -q 'MISSING_CREDENTIAL' <<< "$preset_out"; then
  fail "planrun preset boot failed to compose"
  printf '%s\n' "$preset_out" | tail -20 >&2
else
  ok "planrun preset declaration mounts and composes"
fi

if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi
echo "verify-plugin-e2e: OK"
