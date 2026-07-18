#!/usr/bin/env bash
set -euo pipefail

# Local validation of every workflow under .github/workflows/.
#
# Two passes:
#   1. actionlint — static check (syntax, expression typing, action input
#      contracts, shellcheck on `run:` blocks). Required for ALL workflows.
#   2. act --list / --dryrun — only on workflows that don't reference an
#      external reusable. act can't resolve `uses: owner/repo/.github/...@ref`
#      because that repo isn't a local path, so dryrun would fail for the
#      wrong reason. Those workflows rely on actionlint alone.

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    red "missing: $1"
    return 1
  fi
}

missing=0
require actionlint || missing=1
require act        || missing=1
if [[ "$missing" -ne 0 ]]; then
  red "install missing tools first (brew install actionlint act, or equivalents)"
  exit 127
fi

yellow "==> actionlint (all workflows)"
actionlint -color

# Find workflows that DO reference an external reusable. We skip act dryrun
# for those because act can't resolve the remote ref.
external_reusable_pattern='uses:[[:space:]]+[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/\.github/workflows/'

mapfile -t all_workflows < <(find .github/workflows -maxdepth 1 -name '*.yml' -o -name '*.yaml' | sort)

for wf in "${all_workflows[@]}"; do
  name="${wf##*/}"
  if grep -Eq "$external_reusable_pattern" "$wf"; then
    yellow "==> skipping act dryrun (uses external reusable): $name"
    continue
  fi
  yellow "==> act --list: $name"
  act --workflows "$wf" --list || {
    red "act --list failed for $name"
    exit 1
  }
done

green "all workflow checks passed"
