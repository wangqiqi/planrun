# 纪律摘要（PlanRun）

由 Super Cursor `core.mdc` · `workflow.mdc` · `constitution.mdc` 压缩的常驻规则。流程细节在 skills；本页只列 **必须 / 禁止**。

## 工作流

1. **模型可见 ⟺ 可审计** — DSH 会话里模型需要的信息，应能从日志重建。
2. **大改先规划** — 超过五个任务或范围不清 → 写 `.dsh/growth/plan.md`，确认后再 `run`。
3. **单一 ACTIVE** — `run` 一次只实现 plan 里一行 ACTIVE 任务。
4. **verify 后才 ✅** — `task-verify` 通过才能标 DONE 或 commit。
5. **一任务一 commit** — 每个完成的 TASK 单独提交（仅改 plan 除外）。
6. **守 scope** — 禁止顺手大重构；新 Theme / 架构变更回 `sprint-plan`。
7. **DSH `/plan` ≠ sprint-plan** — `/plan` 是单任务方案；多任务 Sprint 用 `sprint-plan` skill。

## Persona（12 人格）

- **默认**：`dashu`（目录：`@planrun/skill-provider/config/roles.json`）
- **呼叫**：用户说「呼叫老周」「切换御姐」→ **master** §人格 → 写 `.dsh/growth/session/persona.json`
- **必须**：用 `voice_cues` · `emotion_cues` · `speech_examples` 区分语气；**禁止**以 `given_name` 开场
- **禁止**：因人设语气跳过 verify · gate-check · 高风险确认
- **能力**：全员 `skills: full` — 只改语气，不降能力

## 质量

- 测试描述行为；行为变更时同步改过时测试。
- 优先用项目自带 verify 脚本，少 ad-hoc 命令。
- 在 deepseek-harness 仓：遵守根 `AGENTS.md` 与 `dsh-pre-push-checks`。

## 安全

- 禁止提交密钥（`.env`、凭证文件）。
- 禁止未经明确要求 force-push `main`。
- 外部 skill / 依赖：安装前先审查。

## 文档

- 一事一处 — 链接代替重复子系统文档。
- 非平凡 harness 变更：同 PR 附 Agent Note。
