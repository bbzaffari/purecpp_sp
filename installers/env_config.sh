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
    printf "    Begin: [$section] ${TAG}${LINE_BRK}"
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
log_start "ENV SETUP SCRIPT"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "$GREEN[INFO] Resolved SCRIPT_DIR: $SCRIPT_DIR$RESET"

log_start "PIP"
pip install build conan cmake requests pybind11


"$SCRIPT_DIR/setting_conan_profile.sh"

"$SCRIPT_DIR/torch_installer.sh"

"$SCRIPT_DIR/faiss_installer.sh"
#-----------------------------------------


#──────────────────────────────────────────
log_end "ENV SETUP SCRIPT"
printf "\n$CYAN\n$SEGMENT$SEGMENT$SEGMENT\n $RESET"
#-----------------------------------------
