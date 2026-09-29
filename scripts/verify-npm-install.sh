#!/usr/bin/env bash
# verify-npm-install.sh — install the published bundle from the registry.
#
# The other two channels are covered: verify:e2e stages the workspace and
# verify:github installs from git. Neither proves the artifact users get from
# `dsh plugin add @planrun/bundle` actually resolves and boots, so this does
# that against the real registry.
#
# Usage:
#   bash scripts/verify-npm-install.sh                 # @planrun/bundle@<repo version>
#   bash scripts/verify-npm-install.sh @planrun/bundle@1.8.1
#   PLANRUN_NPM_SPEC=… bash scripts/verify-npm-install.sh
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

VERSION="$(node -p "require('$ROOT/packages/bundle-planrun/package.json').version")"
SPEC="${1:-${PLANRUN_NPM_SPEC:-@planrun/bundle@$VERSION}}"

if [[ -n "${PLANRUN_NPM_WORK:-}" ]]; then
  WORK="$PLANRUN_NPM_WORK"; rm -rf "$WORK"; mkdir -p "$WORK"; CLEANUP=false
else
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/planrun-npm.XXXXXX")"; CLEANUP=true
fi
cleanup() { [[ "$CLEANUP" == true ]] && rm -rf "$WORK"; return 0; }
trap cleanup EXIT

PROFILE="$WORK/home/profiles/npm"
mkdir -p "$PROFILE" "$WORK/project"

echo "==> install $SPEC from the registry"
cat > "$PROFILE/package.json" <<JSON
{
  "name": "dsh-profile-npm",
  "private": true,
  "dependencies": { "@planrun/bundle": "$SPEC" },
  "dsh": {
    "profile": {
      "bundles": ["@deepseek-ai/dsh-base", "@planrun/bundle", "@deepseek-ai/dsh-headless"]
    }
  }
}
JSON
printf 'packages:\n  - .\n\nnodeLinker: hoisted\nautoInstallPeers: false\n' > "$PROFILE/pnpm-workspace.yaml"
printf '[]\n' > "$PROFILE/cordis.patch.yml"

if ! (cd "$PROFILE" && pnpm install --store-dir "$WORK/store" --prefer-offline) >"$WORK/install.log" 2>&1; then
  fail "pnpm install failed for $SPEC (is that version published?)"
  tail -25 "$WORK/install.log" >&2
  exit 1
fi
ok "installed $SPEC"

if [[ -d "$PROFILE/node_modules/@planrun/skill-provider/skills" ]]; then
  ok "bundled skills present in the tarball"
else
  fail "installed @planrun/skill-provider ships no skills/ — check the package 'files' field"
fi

echo "==> compose config"
dump="$(DSH_HOME="$WORK/home" node "$DSH_BIN" --profile npm --dump-config 2>&1 || true)"
for row in 'id: planrun-skills' 'id: planrun-workflow' 'id: preset-planrun' '@deepseek-ai/dsh-agent-preset'; do
  grep -q -- "$row" <<< "$dump" || fail "dump-config missing $row"
done
[[ "$FAIL" == 0 ]] && ok "bundle rows + preset declarations composed"

echo "==> boot headless"
RUN=(node "$DSH_BIN" --profile npm "reply with the single word ok")
command -v timeout >/dev/null 2>&1 && RUN=(timeout 90 "${RUN[@]}")
set +e
boot_out="$(cd "$WORK/project" && DSH_HOME="$WORK/home" "${RUN[@]}" 2>&1)"
boot_code=$?
set -e
for forbidden in 'failed to import' 'incompatible with dsh' 'disabling profile plugin row' \
  'format v4' 'producer-owned source kind'; do
  grep -q -- "$forbidden" <<< "$boot_out" && fail "boot reported: $forbidden"
done
if [[ "$boot_code" -ne 0 ]] && ! grep -q 'MISSING_CREDENTIAL' <<< "$boot_out"; then
  fail "boot exited $boot_code without reaching the model call"
  printf '%s\n' "$boot_out" | tail -20 >&2
else
  ok "plugins loaded from the published bundle"
fi
if [[ -f "$WORK/project/.dsh/growth/plan.md" ]]; then
  ok "workflow plugin seeded .dsh/growth/plan.md"
else
  fail "workflow plugin did not seed .dsh/growth/plan.md"
fi

if [[ "$FAIL" -ne 0 ]]; then exit 1; fi
echo "verify-npm-install: OK ($SPEC)"
