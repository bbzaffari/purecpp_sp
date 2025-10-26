#!/bin/bash

#====================== COLORS =====================
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# -- Function to print a formatted module header --
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

# --- Function to compile a specific module ---
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
    echo "  all => run all modules"
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

    echo -e "$CYAN"
    echo ""
    echo "============================================================"
    echo "      Total build time: ${ELAPSED_TIME} s"
    echo "============================================================"
    echo "       ALL MODULES COMPILED SUCCESSFULLY!"
    echo "============================================================"
    echo -e "$RESET"
else
    case "$1" in
        [1-5])
            START_TIME=$(date +%s)
            run_module "${modules[$(( $1 - 1 ))]}"
        
            END_TIME=$(date +%s)
            ELAPSED_TIME=$((END_TIME - START_TIME))

            echo -e "$CYAN"
            echo ""
            echo "============================================================"
            echo "       Total build time: ${ELAPSED_TIME} s"
            echo "============================================================"
            echo "       $modules MODULE COMPILED SUCCESSFULLYa!"
            echo "============================================================"
            echo -e "$RESET"
            ;;
        *)
            echo "Invalid argument: '$1'"
            echo "Please use a number between 1 and 5, or 'all'"
            ;;
    esac
fi



