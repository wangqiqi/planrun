#!/usr/bin/env bash
# verify-planrun.sh — structural checks for the planrun repo
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS="$ROOT/packages/skill-provider/skills"
EXPECTED=(master sprint-plan run review learn git scaffold long release delivery debug test security api refactor perf mcp study user-manual test-report ux ia week disk maintain code-stats-viz pencil-design md2docx-export)
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

echo "==> Checking bundle package"
if ! grep -q '"name": "@planrun/bundle"' "$ROOT/packages/bundle-planrun/package.json"; then
  echo "FAIL: bundle package name should be @planrun/bundle"
  FAIL=1
else
  echo "OK: @planrun/bundle package.json"
fi
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
for skill in learn git scaffold long release delivery debug test security api refactor perf mcp study user-manual test-report ux ia week disk maintain code-stats-viz pencil-design md2docx-export; do
  if ! grep -q "\`$skill\`" "$SKILLS/master/routes.md"; then
    echo "MISSING: master/routes.md should reference $skill"
    FAIL=1
  fi
done

echo "==> Checking persona catalog (12 personas)"
ROLES="$ROOT/packages/skill-provider/config/roles.json"
if [[ ! -f "$ROLES" ]]; then
  echo "MISSING: packages/skill-provider/config/roles.json"
  FAIL=1
else
  persona_count="$(python3 -c "import json; d=json.load(open('$ROLES')); print(len(d.get('personas',[])))")"
  default_id="$(python3 -c "import json; print(json.load(open('$ROLES')).get('default',''))")"
  if [[ "$persona_count" != "12" ]]; then
    echo "FAIL: expected 12 personas, got $persona_count"
    FAIL=1
  elif [[ "$default_id" != "dashu" ]]; then
    echo "FAIL: default persona should be dashu, got $default_id"
    FAIL=1
  else
    echo "OK: roles.json ($persona_count personas, default=$default_id)"
  fi
fi
for f in templates/growth/session/persona.json templates/growth/session/aliases.json scripts/resolve-persona.sh scripts/resolve-persona.mjs; do
  if [[ ! -f "$ROOT/$f" ]]; then
    echo "MISSING: $f"
    FAIL=1
  else
    echo "OK: $f"
  fi
done
if ! grep -q 'session/persona.json' "$ROOT/scripts/install-planrun.sh"; then
  echo "MISSING: install-planrun.sh should seed session/persona.json"
  FAIL=1
fi
if ! grep -q 'Persona' "$ROOT/packages/workflow/src/index.ts"; then
  echo "MISSING: workflow session-start persona inject"
  FAIL=1
fi

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

echo "==> Checking publish readiness"
for pkg in packages/skill-provider packages/workflow packages/bundle-planrun; do
  if ! grep -q '"publishConfig"' "$ROOT/$pkg/package.json"; then
    echo "MISSING: publishConfig in $pkg"
    FAIL=1
  elif ! grep -q '"prepare"' "$ROOT/$pkg/package.json"; then
    echo "MISSING: prepare script in $pkg"
    FAIL=1
  else
    echo "OK: $pkg publish metadata"
  fi
done
if ! grep -q '"verify:publish"' "$ROOT/package.json"; then
  echo "MISSING: verify:publish script"
  FAIL=1
else
  echo "OK: verify:publish"
fi
if [[ ! -f "$ROOT/templates/growth/scripts/dsh-guard.sh" ]]; then
  echo "MISSING: templates/growth/scripts/dsh-guard.sh"
  FAIL=1
else
  echo "OK: growth guard templates"
fi

echo "==> Checking guard cwd resolution"
GUARD_TMP="$(mktemp -d)"
mkdir -p "$GUARD_TMP/nested/.dsh/growth"
cp "$ROOT/templates/dogfood/plan-fixture.md" "$GUARD_TMP/nested/.dsh/growth/plan.md"
if ! (cd "$GUARD_TMP/nested" && bash "$ROOT/scripts/dsh-guard.sh" gate-check >/dev/null); then
  echo "FAIL: gate-check from nested cwd"
  FAIL=1
else
  echo "OK: guard resolves plan from cwd walk-up"
fi
rm -rf "$GUARD_TMP"

echo "==> Checking install guard seed"
INSTALL_TMP="$(mktemp -d)"
git -C "$INSTALL_TMP" init -q
PLANRUN_HOME="$ROOT" bash "$ROOT/scripts/install-planrun.sh" "$INSTALL_TMP" --copy-plan >/dev/null
if [[ ! -f "$INSTALL_TMP/scripts/dsh-guard.sh" ]]; then
  echo "FAIL: install-planrun.sh did not seed scripts/dsh-guard.sh"
  FAIL=1
else
  echo "OK: install-planrun.sh guard seed"
fi
rm -rf "$INSTALL_TMP"

echo "==> Checking subagent presets"
for preset in planrun planrun-review planrun-spike planrun-ship; do
  if [[ ! -f "$ROOT/presets/$preset/agent.cordis.yml" ]] || [[ ! -f "$ROOT/presets/$preset/preset.yml" ]]; then
    echo "MISSING: presets/$preset (agent.cordis.yml + preset.yml)"
    FAIL=1
  else
    echo "OK: presets/$preset"
  fi
done
if ! grep -q 'tool-subagent-review' "$ROOT/presets/planrun/agent.cordis.yml"; then
  echo "MISSING: planrun preset delegation tool-subagent-review"
  FAIL=1
elif ! grep -q 'toolFilter' "$ROOT/presets/planrun/agent.cordis.yml"; then
  echo "MISSING: planrun preset toolFilter for readonly subagents"
  FAIL=1
else
  echo "OK: planrun delegation + toolFilter"
fi
for agent in ship review spike; do
  if [[ ! -f "$ROOT/packages/skill-provider/agents/$agent.md" ]]; then
    echo "MISSING: packages/skill-provider/agents/$agent.md"
    FAIL=1
  else
    echo "OK: agents/$agent.md"
  fi
done
if ! grep -q '"agents"' "$ROOT/packages/skill-provider/package.json"; then
  echo "MISSING: skill-provider package.json files should include agents/"
  FAIL=1
fi
if [[ ! -f "$ROOT/docs/subagents.md" ]]; then
  echo "MISSING: docs/subagents.md"
  FAIL=1
else
  echo "OK: docs/subagents.md"
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
