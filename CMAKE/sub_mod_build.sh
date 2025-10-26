#!/usr/bin/env bash

set -euo pipefail

MOD=$1

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
    local message="$1"
    printf "${CYAN}${SEGMENT}${SEGMENT}${SEGMENT}"
    printf "  $message ${LINE_BRK}"
    printf "${SEGMENT}${RESET}"
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

log_end() {
    local message="$1"
    printf "${YELLOW}${SEGMENT}"
    printf "   $message Finished ${LINE_BRK}"
    printf "${SEGMENT}${SEGMENT}${SEGMENT}${RESET}"
}
#==========================================

# ──────────────────────────────────────────────────────────────

log_start "$TAG Begin $MOD"

#-----------------------------------------

# ──────────────────────────────────────────────────────────────
# Smart core splitter for parallel builds
# ──────────────────────────────────────────────────────────────
cores=$(nproc)

if [ "$cores" -gt 1 ]; then
    half=$((cores / 2))
else
    half=1
fi
printf "$LINE_BRK" 
normal_log  "[INFO] Detected $cores cores, using $half for parallel build." "$GREEN" 1
printf "$LINE_BRK"

#-----------------------------------------

# ──────────────────────────────────────────────────────────────
# Conan
# ──────────────────────────────────────────────────────────────

log_start " $TAG[CONAN] Begin" 


rm -fr ./$MOD/build 
conan install . \
    --build=missing \
    -c tools.build:jobs="$half" \
    -of=$MOD


# rm -fr ./$MOD/conan.lock
# conan lock create . \
#     --build=missing \
#     -c tools.build:jobs="$half" \

log_end "  $TAG[CONAN]"
#-----------------------------------------


# ──────────────────────────────────────────────────────────────
# Build
# ──────────────────────────────────────────────────────────────
cd $MOD
log_start "$TAG COMPILING $MOD"

cmake -DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DBUILD_SHARED_LIBS=OFF \
    -D_GLIBCXX_USE_CXX11_ABI=1 \
    -DSPM_USE_BUILTIN_PROTOBUF=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=generators/conan_toolchain.cmake \
    -S "$(pwd)" \
    -B "$(pwd)/build/Release" \
    -G "Unix Makefiles"



cmake --build "$(pwd)/build/Release" --parallel "$half"

log_end "  $TAG COMPILING $MOD"
#-----------------------------------------

# ──────────────────────────────────────────────────────────────
# Sending to Sandbox
# ──────────────────────────────────────────────────────────────

normal_log "Sending to Sandbox \n" "$GREEN" 3

rm -f ../../Sandbox/purecpp_*.so
cp ./build/Release/purecpp_*.so ../../Sandbox/
normal_log "Step completed." "$GREEN" 0
#-----------------------------------------


log_end "     $TAG "
# ──────────────────────────────────────────────────────────────