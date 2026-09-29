#!/usr/bin/env bash
# pack-local.sh — stage @planrun/* for a local `dsh plugin add`.
#
# Why this exists: the workspace members depend on each other through the
# `workspace:^` protocol, which only `pnpm publish` rewrites into semver. A raw
# `dsh plugin add "file:$PLANRUN_HOME/packages/bundle-planrun"` therefore fails:
#
#   ERR_PNPM_WORKSPACE_PKG_NOT_FOUND: "@planrun/skill-provider@workspace:^" ...
#
# This script copies the built packages into one directory, rewrites the
# bundle's dependencies to `file:../skill-provider` / `file:../workflow`, and
# strips install-time build hooks so pnpm can resolve everything offline.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${PLANRUN_PACK_OUT:-$ROOT/dist-local}"
SKIP_BUILD=false

usage() {
  cat <<EOF
用法: $0 [--no-build]

  --no-build   跳过 pnpm run build（要求 lib/ 已构建）
  环境变量 PLANRUN_PACK_OUT  自定义输出目录（默认 $ROOT/dist-local）

产物:
  <out>/skill-provider/   @planrun/skill-provider
  <out>/workflow/         @planrun/workflow
  <out>/bundle-planrun/   @planrun/bundle

安装:
  dsh plugin --profile web add "file:<out>/bundle-planrun"
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-build) SKIP_BUILD=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知选项: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ "$SKIP_BUILD" != true ]]; then
  echo "==> pnpm run build"
  (cd "$ROOT" && pnpm run build)
fi

for pkg in skill-provider workflow bundle-planrun; do
  if [[ ! -f "$ROOT/packages/$pkg/lib/index.js" ]]; then
    echo "错误: packages/$pkg/lib/index.js 不存在 — 先运行 pnpm run build" >&2
    exit 1
  fi
done

echo "==> staging → $OUT"
rm -rf "$OUT"
mkdir -p "$OUT"

stage_lib() {
  local pkg="$1" dest="$2"
  mkdir -p "$dest/lib"
  cp "$ROOT/packages/$pkg"/lib/*.js "$dest/lib/"
  if [[ -d "$ROOT/packages/$pkg/lib/types" ]]; then
    cp -R "$ROOT/packages/$pkg/lib/types" "$dest/lib/types"
  fi
}

stage_lib skill-provider "$OUT/skill-provider"
cp "$ROOT/packages/skill-provider/package.json" "$OUT/skill-provider/"
for asset in skills agents config; do
  [[ -d "$ROOT/packages/skill-provider/$asset" ]] && cp -R "$ROOT/packages/skill-provider/$asset" "$OUT/skill-provider/"
done

stage_lib workflow "$OUT/workflow"
cp "$ROOT/packages/workflow/package.json" "$OUT/workflow/"

stage_lib bundle-planrun "$OUT/bundle-planrun"
cp "$ROOT/packages/bundle-planrun/package.json" "$OUT/bundle-planrun/"
cp "$ROOT/packages/bundle-planrun"/*.patch.yml "$OUT/bundle-planrun/"

# Rewrite cross-package deps and drop install-time build hooks: the staged
# packages ship prebuilt lib/, and their devDependencies (typescript) are absent.
node - "$OUT" <<'NODE'
const fs = require('node:fs')
const path = require('node:path')
const out = process.argv[2]

const bundlePath = path.join(out, 'bundle-planrun', 'package.json')
const bundle = JSON.parse(fs.readFileSync(bundlePath, 'utf8'))
bundle.dependencies['@planrun/skill-provider'] = 'file:../skill-provider'
bundle.dependencies['@planrun/workflow'] = 'file:../workflow'
fs.writeFileSync(bundlePath, `${JSON.stringify(bundle, null, 2)}\n`)

for (const pkg of ['skill-provider', 'workflow', 'bundle-planrun']) {
  const file = path.join(out, pkg, 'package.json')
  const manifest = JSON.parse(fs.readFileSync(file, 'utf8'))
  delete manifest.scripts?.prepare
  delete manifest.scripts?.prepublishOnly
  delete manifest.scripts?.build
  fs.writeFileSync(file, `${JSON.stringify(manifest, null, 2)}\n`)
}
NODE

for pkg in skill-provider workflow bundle-planrun; do
  if grep -q 'workspace:' "$OUT/$pkg/package.json"; then
    echo "错误: $pkg/package.json 仍含 workspace: 协议" >&2
    exit 1
  fi
done

echo "OK: 本地安装包已就绪 → $OUT"
echo "    dsh plugin --profile web add \"file:$OUT/bundle-planrun\""
