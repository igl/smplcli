function cli {
    local cmd="$1"
    
    # Collect scripts, Deno tasks, NPM tasks and Makefile tasks
    local scripts=()
    if [ -d "scripts" ]; then
        setopt local_options nullglob 2>/dev/null || shopt -s nullglob 2>/dev/null
        for f in scripts/*.ts scripts/*.sh; do
            [ -e "$f" ] && scripts+=("$(basename "$f")")
        done
    fi

    local deno_tasks=()
    if [ -f "deno.json" ]; then
        while IFS= read -r task; do
            [ -n "$task" ] && deno_tasks+=("$task")
        done < <(jq -r '.tasks // {} | keys | .[]' deno.json 2>/dev/null)
    fi

    local node_tasks=()
    if [ -f "package.json" ]; then
        while IFS= read -r task; do
            [ -n "$task" ] && node_tasks+=("$task")
        done < <(jq -r '.scripts // {} | keys | .[]' package.json 2>/dev/null)
    fi
    
    local makefile_tasks=()
    if command -v make &>/dev/null && make -q 2>/dev/null; [ $? -ne 2 ]; then
        while IFS= read -r task; do
            [ -n "$task" ] && makefile_tasks+=("$task")
        done < <(make -p 2>/dev/null | grep -E '^[a-zA-Z0-9_-]+:' | sed 's/://')
    fi

    # Check if anything is available
    if [ ${#scripts[@]} -eq 0 ] && [ ${#deno_tasks[@]} -eq 0 ] && [ ${#node_tasks[@]} -eq 0 ] && [ ${#makefile_tasks[@]} -eq 0 ]; then
        echo "No deno.json, package.json, ./scripts/ folder or makefile found" >&2
        return 1
    fi

    # Show help
    if [ -z "$cmd" ] || [[ "$cmd" =~ ^(help|--help|-h)$ ]]; then
        echo "Available Commands:"
        for name in "${scripts[@]}"; do
            local base="${name%.*}"
            printf "  cli %-12s (scripts/%s)\n" "$base" "$name"
        done
        for t in "${deno_tasks[@]}"; do
            printf "  cli %-12s (deno.json)\n" "$t"
        done
        for t in "${node_tasks[@]}"; do
            printf "  cli %-12s (package.json)\n" "$t"
        done
        for t in "${makefile_tasks[@]}"; do
            printf "  cli %-12s (make)\n" "$t"
        done
        return 0
    fi

    # Try scripts first
    for ext in ts sh; do
        local script="scripts/${cmd}.${ext}"
        [ -f "$script" ] || continue
        shift
        if [ "$ext" = "sh" ]; then
            bash "$script" "$@"
        else
            local shebang=$(sed -n '1s/^#![[:space:]]*//p' "$script")
            shebang="${shebang#/usr/bin/env }"; shebang="${shebang#-S }"
            ${shebang:-deno run -A} "$script" "$@"
        fi
        return $?
    done

    # Try Deno/NPM tasks last
    for t in "${deno_tasks[@]}"; do
        if [ "$cmd" = "$t" ]; then shift; deno task "$cmd" "$@"; return $?; fi
    done
    for t in "${node_tasks[@]}"; do
        if [ "$cmd" = "$t" ]; then shift; npm run "$cmd" -- "$@"; return $?; fi
    done
    for t in "${makefile_tasks[@]}"; do
        if [ "$cmd" = "$t" ]; then shift; make "$cmd" "$@"; return $?; fi
    done

    echo "Unknown command: $cmd (run 'cli' for help)" >&2
    return 1
}
