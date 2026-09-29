#!/usr/bin/env bash
# Usage: build_common.sh VER SRC_DIR debug|release init|build
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

VER="${1:-}"
SRC_DIR="${2:-}"
CONFIG="${3:-}"
ACTION="${4:-}"

usage() {
  echo "Usage: build_common.sh VER SRC_DIR debug|release init|build"
  exit 1
}

[[ -n "$VER" && -n "$SRC_DIR" ]] || usage
[[ "$CONFIG" == "debug" || "$CONFIG" == "release" ]] || usage
[[ "$ACTION" == "init" || "$ACTION" == "build" ]] || usage
[[ -f "$SRC_DIR/Configure" ]] || { echo "[ERROR] Configure not found: $SRC_DIR/Configure"; exit 1; }

# shellcheck source=init_tools.sh
source "$ROOT/init_tools.sh"

BUILD_DIR="build_linux_${CONFIG}_${VER}"
BIN_DIR="bin/${VER}/linux-x86_64"

if [[ "$CONFIG" == "debug" ]]; then
  TARGET="debug-linux-x86_64"
  LIB_SUFFIX="_debug"
else
  TARGET="linux-x86_64"
  LIB_SUFFIX=""
fi

JOBS="$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"

collect() {
  local crypto="$BUILD_DIR/libcrypto.a"
  local ssl="$BUILD_DIR/libssl.a"
  [[ -f "$crypto" ]] || { echo "[ERROR] missing $crypto"; exit 1; }
  [[ -f "$ssl" ]] || { echo "[ERROR] missing $ssl"; exit 1; }

  mkdir -p "$BIN_DIR"
  cp -f "$crypto" "$BIN_DIR/libcrypto${LIB_SUFFIX}.a"
  cp -f "$ssl" "$BIN_DIR/libssl${LIB_SUFFIX}.a"

  rm -rf "$BIN_DIR/include"
  mkdir -p "$BIN_DIR/include"
  cp -a "$SRC_DIR/include/." "$BIN_DIR/include/"
  if [[ -d "$BUILD_DIR/include" ]]; then
    cp -a "$BUILD_DIR/include/." "$BIN_DIR/include/"
  fi

  echo "Collected libs: libcrypto${LIB_SUFFIX}.a libssl${LIB_SUFFIX}.a"
  echo "Collected headers: $BIN_DIR/include/"
}

do_init() {
  echo "==== INIT linux $VER $CONFIG ===="
  rm -rf "$BUILD_DIR"
  mkdir -p "$BUILD_DIR"
  pushd "$BUILD_DIR" >/dev/null
  echo "Configure: perl ../$SRC_DIR/Configure $TARGET no-shared no-makedepend"
  perl "../$SRC_DIR/Configure" "$TARGET" no-shared no-makedepend
  echo "make -j$JOBS build_libs ..."
  make -j"$JOBS" build_libs
  popd >/dev/null
  collect
  echo "==== INIT DONE: $BIN_DIR ===="
}

do_build() {
  echo "==== BUILD linux $VER $CONFIG ===="
  if [[ ! -f "$BUILD_DIR/Makefile" && ! -f "$BUILD_DIR/makefile" ]]; then
    echo "[ERROR] $BUILD_DIR not configured. Run init (menu 1/2) first."
    exit 1
  fi
  pushd "$BUILD_DIR" >/dev/null
  make -j"$JOBS" build_libs
  popd >/dev/null
  collect
  echo "==== BUILD DONE: $BIN_DIR ===="
}

case "$ACTION" in
  init) do_init ;;
  build) do_build ;;
esac
