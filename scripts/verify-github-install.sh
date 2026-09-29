#!/usr/bin/env bash
# verify-github-install.sh — prove the GitHub channel works end to end.
#
# `dsh plugin add github:wangqiqi/planrun` fetches sources, pnpm runs the root
# `prepare` (scripts/build-for-git.mjs) to build lib/, and DSH mounts the root
# `cordis.patch.yml` (relative rows) plus the preset declarations. This script
# reproduces that in a throwaway profile and boots it.
#
# Usage:
#   bash scripts/verify-github-install.sh [git-spec]
#   PLANRUN_GIT_SPEC="git+file:///path/to/checkout#main" bash scripts/verify-github-install.sh
#
# Default spec is the pushed GitHub repo; the file:// form lets you test a local
# commit before pushing. Requires a built deepseek-harness checkout.
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

SPEC="${1:-${PLANRUN_GIT_SPEC:-github:wangqiqi/planrun}}"

if [[ -n "${PLANRUN_GITHUB_WORK:-}" ]]; then
  WORK="$PLANRUN_GITHUB_WORK"; rm -rf "$WORK"; mkdir -p "$WORK"; CLEANUP=false
else
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/planrun-github.XXXXXX")"; CLEANUP=true
fi
cleanup() { [[ "$CLEANUP" == true ]] && rm -rf "$WORK"; return 0; }
trap cleanup EXIT

PROFILE="$WORK/home/profiles/gh"
mkdir -p "$PROFILE" "$WORK/project"

echo "==> install $SPEC into a throwaway profile"
cat > "$PROFILE/package.json" <<JSON
{
  "name": "dsh-profile-gh",
  "private": true,
  "dependencies": { "planrun": "$SPEC" },
  "dsh": {
    "profile": {
      "bundles": ["@deepseek-ai/dsh-base", "planrun", "@deepseek-ai/dsh-headless"]
    }
  }
}
JSON
# No build permission is granted on purpose: the repo root declares no
# `prepare`, so pnpm must install the git dependency without running any build
# script — the runtime it mounts is the committed packages/*/lib/*.js.
cat > "$PROFILE/pnpm-workspace.yaml" <<'YAML'
packages:
  - .

nodeLinker: hoisted
autoInstallPeers: false
YAML
printf '[]\n' > "$PROFILE/cordis.patch.yml"

if ! (cd "$PROFILE" && pnpm install --store-dir "$WORK/store" --prefer-offline) >"$WORK/install.log" 2>&1; then
  fail "pnpm install failed"
  tail -25 "$WORK/install.log" >&2
  echo "hint: a git dependency that declares prepare/prepublish needs an allowBuilds entry; this channel must not" >&2
  exit 1
fi
ok "installed without any build permission"

if [[ -f "$PROFILE/node_modules/planrun/packages/skill-provider/lib/index.js" ]]; then
  ok "committed runtime present in the checkout (no build ran)"
else
  fail "packages/skill-provider/lib/index.js missing — is the runtime committed?"
fi
if [[ -d "$PROFILE/node_modules/yaml" ]]; then
  ok "root dependency yaml resolved"
else
  fail "root dependency yaml missing — the skill provider cannot parse frontmatter"
fi

echo "==> compose config"
dump="$(DSH_HOME="$WORK/home" node "$DSH_BIN" --profile gh --dump-config 2>&1 || true)"
for row in 'id: planrun-git-skills' 'id: planrun-git-workflow' './packages/skill-provider/lib/index.js' \
  'id: preset-planrun' '@deepseek-ai/dsh-agent-preset'; do
  grep -q -- "$row" <<< "$dump" || fail "dump-config missing $row"
done
[[ "$FAIL" == 0 ]] && ok "root patch + preset declarations composed"

echo "==> boot headless"
RUN=(node "$DSH_BIN" --profile gh "reply with the single word ok")
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
  ok "plugins loaded from the GitHub-installed bundle"
fi
if [[ -f "$WORK/project/.dsh/growth/plan.md" ]]; then
  ok "workflow plugin seeded .dsh/growth/plan.md"
else
  fail "workflow plugin did not seed .dsh/growth/plan.md"
fi

if [[ "$FAIL" -ne 0 ]]; then exit 1; fi
echo "verify-github-install: OK ($SPEC)"
