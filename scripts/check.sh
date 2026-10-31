#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
hadolint Dockerfile
actionlint
shellcheck scripts/*.sh tests/act/*.sh
bun run check:docs
bun run check:loc
git diff --check
