---
name: study
description: >-
  Learn new tech/languages — distinct from learn (this repo's conventions).
  Minimal examples and SPIKE-friendly conclusions.
disable-model-invocation: true
user-invocable: true
---

# study

**用这个**：学新技术/语言/框架（通用能力）。**不是那个**：写本仓模块地图/约定 → **`learn`** → `.dsh/growth/learn/`。

**study** = 学 Rust、Playwright、新框架等通用技能。  
**learn** = 本项目约定 → `.dsh/growth/learn/`（见 **learn** skill）。

Standing discipline: [docs/discipline.md](../../../docs/discipline.md)

## 流程

1. 明确学习目标与项目关联（SPIKE 可写 `SPIKE-*`）
2. 最小可运行示例（非空讲理论）
3. 对照官方文档；标注版本
4. 结论：是否引入项目 → 是则开 `TASK-*` via **`sprint-plan`**，否则 `.dsh/growth/archive/`

## 禁止

- 把项目路径/业务规则写进 bundled skills 或 harness SOP
- 与 **learn** 混用输出目录（`.dsh/growth/learn/`）
