#!/usr/bin/env bash
set -euo pipefail

# Run the smoke workflow against the built image using act.
#
# Requires:
#   - nektos/act on PATH
#   - the image built (scripts/build.sh) or IMAGE pre-pulled
#
# Env knobs:
#   IMAGE     image ref to test (default: kiln:dev)
#   ACT_ARGS  extra args passed to act

IMAGE="${IMAGE:-kiln:dev}"

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v act >/dev/null 2>&1; then
  echo "error: act not on PATH — install nektos/act first" >&2
  exit 127
fi

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "error: image $IMAGE not present locally — run scripts/build.sh first" >&2
  exit 1
fi

cd "$repo_root"

# shellcheck disable=SC2086
exec act \
  --pull=false \
  --workflows .github/workflows/smoke.yml \
  -P "ubuntu-latest=$IMAGE" \
  -P "ubuntu-24.04=$IMAGE" \
  -P "ubuntu-22.04=$IMAGE" \
  --container-architecture linux/amd64 \
  ${ACT_ARGS:-}
