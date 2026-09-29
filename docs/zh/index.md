---
layout: home

hero:
  name: PlanRun
  text: Plan once · Run with gates · Ship with receipts.
  tagline: Super Cursor 工作流 SOP，原生运行于 DeepSeek Harness — 28 skills · 12 personas · 一套 bundle
  image:
    src: /logo.svg
    alt: PlanRun
  actions:
    - theme: brand
      text: 安装指南
      link: /zh/install
    - theme: alt
      text: 快速开始
      link: /zh/quickstart
    - theme: alt
      text: GitHub
      link: https://github.com/wangqiqi/planrun

features:
  - icon: 🧭
    title: 28 bundled skills
    details: master · sprint-plan · run · review · release · delivery · debug · test · security · mcp … 通过 Cordis plugin 挂载到 DSH profile。
  - icon: 🎭
    title: 12 personas
    details: config/roles.json 定义语气与人设；run-start hook 注入 Persona hint，协作有辨识度又不自报姓名。
  - icon: 📦
    title: "@planrun/bundle"
    details: dsh plugin add @planrun/bundle 一键挂载 skill-provider + workflow hooks，与 turtle-ui 等同模式。
  - icon: 🌱
    title: ".dsh/growth/"
    details: plan · learn · archive 项目本地镜像 Super Cursor 的 .cursorGrowth/，通常 gitignore，可审计可沉淀。
  - icon: 🚧
    title: Workflow guard
    details: gate-check · plan-check · task-verify · next-task — Sprint 批准后才编码，验收绿才勾 ✅。
  - icon: 🔄
    title: Super Cursor 映射
    details: sprint-plan 对应 plan · ask_user_question 对应 AskQuestion · 完整对照见 mapping 文档。
---

## 日常口诀

**一次 sprint-plan 批准 · 一次 run 连跑 · 决策才停 · verify 才勾 ✅**

`master` → `sprint-plan` → `run` → `release` · `delivery`

## 谁适合用

| 场景 | 建议 |
|------|------|
| ✅ 使用 DeepSeek Harness，想要 plan → run → verify 纪律 | 安装 `@planrun/bundle` |
| ✅ 需要 bundled skills + personas，不想手抄 `.cursor/` | Cordis plugin + growth 模板 |
| ⚠️ 只用 Cursor、不用 DSH | 用 Super Cursor 母版 `.cursor/` 安装 |
| ❌ 需要独立桌面应用或零 Node | 超出范围 — 宿主为 DSH + Node |
