#!/usr/bin/env bash
# resolve-persona.sh — resolve persona by id / role_name / nickname / given_name
# Usage:
#   resolve-persona.sh <query> [project_root]
#   resolve-persona.sh              # print active session persona
# Exit 0 + JSON persona on unique match; exit 2 on ambiguous; exit 1 on miss
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec node "$ROOT/scripts/resolve-persona.mjs" "$@"
