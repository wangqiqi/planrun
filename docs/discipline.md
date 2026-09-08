# Discipline (dsh-super)

Compressed standing rules adapted from Super Cursor `core.mdc` + `workflow.mdc` + `constitution.mdc`. Skills carry procedures; this file carries **must / must-not**.

## Workflow

1. **Model-visible ⟺ logged** — when using DSH, anything the model needs must be reconstructable from the session log.
2. **Plan before large work** — more than five tasks or unclear scope → write `.dsh/growth/plan.md`, confirm, then `run`.
3. **One ACTIVE task** — `run` implements a single ACTIVE row at a time.
4. **Verify before ✅** — task verify must pass before marking DONE or committing.
5. **Commit per task** — each completed TASK gets a git commit (plan-only edits excluded).
6. **Scope discipline** — no drive-by refactors; escalate to `sprint-plan` on theme or architecture change.
7. **DSH plan mode vs sprint-plan** — `/plan` is single-task design; multi-task Sprints use the `sprint-plan` skill.

## Quality

- Tests describe behavior; change obsolete tests with behavior changes.
- Prefer project-native verify scripts over ad-hoc commands.
- In deepseek-harness: follow root `AGENTS.md` and `dsh-pre-push-checks` for push evidence.

## Safety

- Never commit secrets (`.env`, credentials).
- Never force-push `main` without explicit user request.
- External skills and dependencies: review before install.

## Documentation

- One home per fact — link instead of duplicating subsystem docs.
- Non-trivial harness changes include an Agent Note in the same PR.
