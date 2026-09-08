#!/usr/bin/env bash
# verify-planrun.sh — structural checks for the planrun repo
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS="$ROOT/packages/skill-provider/skills"
EXPECTED=(master sprint-plan run review learn git scaffold long release delivery debug test security api refactor perf)
FORBIDDEN_PATTERNS='\.cursorGrowth|AskQuestion|runner\.sh'
FAIL=0

echo "==> Checking bundled skills (${#EXPECTED[@]})"
for name in "${EXPECTED[@]}"; do
  if [[ ! -f "$SKILLS/$name/SKILL.md" ]]; then
    echo "MISSING: skills/$name/SKILL.md"
    FAIL=1
  else
    echo "OK: $name"
  fi
done

echo "==> Checking long reference files"
for ref in hierarchy pacing-checkpoint; do
  if [[ ! -f "$SKILLS/long/reference/$ref.md" ]]; then
    echo "MISSING: long/reference/$ref.md"
    FAIL=1
  else
    echo "OK: long/reference/$ref.md"
  fi
done

echo "==> Checking delivery reference files"
for ref in checklist-core checklist-optional; do
  if [[ ! -f "$SKILLS/delivery/reference/$ref.md" ]]; then
    echo "MISSING: delivery/reference/$ref.md"
    FAIL=1
  else
    echo "OK: delivery/reference/$ref.md"
  fi
done

echo "==> Checking scaffold catalog"
if [[ ! -f "$SKILLS/scaffold/catalog.md" ]]; then
  echo "MISSING: scaffold/catalog.md"
  FAIL=1
fi

echo "==> Checking bundle patch"
if ! grep -q '@planrun/skill-provider' "$ROOT/packages/bundle-planrun/cordis.patch.yml"; then
  echo "MISSING: bundle references skill-provider"
  FAIL=1
fi
if ! grep -q '@planrun/workflow' "$ROOT/packages/bundle-planrun/cordis.patch.yml"; then
  echo "MISSING: bundle references workflow plugin"
  FAIL=1
else
  echo "OK: bundle-planrun cordis.patch.yml"
fi

echo "==> Checking @planrun/workflow package"
for f in packages/workflow/package.json packages/workflow/src/index.ts docs/workflow-hooks-map.md; do
  if [[ ! -f "$ROOT/$f" ]]; then
    echo "MISSING: $f"
    FAIL=1
  else
    echo "OK: $f"
  fi
done
if ! grep -q '"name": "@planrun/workflow"' "$ROOT/packages/workflow/package.json"; then
  echo "MISSING: @planrun/workflow package name"
  FAIL=1
fi

echo "==> Checking master routes"
if ! grep -q 'sprint-plan' "$SKILLS/master/routes.md"; then
  echo "MISSING: master/routes.md should reference sprint-plan"
  FAIL=1
fi
for skill in learn git scaffold long release delivery debug test security api refactor perf; do
  if ! grep -q "\`$skill\`" "$SKILLS/master/routes.md"; then
    echo "MISSING: master/routes.md should reference $skill"
    FAIL=1
  fi
done

echo "==> Checking DSH adaptation (no Cursor-only tokens in bundled skills)"
while IFS= read -r skill_dir; do
  base="$(basename "$skill_dir")"
  [[ "$base" == "master" ]] && continue
  if grep -qE "$FORBIDDEN_PATTERNS" "$skill_dir/SKILL.md" 2>/dev/null; then
    echo "FAIL: skills/$base/SKILL.md contains forbidden Cursor-only token"
    grep -nE "$FORBIDDEN_PATTERNS" "$skill_dir/SKILL.md" || true
    FAIL=1
  fi
  if [[ -d "$skill_dir/reference" ]]; then
    while IFS= read -r ref_file; do
      if grep -qE "$FORBIDDEN_PATTERNS" "$ref_file" 2>/dev/null; then
        echo "FAIL: $ref_file contains forbidden Cursor-only token"
        grep -nE "$FORBIDDEN_PATTERNS" "$ref_file" || true
        FAIL=1
      fi
    done < <(find "$skill_dir/reference" -name '*.md' -type f)
  fi
done < <(find "$SKILLS" -mindepth 1 -maxdepth 1 -type d)

echo "==> Checking workflow guard"
for f in scripts/dsh-guard.sh scripts/plan-parse.sh; do
  if [[ ! -f "$ROOT/$f" ]]; then
    echo "MISSING: $f"
    FAIL=1
  else
    echo "OK: $f"
  fi
done
for script in gate-check plan-check task-verify next-task; do
  if ! grep -q "\"$script\"" "$ROOT/package.json"; then
    echo "MISSING: package.json script $script"
    FAIL=1
  else
    echo "OK: pnpm run $script"
  fi
done
if [[ -f "$ROOT/scripts/dsh-guard.sh" ]]; then
  if ! bash "$ROOT/scripts/dsh-guard.sh" help 2>/dev/null | grep -q gate-check; then
    echo "FAIL: dsh-guard.sh help missing gate-check"
    FAIL=1
  fi
fi

echo "==> Checking verify:dogfood script"
if [[ ! -f "$ROOT/scripts/verify-dogfood.sh" ]]; then
  echo "MISSING: scripts/verify-dogfood.sh"
  FAIL=1
elif ! grep -q '"verify:dogfood"' "$ROOT/package.json"; then
  echo "MISSING: package.json script verify:dogfood"
  FAIL=1
else
  echo "OK: verify:dogfood"
fi

if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi

echo "verify-planrun: OK"
