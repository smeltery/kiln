#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for BUILD_MODE in direct bootstrap; do
  export BUILD_MODE IMAGE="kiln:verify-$BUILD_MODE"
  scripts/build.sh
  scripts/test.sh
done
