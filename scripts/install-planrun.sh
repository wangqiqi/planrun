#!/usr/bin/env bash
# install-planrun.sh — seed .dsh/growth/ and print profile instructions
set -euo pipefail

usage() {
  cat <<EOF
用法: $0 [目标项目路径] [选项]

环境变量:
  PLANRUN_HOME    planrun 仓库根（含 templates/growth）

选项:
  --here            安装到当前 Git 项目根
  --copy-plan       复制 plan.md 模板（若不存在）
  --no-guard        不复制 scripts/dsh-guard.sh 到目标项目
  --preset          复制 presets/planrun 到 ~/.dsh/.agent-presets/planrun
  -h, --help        显示帮助

示例:
  export PLANRUN_HOME=/path/to/planrun
  $0 --here --copy-plan
EOF
}

resolve_source_root() {
  local candidate
  for candidate in "${PLANRUN_HOME:-}"; do
    if [[ -n "$candidate" && -d "$candidate/templates/growth" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  if [[ -d "$script_dir/templates/growth" ]]; then
    echo "$script_dir"
    return 0
  fi
  echo "错误: 未找到 templates/growth；设置 PLANRUN_HOME" >&2
  exit 1
}

find_git_root() {
  local dir="$1"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.git" ]]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  echo "$1"
}

COPY_PLAN=false
INSTALL_PRESET=false
INSTALL_GUARD=true
TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --here) TARGET="$(pwd)"; shift ;;
    --copy-plan) COPY_PLAN=true; shift ;;
    --no-guard) INSTALL_GUARD=false; shift ;;
    --preset) INSTALL_PRESET=true; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "未知选项: $1" >&2; exit 1 ;;
    *) TARGET="$1"; shift ;;
  esac
done

SOURCE="$(resolve_source_root)"
if [[ -z "$TARGET" ]]; then
  TARGET="$(find_git_root "$(pwd)")"
fi
TARGET="$(find_git_root "$(cd "$TARGET" && pwd)")"

GROWTH="$TARGET/.dsh/growth"
mkdir -p "$GROWTH/learn" "$GROWTH/archive"

if [[ ! -f "$GROWTH/plan.md" ]] || [[ "$COPY_PLAN" == true ]]; then
  if [[ ! -f "$GROWTH/plan.md" ]]; then
    cp "$SOURCE/templates/growth/plan.md" "$GROWTH/plan.md"
    echo "已写入 $GROWTH/plan.md"
  fi
fi

if [[ ! -f "$GROWTH/learn/README.md" ]]; then
  cp "$SOURCE/templates/growth/learn/README.md" "$GROWTH/learn/README.md"
fi
if [[ ! -f "$GROWTH/archive/README.md" ]]; then
  cp "$SOURCE/templates/growth/archive/README.md" "$GROWTH/archive/README.md"
fi

SESSION="$GROWTH/session"
mkdir -p "$SESSION"
if [[ ! -f "$SESSION/persona.json" ]]; then
  cp "$SOURCE/templates/growth/session/persona.json" "$SESSION/persona.json"
  echo "已写入 $SESSION/persona.json"
fi
if [[ ! -f "$SESSION/aliases.json" ]]; then
  cp "$SOURCE/templates/growth/session/aliases.json" "$SESSION/aliases.json"
fi

if [[ "$INSTALL_GUARD" == true ]]; then
  TARGET_SCRIPTS="$TARGET/scripts"
  mkdir -p "$TARGET_SCRIPTS"
  for f in dsh-guard.sh plan-parse.sh; do
    src="$SOURCE/templates/growth/scripts/$f"
    dest="$TARGET_SCRIPTS/$f"
    if [[ ! -f "$dest" ]]; then
      cp "$src" "$dest"
      chmod +x "$dest"
      echo "已写入 $dest"
    else
      echo "SKIP: $dest 已存在（未覆盖）"
    fi
  done
  node "$SOURCE/scripts/merge-guard-package-json.mjs" "$TARGET" || true
fi

if [[ "$INSTALL_PRESET" == true ]]; then
  PRESET_DEST="${DSH_HOME:-$HOME/.dsh}/.agent-presets/planrun"
  mkdir -p "$(dirname "$PRESET_DEST")"
  rm -rf "$PRESET_DEST"
  cp -a "$SOURCE/presets/planrun" "$PRESET_DEST"
  echo "已复制 preset → $PRESET_DEST"
fi

cat <<EOF

PlanRun 项目模板已安装到: $GROWTH

下一步:
  1. 将 bundle 加入 DSH profile:
     dsh plugin --profile web add @planrun/bundle
     # 开发: dsh plugin --profile web add "file:$SOURCE/packages/bundle-planrun"
  2. 启动 dsh web，使用 standard preset
  3. 加载 skill: master · sprint-plan · run · review
  4. 呼叫人格: 「呼叫老周」「切换御姐」→ master §人格·呼叫；默认 dashu
  5. Sprint 闸门（项目 scripts/ 已种子 guard 时）:
     pnpm run gate-check    # PLAN_APPROVED + ACTIVE
     pnpm run plan-check    # handoff 结构
     pnpm run task-verify   # 当前 ACTIVE 验收
     pnpm run next-task     # 下一待办 ID

文档: $SOURCE/docs/quickstart.zh.md · $SOURCE/docs/workflow-guard.md

EOF
