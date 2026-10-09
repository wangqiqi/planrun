#!/usr/bin/env bash
# verify-publish.sh — structural checks for npm publish readiness (no upload)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

# npm writes pack logs under its cache (default ~/.npm); keep it in a scratch
# dir so the check runs in sandboxes and CI homes that deny $HOME writes.
NPM_CACHE="$(mktemp -d "${TMPDIR:-/tmp}/planrun-npm-cache.XXXXXX")"
trap 'rm -rf "$NPM_CACHE"' EXIT
export npm_config_cache="$NPM_CACHE"

check_pkg() {
  local dir="$1"
  local pkg_json="$ROOT/$dir/package.json"
  local name version
  # Paths go in as argv: an MSYS-style `/e/repo/...` embedded in the script text
  # is resolved by Node against the current drive root (MODULE_NOT_FOUND).
  name="$(node -p "require(process.argv[process.argv.length - 1]).name" "$pkg_json")"
  version="$(node -p "require(process.argv[process.argv.length - 1]).version" "$pkg_json")"
  echo "==> $name@$version"

  if ! node -e "const p=require(process.argv[process.argv.length - 1]); if(!p.publishConfig?.access) process.exit(1)" "$pkg_json"; then
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
  # `pnpm pack`, not `npm pack`: only pnpm rewrites `workspace:^` to a real
  # version, so only its tarball is the artifact a consumer would resolve. The
  # guard also aborts the script under `set -e`, which made the FAIL branch below
  # unreachable.
  if ! (cd "$ROOT/$dir" && pnpm pack >/dev/null 2>&1); then
    echo "FAIL: pnpm pack failed"
    FAIL=1
    return
  fi
  local tgz tgz_tar
  tgz="$(ls -1 "$ROOT/$dir"/*.tgz 2>/dev/null | head -1)"
  if [[ -z "$tgz" || ! -f "$tgz" ]]; then
    echo "FAIL: pnpm pack produced no tarball"
    FAIL=1
    return
  fi
  # GNU tar reads a `E:\...` argument as a remote host spec ("Cannot connect to
  # E: resolve failed"), so hand it a POSIX path. cygpath only exists on Windows.
  tgz_tar="$tgz"
  if command -v cygpath >/dev/null 2>&1; then
    tgz_tar="$(cygpath -u "$tgz")"
  fi
  local listing
  listing="$(tar -tzf "$tgz_tar")"
  local ok=true
  if ! grep -q '^package/lib/index.js$' <<< "$listing"; then
    echo "FAIL: tarball missing lib/index.js"
    ok=false
  fi
  # Every emitted top-level runtime module must ship: lib/index.js imports its
  # siblings (e.g. ./load-bundled-skills.js), so a tarball with only index.js
  # installs but fails to import at plugin load time.
  local file module
  while IFS= read -r file; do
    module="lib/${file#"$ROOT/$dir"/lib/}"
    if ! grep -q "^package/$module$" <<< "$listing"; then
      echo "FAIL: tarball missing runtime module $module"
      ok=false
    fi
  done < <(find "$ROOT/$dir/lib" -type f -name '*.js' | sort)
  if [[ "$name" == "@planrun/skill-provider" ]]; then
    if ! grep -q 'package/skills/master/SKILL.md' <<< "$listing"; then
      echo "FAIL: tarball missing bundled skills"
      ok=false
    fi
    if ! grep -q 'package/config/roles.json' <<< "$listing"; then
      echo "FAIL: tarball missing config/roles.json"
      ok=false
    fi
    if ! grep -q 'package/agents/ship.md' <<< "$listing"; then
      echo "FAIL: tarball missing agents/*.md"
      ok=false
    fi
  fi
  if [[ "$name" == "@planrun/bundle" ]]; then
    local patch
    while IFS= read -r patch; do
      [[ -z "$patch" ]] && continue
      if ! grep -q "^package/${patch#./}$" <<< "$listing"; then
        echo "FAIL: tarball missing declared bundle patch $patch"
        ok=false
      fi
    done < <(node -e "const p=require(process.argv[process.argv.length - 1]);const v=p.dsh&&p.dsh.bundle&&p.dsh.bundle.patch;const list=Array.isArray(v)?v:(v===undefined?[]:[v]);for(const e of list)console.log(e)" "$pkg_json")
    if grep -q 'file:\.\.' "$pkg_json"; then
      echo "FAIL: bundle still uses file:../ dependencies"
      ok=false
    fi
  fi
  # The manifest inside the tarball is what a consumer resolves. `pnpm publish`
  # rewrites `workspace:^` to semver, but nothing verified that, so a publish
  # through another path could ship an unresolvable protocol.
  local packed_manifest
  if packed_manifest="$(tar -xzOf "$tgz_tar" package/package.json 2>/dev/null)" && [[ -n "$packed_manifest" ]]; then
    if grep -q '"workspace:' <<< "$packed_manifest"; then
      echo "FAIL: published manifest still contains a workspace: range"
      ok=false
    fi
  else
    echo "FAIL: cannot read package/package.json out of the tarball"
    ok=false
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
