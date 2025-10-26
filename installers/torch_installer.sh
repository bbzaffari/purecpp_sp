#!/usr/bin/env bash
set -euo pipefail

#================= COLORS =================
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

#================= FORMATTING =============
TAG="[$(basename "${BASH_SOURCE[0]}")]"
LINE_BRK=$'\n\n'
SEGMENT="===========================================================\n"

#================= LOGGER FUNCS ===========
log_start() {
    local section="$1"
    printf "${CYAN}${SEGMENT}${SEGMENT}${SEGMENT}"
    printf "      Begin [$section] ${TAG}${LINE_BRK}"
    printf "${SEGMENT}${RESET}"
}

log_end() {
    local section="$1"
    printf "${YELLOW}${SEGMENT}"
    printf "             Finish [$section]${LINE_BRK}"
    printf "${SEGMENT}${SEGMENT}${SEGMENT}${RESET}"
}
#==========================================


#──────────────────────────────────────────
log_start "LIBTORCH DOWNLOAD"

ZIP="libtorch-cxx11-abi-shared-with-deps-2.5.0+cpu.zip"
URL="https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-2.5.0%2Bcpu.zip"

echo "[INFO] Cleaning previous files..."
rm -rf "$ZIP" ./libs/libtorch/cpu

echo "[INFO] Downloading LibTorch from: $URL"
wget "$URL" -O "$ZIP"

echo "[INFO] Extracting $ZIP..."
mkdir -p ./libs/libtorch
unzip "$ZIP" -d ./libs/libtorch

echo "[INFO] Moving contents to ./libs/libtorch/cpu"
mv ./libs/libtorch/libtorch ./libs/libtorch/cpu

echo "[INFO] Cleaning up .zip file..."
rm -f "$ZIP"

log_end "LIBTORCH DOWNLOAD"
