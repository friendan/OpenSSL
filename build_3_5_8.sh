#!/usr/bin/env bash
# OpenSSL 3_5_8 — Linux x86_64
# Usage:
#   ./build_3_5_8.sh
#   ./build_3_5_8.sh 1|2|3|4
#   ./build_3_5_8.sh init debug|release
#   ./build_3_5_8.sh build debug|release
# 1/2 = Configure + full build_libs; 3/4 = incremental
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

VER="3_5_8"
SRC_DIR="openssl-src/openssl-3.5.8"
COMMON="$ROOT/build_common.sh"

run_common() {
  bash "$COMMON" "$VER" "$SRC_DIR" "$1" "$2"
}

dispatch() {
  local a1="${1:-}" a2="${2:-}"
  case "$a1" in
    1) run_common debug init ;;
    2) run_common release init ;;
    3) run_common debug build ;;
    4) run_common release build ;;
    init)
      case "$a2" in
        debug) run_common debug init ;;
        release) run_common release init ;;
        *) echo "[ERROR] use: init debug|release"; exit 1 ;;
      esac
      ;;
    build)
      case "$a2" in
        debug) run_common debug build ;;
        release) run_common release build ;;
        *) echo "[ERROR] use: build debug|release"; exit 1 ;;
      esac
      ;;
    debug)
      case "$a2" in
        init) run_common debug init ;;
        build) run_common debug build ;;
        *) echo "[ERROR] use: debug init|build"; exit 1 ;;
      esac
      ;;
    release)
      case "$a2" in
        init) run_common release init ;;
        build) run_common release build ;;
        *) echo "[ERROR] use: release init|build"; exit 1 ;;
      esac
      ;;
    *)
      echo "[ERROR] bad args: $*"
      echo "Usage:"
      echo "  $0"
      echo "  $0 1|2|3|4"
      echo "  $0 init debug|release"
      echo "  $0 build debug|release"
      echo "1/2=Configure+全量编库  3/4=增量编库"
      exit 1
      ;;
  esac
}

menu() {
  while true; do
    clear 2>/dev/null || true
    echo "========================================"
    echo "  OpenSSL $VER (linux-x86_64)"
    echo "========================================"
    echo "  1 - 初始化 Debug   (Configure + 全量编库)"
    echo "  2 - 初始化 Release (Configure + 全量编库)"
    echo "  3 - 增量编译 Debug (需先做过 1)"
    echo "  4 - 增量编译 Release (需先做过 2)"
    echo "  0 - 退出"
    echo "========================================"
    echo "也可: $0 2  或  $0 init release"
    echo "========================================"
    read -r -p "请选择: " CHOICE
    case "$CHOICE" in
      1) run_common debug init || echo "[FAILED]"; read -r -p "按回车继续..." _ ;;
      2) run_common release init || echo "[FAILED]"; read -r -p "按回车继续..." _ ;;
      3) run_common debug build || echo "[FAILED]"; read -r -p "按回车继续..." _ ;;
      4) run_common release build || echo "[FAILED]"; read -r -p "按回车继续..." _ ;;
      0) exit 0 ;;
      *) echo "无效输入"; read -r -p "按回车继续..." _ ;;
    esac
  done
}

if [[ $# -eq 0 ]]; then
  menu
else
  dispatch "$@"
fi
