#!/usr/bin/env bash
set -euo pipefail

#================= COLORS =================
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

#================= FORMATTING =============
TAG="[$(basename "${BASH_SOURCE[0]}")]"
LINE_BRK=$'\n\n'
SEGMENT="===========================================================\n"

#================= LOGGER FUNCS ===========
log_start() {
    local section="$1"
    printf "${CYAN}${SEGMENT}${SEGMENT}${SEGMENT}"
    printf " Begin: [$section] ${TAG}${LINE_BRK}"
    printf "${SEGMENT}${RESET}"
}

log_end() {
    local section="$1"
    printf "${YELLOW}${SEGMENT}"
    printf "             Finish [$section]${LINE_BRK}"
    printf "${SEGMENT}${SEGMENT}${SEGMENT}${RESET}"
}

normal_log() {
    local message="$1"
    local color="$RESET"

    if [ $# -ge 2 ]; then
        color="$2"
    fi

    if [ $# -ge 3 ]; then
        repeat="$3"
    fi

    # Repeat SEGMENT lines to frame the message visually

    for ((i = 0; i < repeat; i++)); do
        echo -e "${color}${SEGMENT}${RESET}"
    done

    echo -e "${color}   $message${LINE_BRK}${RESET}"

    for ((i = 0; i < repeat; i++)); do
        echo -e "${color}${SEGMENT}${RESET}"
    done
}
#==========================================


#──────────────────────────────────────────
log_start "DETECT ROOT PRIVILEGES"

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo -e "${RED}[!] Not running as root and 'sudo' is not available. Re-run as root or install sudo.${RESET}"
    exit 1
  fi
fi

log_end "DETECT ROOT PRIVILEGES"


#──────────────────────────────────────────
log_start "DETECT PACKAGE MANAGER"

PKG_MANAGER=""
if command -v apt-get >/dev/null 2>&1; then
  PKG_MANAGER="apt"
  echo "[pkg] Detected APT-based system (Ubuntu/Debian)"
elif command -v yum >/dev/null 2>&1; then
  PKG_MANAGER="yum"
  echo "[pkg] Detected YUM-based system (manylinux/CentOS-like)"
else
  echo -e "${RED}[x] Unsupported system: neither apt-get nor yum found.${RESET}" >&2
  exit 1
fi

log_end "DETECT PACKAGE MANAGER"


#──────────────────────────────────────────
log_start "SETUP DIRECTORIES"

PROJ_DIR=$(pwd)
FAISS_DIR="${PROJ_DIR}/libs/faiss"
mkdir -p "$FAISS_DIR"
echo "[INFO] Created: $FAISS_DIR"

log_end "SETUP DIRECTORIES"


#──────────────────────────────────────────
log_start "INSTALL DEPENDENCIES"

if [[ "$PKG_MANAGER" == "apt" ]]; then
  $SUDO apt-get update -y
  $SUDO apt-get install -y \
    cmake g++ libopenblas-dev libgflags-dev \
    python3-dev build-essential git

else
  echo "[INFO] Checking if EPEL is installed..."
  if ! rpm -q epel-release >/dev/null 2>&1; then
    echo "[INFO] Installing EPEL repository..."
    $SUDO yum install -y epel-release
  fi

  $SUDO yum update -y
  $SUDO yum groupinstall -y "Development Tools"
  $SUDO yum install -y \
    cmake3 gcc-c++ openblas-devel python3-devel git gflags-devel
fi

if ! command -v cmake >/dev/null && command -v cmake3 >/dev/null; then
  echo "[INFO] Linking cmake3 to cmake..."
  $SUDO ln -sf /usr/bin/cmake3 /usr/bin/cmake
fi

log_end "INSTALL DEPENDENCIES"


#──────────────────────────────────────────
log_start "BUILD FAISS (CPU ONLY)"

cd "$FAISS_DIR"

cmake -B build \
  -DFAISS_ENABLE_GPU=OFF \
  -DFAISS_ENABLE_PYTHON=OFF \
  -DFAISS_ENABLE_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build --parallel 3
cd "$PROJ_DIR"

log_end "BUILD FAISS (CPU ONLY)"


#──────────────────────────────────────────
log_start "VERIFY BUILD"

FOUND_LIB=$(find "$FAISS_DIR/build/faiss" -name "libfaiss.*" | head -n 1)

if [ -f "$FOUND_LIB" ]; then
  echo "[OK] Header files at: ${FAISS_DIR}/faiss/"
  echo "[OK] Library file at:  ${FOUND_LIB}"
else
  echo -e "${RED}[WARN] libfaiss not found in expected build directory.${RESET}"
fi

log_end "VERIFY BUILD"


#──────────────────────────────────────────

log_end "FAISS INSTALLATION"
#──────────────────────────────────────────


echo -e "$CYAN"
echo "LINKING INSTRUCTIONS"
echo ""
echo "You can now link FAISS in your C++ project using:"
echo ""
echo '  include_directories(${CMAKE_SOURCE_DIR}/libs/faiss/faiss) '
echo '  link_directories(${CMAKE_SOURCE_DIR}/libs/faiss/build/faiss)'
echo '  target_link_libraries(your_target PRIVATE faiss)'
echo -e "$RESET"