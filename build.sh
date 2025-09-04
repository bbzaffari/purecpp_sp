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
    print_module "$dir"
    cd "$dir" || exit 1
    ./o.sh
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
