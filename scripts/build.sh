#!/usr/bin/env bash
set -euo pipefail

# Build the kiln image.
#
# Default build mode is `direct` — FROM ${WOLFI_BASE}, apk install on top.
# This requires the registry hosting WOLFI_BASE to be reachable. The default
# WOLFI_BASE (cgr.dev/chainguard/wolfi-base:latest) is publicly pullable. If
# your environment blocks cgr.dev/chainguard images (allowlist/air-gap),
# override BUILD_MODE=bootstrap to use the alpine-driven apk bootstrap fallback.
#
# Env knobs:
#   IMAGE            image ref to tag (default: kiln:dev)
#   BUILD_MODE       direct | bootstrap (default: direct)
#   WOLFI_BASE       base image for direct mode
#                    (default: cgr.dev/chainguard/wolfi-base:latest)
#   BOOTSTRAP_IMAGE  image driving the bootstrap stage
#                    (default: docker.io/library/alpine:3.21)
#   NODE_MAJOR       node major version (default: 22)
#   PYTHON_MINOR     python minor series (default: 3.13)
#   WOLFI_REPO       wolfi apk repository URL (default: https://packages.wolfi.dev/os)
#   WOLFI_KEY_URL    wolfi signing key URL (default: matches WOLFI_REPO)
#   PLATFORM         docker buildx --platform value (default: linux/amd64)
#   PUSH             set to 1 to docker push after build

IMAGE="${IMAGE:-kiln:dev}"
BUILD_MODE="${BUILD_MODE:-direct}"
WOLFI_BASE="${WOLFI_BASE:-cgr.dev/chainguard/wolfi-base:latest}"
BOOTSTRAP_IMAGE="${BOOTSTRAP_IMAGE:-docker.io/library/alpine:3.21}"
NODE_MAJOR="${NODE_MAJOR:-22}"
PYTHON_MINOR="${PYTHON_MINOR:-3.13}"
WOLFI_REPO="${WOLFI_REPO:-https://packages.wolfi.dev/os}"
WOLFI_KEY_URL="${WOLFI_KEY_URL:-https://packages.wolfi.dev/os/wolfi-signing.rsa.pub}"
PLATFORM="${PLATFORM:-linux/amd64}"

case "$BUILD_MODE" in
  direct|bootstrap) ;;
  *)
    echo "error: BUILD_MODE must be 'direct' or 'bootstrap' (got: $BUILD_MODE)" >&2
    exit 2
    ;;
esac

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

build_args=(
  --build-arg "BUILD_MODE=$BUILD_MODE"
  --build-arg "WOLFI_BASE=$WOLFI_BASE"
  --build-arg "BOOTSTRAP_IMAGE=$BOOTSTRAP_IMAGE"
  --build-arg "NODE_MAJOR=$NODE_MAJOR"
  --build-arg "PYTHON_MINOR=$PYTHON_MINOR"
  --build-arg "WOLFI_REPO=$WOLFI_REPO"
  --build-arg "WOLFI_KEY_URL=$WOLFI_KEY_URL"
)

output_args=(--load)
if [[ "${PUSH:-0}" == "1" ]]; then
  output_args=(--push)
fi

if [[ "$BUILD_MODE" == "direct" ]]; then
  echo "building $IMAGE in DIRECT mode (FROM $WOLFI_BASE)"
else
  echo "building $IMAGE in BOOTSTRAP mode (FROM scratch, rootfs built via $BOOTSTRAP_IMAGE)"
fi
echo "  node=$NODE_MAJOR python=$PYTHON_MINOR platform=$PLATFORM"

docker buildx build \
  --platform "$PLATFORM" \
  "${build_args[@]}" \
  --tag "$IMAGE" \
  "${output_args[@]}" \
  "$repo_root"
