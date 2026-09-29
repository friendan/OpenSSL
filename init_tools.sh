#!/usr/bin/env bash
# Check Linux build tools (system packages). x86_64 only.
set -euo pipefail

arch="$(uname -m)"
if [[ "$arch" != "x86_64" ]]; then
  echo "[ERROR] only x86_64 is supported (got: $arch)"
  exit 1
fi

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] missing tool: $1"
    echo "  Debian/Ubuntu: sudo apt-get install -y build-essential perl nasm"
    echo "  RHEL/CentOS:   sudo yum install -y gcc make perl nasm"
    exit 1
  fi
}

need perl
need make
if ! command -v gcc >/dev/null 2>&1 && ! command -v clang >/dev/null 2>&1; then
  echo "[ERROR] need gcc or clang"
  exit 1
fi
need nasm

echo "[OK] tools: perl=$(command -v perl) make=$(command -v make) nasm=$(command -v nasm)"
