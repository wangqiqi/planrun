#!/usr/bin/env bash
# publish-packages.sh — publish @planrun/* to npm in dependency order (maintainer)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DRY_RUN=false
PACK_ONLY=false

usage() {
  cat <<EOF
用法: $0 [--dry-run] [--pack-only]

  --dry-run     仅 pnpm pack，不上传 npm
  --pack-only   同 --dry-run（生成 .tgz 供本地验证）

顺序: @planrun/skill-provider → @planrun/workflow → @planrun/bundle

前置: npm login · @planrun scope 权限 · pnpm run build
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|--pack-only) DRY_RUN=true; PACK_ONLY=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知选项: $1" >&2; exit 1 ;;
  esac
done

echo "==> Building workspace"
pnpm run build

publish_one() {
  local pkg_dir="$1"
  local name
  name="$(node -p "require('./$pkg_dir/package.json').name")"
  echo "==> $name ($pkg_dir)"
  if [[ "$DRY_RUN" == true ]]; then
    (cd "$pkg_dir" && npm pack --dry-run 2>&1 | tail -5)
    (cd "$pkg_dir" && npm pack)
    return 0
  fi
  pnpm publish "$pkg_dir" --access public --no-git-checks
}

publish_one packages/skill-provider
publish_one packages/workflow
publish_one packages/bundle-planrun

echo "OK: publish-packages complete"
