#!/usr/bin/env bash
# verify-docs-paths.sh — forbid machine-specific paths in docs/ (platform-neutral install docs)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS="$ROOT/docs"
FAIL=0

FORBIDDEN=(
  '/data/test-jw'
  '/data/workspace'
)

echo "==> Checking docs/ for machine-specific paths"

for pattern in "${FORBIDDEN[@]}"; do
  if matches="$(grep -rl "$pattern" "$DOCS" 2>/dev/null || true)"; then
    if [[ -n "$matches" ]]; then
      echo "FAIL: docs must not contain '$pattern':"
      echo "$matches"
      FAIL=1
    fi
  fi
done

if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi

if [[ ! -f "$DOCS/install.md" ]]; then
  echo "MISSING: docs/install.md"
  exit 1
fi

echo "OK: docs path neutrality"
echo "OK: docs/install.md present"
