# PlanRun subagent presets (DSH)

PlanRun ports Super Cursor **ship** · **review** · **spike** agents as DSH **agent presets** plus named delegation tools.

## Install presets

The four presets ship **inside the bundle** as `@deepseek-ai/dsh-agent-preset`
declarations (`packages/bundle-planrun/presets.patch.yml`), so installing the
bundle is all it takes:

```sh
dsh plugin --profile web add "github:wangqiqi/planrun#<tag>"   # current release: #v1.9.2

# npm (not published yet):
dsh plugin --profile web add @planrun/bundle

# repo dev:
"$PLANRUN_HOME/scripts/pack-local.sh"
dsh plugin --profile web add "file:$PLANRUN_HOME/dist-local/bundle-planrun"
```

Restart `dsh web`; the preset picker lists:

| Preset id | Purpose |
|-----------|---------|
| `planrun` | Sprint persona + `subagent` / `subagent_review` / `subagent_spike` / `subagent_ship` |
| `planrun-review` | Dedicated readonly review session |
| `planrun-spike` | Dedicated readonly SPIKE session |
| `planrun-ship` | Dedicated release / tag session |

> DSH no longer reads `$DSH_HOME/.agent-presets/<id>/` directories
> (`preset.yml` + `agent.cordis.yml`). Agent presets are bundle-patch
> declarations now, so the old `install-planrun.sh --preset` path is gone.
> Presets appear on surfaces that mount `@deepseek-ai/dsh-agent-preset-registry`
> — the Web bundle does; the headless bundle does not, where the declaration
> rows stay pending and print a harmless "did not activate" warning.

Editing a preset: change `presets/<id>/{preset.yml,plugins.yml}`, run
`node scripts/gen-presets.mjs`, and reinstall the bundle. `pnpm run verify`
fails when the generated patch is stale.

## Recommended session setup

| Layer | Choice |
|-------|--------|
| Profile bundle | `dsh plugin --profile web add "github:wangqiqi/planrun#<tag>"` (npm equivalent `@planrun/bundle` pending publish) |
| Default preset | **`standard`** (full coding tools) — skills still load from bundle |
| Delegation | Copy **planrun** delegation rows into your standard preset copy, **or** switch preset to **planrun** when you need named subagent tools |

`planrun` is thinner than **standard** (workflow-focused). For daily coding, keep **standard** + PlanRun skills; use **planrun** when you want bundled `subagent_review` / `subagent_spike` / `subagent_ship` without editing standard.

## Named delegation tools (preset `planrun`)

| Tool | Child preset | Readonly |
|------|--------------|----------|
| `subagent_review` | `agentPreset: planrun-review` | yes (the child preset ships no write/bash/delegation tools) |
| `subagent_spike` | `agentPreset: planrun-spike` | yes |
| `subagent_ship` | `agentPreset: planrun-ship` | no (release writes; the child preset ships no delegation tools) |
| `subagent` | inherits parent preset | inherits parent preset |
| `subagent_fork` | inherits parent preset | inherits parent preset |

> DSH ≥0.2 removed the per-tool `persona` and `toolFilter` config: a delegation
> tool now selects a child **agent preset** with `agentPreset`, and the preset's
> plugin list is the restriction. The readonly guarantee therefore lives in
> `planrun-review` / `planrun-spike` (no `tool-bash` / `tool-fs` write rows, no
> subagent rows); keep those presets installed or the named tools lose their
> isolation.

### Example: review a diff

```
subagent_review(
  description: "review REV-001",
  prompt: "Load review skill. Review packages/workflow since main."
)
```

### Example: SPIKE research

```
subagent_spike(
  description: "SPIKE-001 research",
  prompt: "Compare npm vs git install for @planrun/bundle. Table + TASK split."
)
```

### Example: ship release

```
subagent_ship(
  description: "ship v1.8.3",
  prompt: "Load release skill. verify green → CHANGELOG → tag."
)
```

The spawn provider is continuable, so `send_message` continues a finished child;
`run_in_background` / `label` are gone from the tool surface.

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

- Codex / Claude Code product subagent rows (remain `disabled` in upstream standard preset)
