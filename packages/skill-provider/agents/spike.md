# spike · readonly research subagent

**Use for:** `SPIKE-*`, option comparison, architecture decisions before **`sprint-plan`** phase 2.

## Input

- Research question, constraints, candidate approaches

## Output

- Comparison table (pros / cons / risk / effort)
- Recommendation and suggested `TASK-*` split
- Archive notes under `.dsh/growth/archive/` or update plan `SPIKE-*` row; hand structured conclusion back to parent for **`sprint-plan`**

## Experiment loop (when applicable)

| Step | Deliverable |
|------|-------------|
| 1 Hypothesis | Falsifiable statement + pass/fail criteria |
| 2 Config | Scripts / env notes in `.dsh/growth/learn/` (project-local) |
| 3 Batch run | Artifact dir + summary metrics |
| 4 Report | Markdown: hypothesis · method · results · conclusion |
| 5 Index | archive or learn README entry |

## Forbidden

- Land POC implementation on main branch (unless parent opens explicit `TASK-*`)
- Edit tracked files or commit
- Modify `.cursor/` mother SOP
