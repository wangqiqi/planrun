#!/usr/bin/env bash
# verify-publish.sh — structural checks for npm publish readiness (no upload)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

check_pkg() {
  local dir="$1"
  local pkg_json="$ROOT/$dir/package.json"
  local name version
  name="$(node -p "require('$pkg_json').name")"
  version="$(node -p "require('$pkg_json').version")"
  echo "==> $name@$version"

  if ! node -e "const p=require('$pkg_json'); if(!p.publishConfig?.access) process.exit(1)"; then
    echo "FAIL: missing publishConfig.access"
    FAIL=1
  fi
  if ! grep -q '"prepare"' "$pkg_json"; then
    echo "FAIL: missing prepare script"
    FAIL=1
  fi
  if [[ ! -f "$ROOT/$dir/lib/index.js" ]]; then
    echo "FAIL: lib/index.js missing — run pnpm run build"
    FAIL=1
  fi

  rm -f "$ROOT/$dir"/*.tgz
  (cd "$ROOT/$dir" && npm pack >/dev/null 2>&1)
  local tgz
  tgz="$(ls -1 "$ROOT/$dir"/*.tgz 2>/dev/null | head -1)"
  if [[ -z "$tgz" || ! -f "$tgz" ]]; then
    echo "FAIL: npm pack failed"
    FAIL=1
    return
  fi
  local listing
  listing="$(tar -tzf "$tgz")"
  local ok=true
  if ! grep -q '^package/lib/index.js$' <<< "$listing"; then
    echo "FAIL: tarball missing lib/index.js"
    ok=false
  fi
  if [[ "$name" == "@planrun/skill-provider" ]]; then
    if ! grep -q 'package/skills/master/SKILL.md' <<< "$listing"; then
      echo "FAIL: tarball missing bundled skills"
      ok=false
    fi
    if ! grep -q 'package/config/roles.json' <<< "$listing"; then
      echo "FAIL: tarball missing config/roles.json"
      ok=false
    fi
  fi
  if [[ "$name" == "@planrun/bundle" ]]; then
    if ! grep -q 'package/cordis.patch.yml' <<< "$listing"; then
      echo "FAIL: tarball missing cordis.patch.yml"
      ok=false
    fi
    if grep -q 'file:\.\.' "$pkg_json"; then
      echo "FAIL: bundle still uses file:../ dependencies"
      ok=false
    fi
  fi
  rm -f "$tgz"
  if [[ "$ok" != true ]]; then
    FAIL=1
    return
  fi
  echo "OK: pack structure"
}

check_pkg packages/skill-provider
check_pkg packages/workflow
check_pkg packages/bundle-planrun

if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi
echo "verify-publish: OK"
