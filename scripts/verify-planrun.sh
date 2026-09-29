#!/usr/bin/env bash
# verify-planrun.sh — structural checks for the planrun repo
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS="$ROOT/packages/skill-provider/skills"
EXPECTED=(master sprint-plan run review learn git scaffold long release delivery debug test security api refactor perf mcp study user-manual test-report ux ia week disk maintain code-stats-viz pencil-design md2docx-export)
FORBIDDEN_PATTERNS='\.cursorGrowth|AskQuestion|runner\.sh'
RETIRED_PATTERNS='install-planrun\.sh --preset|\.agent-presets|agent/session-start'
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
for f in packages/workflow/package.json packages/workflow/src/index.ts docs/en/workflow-hooks-map.md; do
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
  echo "MISSING: workflow agent/created persona inject"
  FAIL=1
fi
if node - "$ROOT/packages/workflow/src/index.ts" "$ROOT/packages/workflow/src/dsh-shim.ts" <<'NODE'
const fs = require('node:fs')
let bad = false
for (const file of process.argv.slice(1).filter((arg) => arg !== '-')) {
  // Strip comments so prose about the retired names does not count as usage.
  const source = fs.readFileSync(file, 'utf8')
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/\/\/.*$/gm, '')
  if (/agent\/session-start|kind:\s*['"]plugin['"]/.test(source)) {
    console.error(`  ${file}`)
    bad = true
  }
}
process.exit(bad ? 1 : 0)
NODE
then
  echo "OK: workflow uses agent/created + producer-owned message source"
else
  echo "FAIL: workflow still uses a retired DSH API (agent/session-start or kind:'plugin')"
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

echo "==> Checking retired surfaces (preset install path · session-start event)"
# These tokens were valid before v1.7 and are wrong now; scan every bundled
# markdown file, including master/routes.md, which the Cursor-token loop skips.
retired=0
while IFS= read -r skill_md; do
  if grep -qE "$RETIRED_PATTERNS" "$skill_md" 2>/dev/null; then
    echo "FAIL: $skill_md references a retired surface"
    grep -nE "$RETIRED_PATTERNS" "$skill_md" || true
    FAIL=1
    retired=1
  fi
done < <(find "$SKILLS" -name '*.md' -type f)
if [[ "$retired" -eq 0 ]]; then
  echo "OK: no retired install/event tokens in bundled skills"
fi

echo "==> Checking markdown links"
if ! node "$ROOT/scripts/verify-doc-links.mjs"; then
  FAIL=1
fi

echo "==> Checking committed GitHub-install runtime"
if ! bash "$ROOT/scripts/verify-lib-sync.sh"; then
  FAIL=1
fi

echo "==> Checking workflow plugin tests (plan-mode stand-down · steer chaining)"
if ! (cd "$ROOT" && pnpm --filter @planrun/workflow run test) >/dev/null 2>&1; then
  echo "FAIL: workflow tests failed — run: pnpm --filter @planrun/workflow run test"
  FAIL=1
else
  echo "OK: workflow plugin tests"
fi

echo "==> Checking tracked files are not gitignored"
# A tracked-but-ignored file is dropped by `npm pack`/git packaging, so a
# `github:` install silently loses it (this is how templates/growth/plan.md went
# missing). git check-ignore hides tracked files unless --no-index is passed.
if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  dropped="$(git -C "$ROOT" ls-files | git -C "$ROOT" check-ignore --stdin --no-index 2>/dev/null || true)"
  if [[ -n "$dropped" ]]; then
    echo "FAIL: tracked files are gitignored — installs will drop them:"
    printf '  %s\n' $dropped
    FAIL=1
  else
    echo "OK: no tracked file is gitignored"
  fi
else
  echo "SKIP: not a git checkout"
fi


echo "==> Checking skill-name conflicts with official DSH skills/commands"
# Official bundled skills a stock DSH install provides, plus the built-in slash
# commands. A same-name skill would shadow — or be shadowed — non-deterministically
# at equal rank, and a same-name command collides in the command palette.
OFFICIAL_SKILLS="dsh-badge office-docx office-pptx office-xlsx cordis-composition-reference cordis-plugin-development editing-cordis-compositions"
OFFICIAL_COMMANDS="file goal plan feedback compact permission model export"
skill_conflict=0
while IFS= read -r skill_dir; do
  base="$(basename "$skill_dir")"
  skill_name="$(sed -n '1,8p' "$skill_dir/SKILL.md" | grep -m1 '^name:' | sed 's/^name:[[:space:]]*//')"
  [[ -z "$skill_name" ]] && skill_name="$base"
  for official in $OFFICIAL_SKILLS $OFFICIAL_COMMANDS; do
    if [[ "$skill_name" == "$official" ]]; then
      echo "FAIL: skills/$base (name: $skill_name) collides with official DSH name '$official'"
      skill_conflict=1
      FAIL=1
    fi
  done
  if [[ "$skill_name" != "$base" ]]; then
    echo "FAIL: skills/$base frontmatter name '$skill_name' differs from its directory"
    FAIL=1
  fi
done < <(find "$SKILLS" -mindepth 1 -maxdepth 1 -type d)
if [[ "$skill_conflict" -eq 0 ]]; then
  echo "OK: no skill/command name collisions with official DSH"
fi
if grep -q 'PLANRUN_SKILL_RANK = 650' "$ROOT/packages/skill-provider/src/dsh-skill-shim.ts"; then
  echo "OK: PlanRun skill rank 650 (above DSH bundled 600)"
else
  echo "FAIL: PlanRun skill rank must stay above DSH's bundled rank (600)"
  FAIL=1
fi
stray_files="$(find "$ROOT/packages" -path '*/node_modules' -prune -o -path '*/src/*' \
  \( -name '*.js' -o -name '*.d.ts' -o -name '*.map' \) -print)"
if [[ -n "$stray_files" ]]; then
  echo "FAIL: stray compiler output beside TypeScript sources (packages/*/src)"
  printf '%s\n' "$stray_files" | sed 's#^#  #'
  FAIL=1
else
  echo "OK: no stray build artifacts under packages/*/src"
fi

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
  if [[ ! -f "$ROOT/presets/$preset/plugins.yml" ]] || [[ ! -f "$ROOT/presets/$preset/preset.yml" ]]; then
    echo "MISSING: presets/$preset (plugins.yml + preset.yml)"
    FAIL=1
  elif ! grep -q "^id: $preset$" "$ROOT/presets/$preset/preset.yml"; then
    echo "MISSING: presets/$preset/preset.yml id: $preset"
    FAIL=1
  else
    echo "OK: presets/$preset"
  fi
done
if ! grep -q 'tool-subagent-review' "$ROOT/presets/planrun/plugins.yml"; then
  echo "MISSING: planrun preset delegation tool-subagent-review"
  FAIL=1
elif ! grep -q 'toolFilter' "$ROOT/presets/planrun/plugins.yml"; then
  echo "MISSING: planrun preset toolFilter for readonly subagents"
  FAIL=1
else
  echo "OK: planrun delegation + toolFilter"
fi
if ! node "$ROOT/scripts/gen-presets.mjs" --check; then
  FAIL=1
fi
PRESET_PATCH="$ROOT/packages/bundle-planrun/presets.patch.yml"
if [[ ! -f "$PRESET_PATCH" ]]; then
  echo "MISSING: packages/bundle-planrun/presets.patch.yml"
  FAIL=1
else
  for preset in planrun planrun-review planrun-spike planrun-ship; do
    if ! grep -q "id: preset-$preset$" "$PRESET_PATCH"; then
      echo "MISSING: presets.patch.yml declaration preset-$preset"
      FAIL=1
    fi
  done
  if ! grep -q "@deepseek-ai/dsh-agent-preset" "$PRESET_PATCH"; then
    echo "MISSING: presets.patch.yml must declare @deepseek-ai/dsh-agent-preset"
    FAIL=1
  else
    echo "OK: presets.patch.yml declarations"
  fi
  if ! node -e "
    const p = require('$ROOT/packages/bundle-planrun/package.json')
    const patch = p.dsh?.bundle?.patch
    const list = Array.isArray(patch) ? patch : [patch]
    if (!list.includes('./presets.patch.yml')) process.exit(1)
    if (!(p.files ?? []).includes('presets.patch.yml')) process.exit(1)
  "; then
    echo "FAIL: bundle manifest must declare and ship ./presets.patch.yml"
    FAIL=1
  else
    echo "OK: bundle manifest ships presets.patch.yml"
  fi
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
if [[ ! -f "$ROOT/docs/en/subagents.md" ]]; then
  echo "MISSING: docs/en/subagents.md"
  FAIL=1
else
  echo "OK: docs/en/subagents.md"
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

echo "==> Checking docs path neutrality"
if ! bash "$ROOT/scripts/verify-docs-paths.sh"; then
  FAIL=1
fi

if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi

echo "verify-planrun: OK"
