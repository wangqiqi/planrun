# PlanRun subagent presets (DSH)

PlanRun ports Super Cursor **ship** · **review** · **spike** agents as DSH **agent presets** plus named delegation tools.

## Install presets

```sh
export PLANRUN_HOME=/path/to/planrun
"$PLANRUN_HOME/scripts/install-planrun.sh" --preset
```

Copies four directories into `~/.dsh/.agent-presets/`:

| Preset id | Purpose |
|-----------|---------|
| `planrun` | Sprint persona + `subagent` / `subagent_review` / `subagent_spike` / `subagent_ship` |
| `planrun-review` | Dedicated readonly review session |
| `planrun-spike` | Dedicated readonly SPIKE session |
| `planrun-ship` | Dedicated release / tag session |

Restart `dsh web` after install so the preset picker picks up new rows.

## Recommended session setup

| Layer | Choice |
|-------|--------|
| Profile bundle | `dsh plugin --profile web add @planrun/bundle` |
| Default preset | **`standard`** (full coding tools) — skills still load from bundle |
| Delegation | Copy **planrun** delegation rows into your standard preset copy, **or** switch preset to **planrun** when you need named subagent tools |

`planrun` is thinner than **standard** (workflow-focused). For daily coding, keep **standard** + PlanRun skills; use **planrun** when you want bundled `subagent_review` / `subagent_spike` / `subagent_ship` without editing standard.

## Named delegation tools (preset `planrun`)

| Tool | Mode | Readonly |
|------|------|----------|
| `subagent_review` | one-shot | yes (`toolFilter` denies write/bash/subagent) |
| `subagent_spike` | one-shot | yes |
| `subagent_ship` | continuable background | no (release writes); denies nested subagent tools |
| `subagent` | continuable | inherits parent preset |
| `subagent_fork` | one-shot fork | inherits parent preset |

### Example: review a diff

```
subagent_review(
  label: "REV-001",
  prompt: "Load review skill. Review packages/workflow since main.",
  run_in_background: false
)
```

### Example: SPIKE research

```
subagent_spike(
  label: "SPIKE-001",
  prompt: "Compare npm vs git install for @planrun/bundle. Table + TASK split.",
  run_in_background: false
)
```

### Example: ship release (background)

```
subagent_ship(
  label: "ship v1.6.0",
  prompt: "Load release skill. verify green → CHANGELOG → tag.",
  run_in_background: true
)
```

Use `list_agents` / `send_message` (from `dsh-tool-subagent-control`) for continuable children.

## Agent definitions (npm)

Bundled markdown (synced with preset persona text):

```
node_modules/@planrun/skill-provider/agents/
  review.md
  spike.md
  ship.md
```

## Mapping from Super Cursor

| Super Cursor | PlanRun |
|--------------|---------|
| `.cursor/agents/review.md` | preset `planrun-review` + `subagent_review` |
| `.cursor/agents/spike.md` | preset `planrun-spike` + `subagent_spike` |
| `.cursor/agents/ship.md` | preset `planrun-ship` + `subagent_ship` |

## Out of scope (v1.6)

- Auto-mounting `~/.dsh/.agent-presets` in `@planrun/bundle` cordis.patch (manual `--preset` only)
- Codex / Claude Code product subagent rows (remain `disabled` in upstream standard preset)
