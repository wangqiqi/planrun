# dsh-super

DSH-native agent workflow SOP collection, adapted from [Super Cursor](../cursor-ai) for [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness).

Skills, a profile bundle, and optional presets — not a fork of DSH and not a Cursor plugin.

## What ships

| Piece | Package / path | Role |
|---|---|---|
| Bundled skills | `@dsh-super/skill-provider` | 12 workflow skills (plan · run · review · learn · git · scaffold · long · release · delivery · debug · test · `master`) |
| Profile bundle | `@dsh-super/bundle-super` | `cordis.patch.yml` that mounts the skill provider |
| Agent preset | `presets/super/` | Optional `super` preset (use with `standard` + bundle in v0.1) |
| Growth templates | `templates/growth/` | Project-local `.dsh/growth/` seeds |
| Installer | `scripts/install-super-dsh.sh` | Copy growth templates and document profile setup |

## Quick start

### 1. Build packages (from this repo)

```sh
pnpm install
pnpm run build
```

Link against a local `deepseek-harness` checkout when developing:

```sh
pnpm install
# peer packages resolve from your dsh installation or file: links in package.json
```

### 2. Add the bundle to a DSH profile

```sh
dsh plugin --profile web add file:/data/test-jw/dsh-super/packages/bundle-super
```

Append to `$DSH_HOME/profiles/web/cordis.patch.yml` (or use `install-super-dsh.sh`):

```yaml
- insert:
    - id: super-skills
      name: '@dsh-super/skill-provider'
```

### 3. Install growth templates into a project

```sh
export DSH_SUPER_HOME=/data/test-jw/dsh-super
./scripts/install-super-dsh.sh --here
```

### 4. Use skills in a session

With the `standard` preset (or `super` when registered), load skills by name:

| Skill | Role |
|-------|------|
| `master` | Route when unsure which workflow to use |
| `sprint-plan` | Multi-task / Sprint planning (not DSH `/plan` plan mode) |
| `run` | Execute ACTIVE tasks from `.dsh/growth/plan.md` |
| `review` | Structured code / PR review |
| `learn` | Project conventions → `.dsh/growth/learn/` |
| `git` | Branches, commits, merge; harness pre-push when applicable |
| `scaffold` | Empty-repo templates (mother-repo `scaffold.sh`) |
| `long` | Multi-Sprint Epic scheduling |
| `release` | Merge, PR, tag, CHANGELOG ship exit |
| `delivery` | Pre-ship 7-dim checklist |
| `debug` | Reproduce-first debug loop |
| `test` | TDD, layers, E2E patterns |

User invocation: skill slash commands where the DSH client supports them.

## Naming vs Super Cursor

| Super Cursor | dsh-super |
|---|---|
| `plan` skill | `sprint-plan` |
| `.cursorGrowth/` | `.dsh/growth/` |
| `AskQuestion` | `ask_user_question` tool |
| `rules/*.mdc` | `docs/discipline.md` |

See [docs/mapping-from-super-cursor.md](docs/mapping-from-super-cursor.md).

## Repository layout

```
packages/
  skill-provider/    # Cordis plugin + bundled skills/
  bundle-super/      # dsh.bundle.patch entry
presets/super/       # agent preset (evolving)
templates/growth/    # plan.md mirror, learn/, archive/
docs/                # mapping, quickstart, naming
scripts/             # install-super-dsh.sh, verify-super-dsh.sh
```

## Roadmap

- **v0.1** — MVP skills (`master` · `sprint-plan` · `run` · `review`) + bundle + installer
- **v0.2 batch-1** — `learn` · `git` · `scaffold` · `long`
- **v0.2 batch-2** — `release` · `delivery` · `debug` · `test` (current)
- **v0.3** — `@dsh-super/workflow` plugin (gates, pre-step injection)

## License

MIT
