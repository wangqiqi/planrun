# Quickstart

## 1. Build

```sh
cd /data/test-jw/dsh-super
pnpm install
pnpm run build
pnpm run verify
```

DevDependencies point at sibling `deepseek-harness` for `@deepseek-ai/cordis` and `@deepseek-ai/dsh-skill`.

## 2. Install the bundle

On a machine with `dsh` installed:

```sh
export DSH_SUPER_HOME=/data/test-jw/dsh-super
dsh plugin --profile web add "file:$DSH_SUPER_HOME/packages/bundle-super"
```

Or append to `$DSH_HOME/profiles/web/cordis.patch.yml`:

```yaml
- insert:
    - id: super-skills
      name: '@dsh-super/skill-provider'
```

## 3. Project growth templates

```sh
./scripts/install-super-dsh.sh --here
```

Creates `.dsh/growth/` at the Git project root.

## 4. Use in a session

With the **standard** preset:

| Situation | Load |
|---|---|
| Unsure which workflow | `master` |
| Multi-task / Sprint planning | `sprint-plan` |
| Execute ACTIVE tasks | `run` |
| PR / code review | `review` |
| Single-task design | DSH **`/plan`** (plan mode) |

## 5. Super Cursor mapping

See [mapping-from-super-cursor.md](mapping-from-super-cursor.md) and [naming.md](naming.md).

中文: [quickstart.zh.md](quickstart.zh.md)
