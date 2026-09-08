---
layout: home

hero:
  name: PlanRun
  text: Plan once · Run with gates · Ship with receipts.
  tagline: Super Cursor workflow SOP for DeepSeek Harness — 28 skills · 12 personas · one bundle
  image:
    src: /planrun/logo.svg
    alt: PlanRun
  actions:
    - theme: brand
      text: Install
      link: install
    - theme: alt
      text: Quickstart
      link: quickstart
    - theme: alt
      text: GitHub
      link: https://github.com/wangqiqi/planrun

features:
  - icon: 🧭
    title: 28 bundled skills
    details: master · sprint-plan · run · review · release · delivery · debug · test · security · mcp … mounted via Cordis plugin on your DSH profile.
  - icon: 🎭
    title: 12 personas
    details: config/roles.json defines voice and tone; run-start hook injects Persona hints without breaking verify discipline.
  - icon: 📦
    title: "@planrun/bundle"
    details: dsh plugin add @planrun/bundle — one command for skill-provider + workflow hooks (same pattern as turtle-ui).
  - icon: 🌱
    title: ".dsh/growth/"
    details: plan · learn · archive mirror Super Cursor's .cursorGrowth/ — project-local, usually gitignored, auditable.
  - icon: 🚧
    title: Workflow guard
    details: gate-check · plan-check · task-verify · next-task — no coding before PLAN_APPROVED; no ✅ without verify.
  - icon: 🔄
    title: Super Cursor mapping
    details: sprint-plan ↔ plan · ask_user_question ↔ AskQuestion · full table in mapping docs.
---

## Daily mantra

**One sprint-plan approval · one run loop · interrupt only on decisions · ✅ only after verify**

`master` → `sprint-plan` → `run` → `release` · `delivery`

## Who should use PlanRun

| Scenario | Recommendation |
|----------|----------------|
| ✅ DeepSeek Harness user wanting plan → run → verify discipline | Install `@planrun/bundle` |
| ✅ Need bundled skills + personas without copying `.cursor/` | Cordis plugin + growth templates |
| ⚠️ Cursor only, no DSH | Super Cursor mother `.cursor/` install |
| ❌ Standalone desktop app or zero Node | Out of scope — host is DSH + Node |
