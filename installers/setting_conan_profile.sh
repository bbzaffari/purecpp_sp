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
    printf "              Begin [$section] ${TAG}${LINE_BRK}"
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
log_start "CONAN DETECT"

echo "[INFO] Running: conan profile detect --force"
conan profile detect --force

log_end "CONAN DETECT"


#──────────────────────────────────────────
log_start "LOCATE PROFILE DIR"

PROFILE_DIR=$(find . -type d -wholename "*/.conan2/profiles" | head -n 1 || true)
if [ -z "$PROFILE_DIR" ]; then
    PROFILE_DIR="$HOME/.conan2/profiles"
    echo "[INFO] Defaulting to: $PROFILE_DIR"
    mkdir -p "$PROFILE_DIR"
else
    echo "[INFO] Found profile dir at: $PROFILE_DIR"
fi

log_end "LOCATE PROFILE DIR"


#──────────────────────────────────────────
log_start "WRITE PROFILE"

DEFAULT_PROFILE="$PROFILE_DIR/default"

cat << EOF > "$DEFAULT_PROFILE"
[settings]
arch=x86_64
build_type=Release
compiler=gcc
compiler.cppstd=17
compiler.libcxx=libstdc++11
compiler.version=11
os=Linux
EOF

echo "[INFO] Profile written to: $DEFAULT_PROFILE"

log_end "WRITE PROFILE"


#──────────────────────────────────────────
log_start "VERIFY PROFILE"

echo "[INFO] Displaying contents of: $DEFAULT_PROFILE"
cat "$DEFAULT_PROFILE"

log_end "VERIFY PROFILE"
