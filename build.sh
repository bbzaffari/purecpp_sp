#!/bin/bash

# -------------------- Function to print a formatted module header --------------------
print_module() {
    local module="$1"
    local title="MODULE ${module}"
    local total_len=$(( ${#title} + 4 ))
    local separator=$(printf "%*s" "$total_len" | tr ' ' '-')

    echo ""
    echo "$separator"
    printf "| %-*s |\n" $((total_len - 4)) "$title"
    echo "$separator"
}

# -------------------- Function to compile a specific module --------------------
run_module() {
    local dir="$1"
    cd CMAKE/
    print_module "$dir"
    ./sub_mod_build.sh "$dir"
    cd - > /dev/null
}

# -------------------- Ordered list of modules --------------------
modules=("CMAKE_LIBS" "CMAKE_META" "CMAKE_EMBED" "CMAKE_EXTRACT" "CMAKE_CHUNKS_CLEAN")

# -------------------- Main logic --------------------
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 [all | 1-5]"
    echo "-----------------------------------"
    echo "  1 => ${modules[0]}"
    echo "  2 => ${modules[1]}"
    echo "  3 => ${modules[2]}"
    echo "  4 => ${modules[3]}"
    echo "  5 => ${modules[4]}"
    echo " all => run all modules"
    echo "-----------------------------------"
    exit 1
fi

if [ "$1" = "all" ]; then
    START_TIME=$(date +%s)

    for i in "${!modules[@]}"; do
        run_module "${modules[$i]}"
    done

    END_TIME=$(date +%s)
    ELAPSED_TIME=$((END_TIME - START_TIME))

    echo ""
    echo "============================================================"
    echo "Total execution time: ${ELAPSED_TIME} seconds"
    echo "============================================================"
    echo "       ALL MODULES COMPILED SUCCESSFULLY!"
    echo "============================================================"
else
    case "$1" in
        [1-5])
            run_module "${modules[$(( $1 - 1 ))]}"
            ;;
        *)
            echo "Invalid argument: '$1'"
            echo "Please use a number between 1 and 5, or 'all'"
            ;;
    esac
fi









# #!/usr/bin/env bash
# set -euo pipefail
# cd src/

# #================= COLORS =================
# GREEN='\033[0;32m'
# CYAN='\033[0;36m'
# YELLOW='\033[1;33m'
# RESET='\033[0m'

# #================= FORMATTING =============
# LINE_BRK=$'\n\n'
# SEGMENT="===========================================================\n"
# TAG="[$(basename "${BASH_SOURCE[0]}")]"

# #================= LOGGER FUNCS ===========
# log_start() {
#     local section="$1"
#     printf "${CYAN}${SEGMENT}${SEGMENT}${SEGMENT}"
#     printf "              Begin [$section] ${TAG}${LINE_BRK}"
#     printf "${SEGMENT}${RESET}"
# }

# log_end() {
#     local section="$1"
#     printf "${YELLOW}${SEGMENT}"
#     printf "             Finish [$section]${LINE_BRK}"
#     printf "${SEGMENT}${SEGMENT}${SEGMENT}${RESET}"
# }
# #==========================================


# #──────────────────────────────────────────
# log_start "CORE SPLITTER"

# cores=$(nproc)
# half=$(( cores > 1 ? cores / 2 : 1 ))

# printf "$LINE_BRK"
# echo "[INFO] Detected $cores cores, using $half for parallel build."
# printf "$LINE_BRK"

# log_end "CORE SPLITTER"


# #──────────────────────────────────────────
# log_start "CONAN"

# rm -fr ./build 
# conan install . --build=missing -c tools.build:jobs=$half
# # rm -fr ./conan.lock
# # conan lock create . --build=missing -c tools.build:jobs=$half

# log_end "CONAN"


# #──────────────────────────────────────────
# log_start "BUILD"

# cmake -DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
#     -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
#     -DBUILD_SHARED_LIBS=OFF \
#     -D_GLIBCXX_USE_CXX11_ABI=1 \
#     -DSPM_USE_BUILTIN_PROTOBUF=OFF \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DCMAKE_TOOLCHAIN_FILE=generators/conan_toolchain.cmake \
#     -S "$(pwd)" \
#     -B "$(pwd)/build/Release" \
#     -G "Unix Makefiles"

# cmake --build "$(pwd)/build/Release" --parallel $half

# log_end "BUILD"


# #──────────────────────────────────────────
# log_start "SANDBOX DEPLOY"

# printf "[INFO] Sending built .so to Sandbox folder...$LINE_BRK"
# rm -f ../Sandbox/*.so
# cp ./build/Release/RagPUREAI.cpython*.so ../Sandbox/

# log_end "SANDBOX DEPLOY"

