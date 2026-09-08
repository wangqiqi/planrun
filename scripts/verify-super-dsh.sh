#!/usr/bin/env bash
# verify-super-dsh.sh — structural checks for the dsh-super repo
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS="$ROOT/packages/skill-provider/skills"
EXPECTED=(master sprint-plan run review)
FAIL=0

echo "==> Checking MVP skills"
for name in "${EXPECTED[@]}"; do
  if [[ ! -f "$SKILLS/$name/SKILL.md" ]]; then
    echo "MISSING: skills/$name/SKILL.md"
    FAIL=1
  else
    echo "OK: $name"
  fi
done

echo "==> Checking bundle patch"
if ! grep -q '@dsh-super/skill-provider' "$ROOT/packages/bundle-super/cordis.patch.yml"; then
  echo "MISSING: bundle references skill-provider"
  FAIL=1
fi

echo "==> Checking routes reference sprint-plan"
if ! grep -q 'sprint-plan' "$SKILLS/master/routes.md"; then
  echo "MISSING: master/routes.md should reference sprint-plan"
  FAIL=1
fi

if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi

echo "verify-super-dsh: OK"
