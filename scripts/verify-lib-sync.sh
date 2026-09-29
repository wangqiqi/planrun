#!/usr/bin/env bash
# verify-lib-sync.sh — the committed GitHub-install runtime must match src/.
#
# The `github:` channel has no build step (the repo root declares no `prepare`,
# so pnpm never asks for build permission). That only works while the runtime
# entry points are committed, so rebuild and fail when they are stale or when a
# runtime module exists on disk but is not tracked.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "SKIP: not a git checkout"
  exit 0
fi

pnpm run build >/dev/null

stale="$(git diff --name-only -- 'packages/*/lib/*.js')"
if [[ -n "$stale" ]]; then
  echo "FAIL: committed runtime is stale — rebuild and commit these:"
  printf '  %s\n' $stale
  exit 1
fi

untracked="$(git ls-files --others --exclude-standard -- 'packages/*/lib/*.js')"
if [[ -n "$untracked" ]]; then
  echo "FAIL: runtime module not committed — a git install would miss it:"
  printf '  %s\n' $untracked
  exit 1
fi

echo "OK: committed lib/*.js matches a fresh build"
