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
    printf "      Begin: [$section] ${TAG}${LINE_BRK}"
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

echo -e "$GREEN[INFO] Running: conan profile detect --force$RESET"
conan profile detect --force

log_end "CONAN DETECT"


#──────────────────────────────────────────
log_start "LOCATE PROFILE DIR"

PROFILE_DIR=$(find . -type d -wholename "*/.conan2/profiles" | head -n 1 || true)
if [ -z "$PROFILE_DIR" ]; then
    PROFILE_DIR="$HOME/.conan2/profiles"
    echo -e "$GREEN[INFO] Defaulting to: $PROFILE_DIR$RESET"
    mkdir -p "$PROFILE_DIR"
else
    echo -e "$GREEN[INFO] Found profile dir at: $PROFILE_DIR$RESET"
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

echo -e "$GREEN[INFO] Profile written to: $DEFAULT_PROFILE$RESET"

log_end "WRITE PROFILE"


#──────────────────────────────────────────
log_start "VERIFY PROFILE"

echo -e "$GREEN[INFO] Displaying contents of: $DEFAULT_PROFILE"
echo -e "$CYAN"
cat "$DEFAULT_PROFILE"
echo -e "$RESET"

log_end "VERIFY PROFILE"
