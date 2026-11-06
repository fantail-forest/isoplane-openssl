#!/usr/bin/env bash
# Build and install static WASI libraries: isoplane-build-wasi.sh BUILD_DIR PREFIX [JOBS]
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 BUILD_DIR PREFIX [JOBS] (requires WASI_SDK_PATH)" >&2
  exit 2
fi
: "${WASI_SDK_PATH:?Set WASI_SDK_PATH to the pinned WASI SDK}"
source_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$1" "$2"
build_directory="$(realpath "$1")"
prefix="$(realpath "$2")"
wasi_sdk="$(realpath "$WASI_SDK_PATH")"
jobs="${3:-2}"

cd "$build_directory"
CC="$wasi_sdk/bin/clang" AR="$wasi_sdk/bin/llvm-ar" RANLIB="$wasi_sdk/bin/llvm-ranlib" \
  perl "$source_directory/Configure" linux-generic32 no-shared no-threads no-asm no-dso no-module no-engine \
    no-sock no-async no-apps no-tests no-secure-memory no-ui-console \
    --with-rand-seed=getrandom --prefix="$prefix" --openssldir=/etc/ssl
make -j"$jobs" build_libs
make install_dev
