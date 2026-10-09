#!/usr/bin/env bash
# verify-release.sh — the release triple must agree before a tag is pushed.
#
# The `github:` channel packs the whole repo, so the root version, the three
# package versions and the CHANGELOG section a user reads all describe the same
# artifact. A partial bump publishes a bundle whose `workspace:^` rewrite points
# at an unpublished version.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

root_version="$(node -p "require(process.argv[process.argv.length - 1]).version" "$ROOT/package.json")"
echo "==> release $root_version"

for pkg in skill-provider workflow bundle-planrun; do
  version="$(node -p "require(process.argv[process.argv.length - 1]).version" "$ROOT/packages/$pkg/package.json")"
  if [[ "$version" != "$root_version" ]]; then
    echo "FAIL: packages/$pkg is $version but the root is $root_version"
    FAIL=1
  else
    echo "OK: packages/$pkg $version"
  fi
done

if ! grep -q "^## \[$root_version\]" "$ROOT/CHANGELOG.md"; then
  echo "FAIL: CHANGELOG.md has no '## [$root_version]' section"
  FAIL=1
else
  echo "OK: CHANGELOG entry"
fi

if [[ -n "$(git -C "$ROOT" status --porcelain=v1)" ]]; then
  echo "FAIL: working tree is dirty — a tag must point at a committed revision"
  git -C "$ROOT" status --porcelain=v1 | sed 's/^/  /'
  FAIL=1
else
  echo "OK: working tree clean"
fi

if git -C "$ROOT" rev-parse -q --verify "refs/tags/v$root_version" >/dev/null; then
  echo "OK: tag v$root_version exists ($(git -C "$ROOT" rev-list -n 1 "v$root_version" | cut -c1-8))"
else
  echo "WARN: tag v$root_version not created yet (release step: git tag -a v$root_version)"
fi

if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi
echo "verify-release: OK"
