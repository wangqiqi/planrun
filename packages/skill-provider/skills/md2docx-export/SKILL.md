---
name: md2docx-export
description: >-
  Markdown to DOCX (no slash): export Word via PyPI package mddocx.
  Trigger on md转docx, export Word, markdown to word.
disable-model-invocation: true
user-invocable: true
---

# md2docx-export · Markdown → DOCX

**工具技能**（非 sprint-plan/run 主路径）。**用这个**：`.md` / Markdown 文本 → `.docx`。**不是那个**：编辑已有 Word 样式/修订 → anthropics **docx** skill 或 Office MCP；上线走查 → **delivery**；写操作手册正文 → **user-manual**。

上游索引 → `docs/library-index.md` §mddocx。PlanRun **不**内置转换器；用户本机 `pip install` + 可选 MCP。

## 与 Office / docx skill 分流

| 用户意图 | 入口 |
|----------|------|
| Markdown / `.md` → Word | **本 skill** · `mddocx` CLI 或 **mddocx MCP** |
| 改已有 `.docx`（段落、样式、批注） | anthropics **docx** skill / 飞书等 MCP |
| 使用说明书配图与 walkthrough | **user-manual** → 导出 docx 可走本 skill |
| pptx / xlsx 深度编辑 | **master** `deps` · upstream / MCP |

## Setup

转换前先确认 `mddocx` 可用。

### Check installation

```bash
mddocx --version || python -m mddocx.cli --version
```

未安装：

```bash
pip install mddocx
```

复杂 HTML 块（Markdown 内嵌 `<table>` / `<div>` 等）可选：

```bash
pip install "mddocx[html]"
```

### MCP（推荐 · function call）

MCP server 在 **mddocx 包**内发布（`pip install "mddocx[mcp]"`）。配置示例 → `reference/mcp-config.example.json`（bundled 同路径）。

**Agent 调用顺序**：`GetDynamicTools`（namespace `mddocx`）→ 读 schema → `CallDynamicTool`。

| 能力 | 入口 |
|------|------|
| 结构化转换（单文件 / 文本 / 批量） | **mddocx MCP** |
| 兜底 / 无 MCP | **CLI**（下节） |

MCP 未配置时：告知用户安装 `mddocx[mcp]` 并注册 Cursor MCP；勿静默改用 WebUI。

## CLI（兜底）

单文件：

```bash
mddocx input.md output.docx
```

调试与指标：

```bash
mddocx --debug input.md output.docx
```

批量（目录）：

```bash
python -m mddocx.batch_convert --input-dir ./docs --output-dir ./docx
```

若上游未提供 `batch_convert` 模块，用 md2docx 仓库 `scripts/batch_convert.py` 或 MCP `batch_convert` tool。

### Agent 刚写的 Markdown

无 MCP 时：先写入工作区 `.md`，再 `mddocx` 转 docx。有 MCP 时优先 `convert_md_text_to_docx`（以 MCP schema 为准）。

## 网络与离线

| 特性 | 依赖 |
|------|------|
| Mermaid 图 | `mermaid.ink` |
| LaTeX 公式 | `latex.codecogs.com` |

离线或出域：图表/公式可能回退为源码 + 提示；在交付说明中注明。勿假设无网可用。

## Working directory

输出 `.docx` 放在用户项目目录或约定的 `dist/` / `docs/export/`。**不要**只用 `/tmp` 除非用户明确要求临时文件。

## 与 user-manual / delivery

| 场景 | 动作 |
|------|------|
| 手册 md 已定稿，要 Word 交付 | verify 绿后 `mddocx` 导出 |
| 仅配图 regen | **user-manual**；导出 docx 为可选最后一步 |
| 发版前文档走查 | **delivery**；docx 导出不替代走查 |

## 故障

| 症状 | 检查 |
|------|------|
| `command not found` | `pip install mddocx` · venv 是否激活 |
| 输入不存在 | 路径相对项目根；先 `Read` 确认 `.md` |
| 输出被占用 | CLI 会自动加时间戳后缀；或换输出路径 |
| MCP `needsAuth` / 连不上 | 检查 `mcp.json` command/args · `python -m mddocx.mcp` 能否单独启动 |
