#!/usr/bin/env bats

# Load the cli function
setup() {
    # Source the cli.sh to get the function
    source "$BATS_TEST_DIRNAME/../cli.sh"

    # Store original directory
    ORIG_DIR="$PWD"

    # Create mock bin directory
    MOCK_BIN="$BATS_TEST_DIRNAME/tmp/bin"
    mkdir -p "$MOCK_BIN"

    # Add mock bin to PATH (prepend so mocks take precedence)
    export PATH="$MOCK_BIN:$PATH"
}

teardown() {
    cd "$ORIG_DIR"
    rm -rf "$BATS_TEST_DIRNAME/tmp"
}

# Helper to create mock command
create_mock() {
    local cmd="$1"
    local output="${2:-}"
    cat > "$MOCK_BIN/$cmd" << EOF
#!/bin/bash
echo "MOCK $cmd called with: \$*"
${output:+echo "$output"}
EOF
    chmod +x "$MOCK_BIN/$cmd"
}

# =============================================================================
# Help output tests
# =============================================================================

@test "cli --help shows help" {
    cd "$BATS_TEST_DIRNAME/fixtures/deno-project"
    run cli --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Available Commands:"* ]]
}

@test "cli -h shows help" {
    cd "$BATS_TEST_DIRNAME/fixtures/deno-project"
    run cli -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Available Commands:"* ]]
}

@test "cli help shows help" {
    cd "$BATS_TEST_DIRNAME/fixtures/deno-project"
    run cli help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Available Commands:"* ]]
}

@test "cli with no args shows help" {
    cd "$BATS_TEST_DIRNAME/fixtures/deno-project"
    run cli
    [ "$status" -eq 0 ]
    [[ "$output" == *"Available Commands:"* ]]
}

# =============================================================================
# Task discovery tests
# =============================================================================

@test "discovers deno.json tasks" {
    cd "$BATS_TEST_DIRNAME/fixtures/deno-project"
    run cli
    [ "$status" -eq 0 ]
    [[ "$output" == *"dev"* ]]
    [[ "$output" == *"build"* ]]
    [[ "$output" == *"(deno.json)"* ]]
}

@test "discovers package.json scripts" {
    cd "$BATS_TEST_DIRNAME/fixtures/npm-project"
    run cli
    [ "$status" -eq 0 ]
    [[ "$output" == *"dev"* ]]
    [[ "$output" == *"build"* ]]
    [[ "$output" == *"(package.json)"* ]]
}

@test "discovers scripts folder" {
    cd "$BATS_TEST_DIRNAME/fixtures/scripts-project"
    run cli
    [ "$status" -eq 0 ]
    [[ "$output" == *"build"* ]]
    [[ "$output" == *"dev"* ]]
    [[ "$output" == *"(scripts/"* ]]
}

@test "discovers Makefile targets" {
    cd "$BATS_TEST_DIRNAME/fixtures/make-project"
    run cli
    [ "$status" -eq 0 ]
    [[ "$output" == *"build"* ]]
    [[ "$output" == *"(make)"* ]]
}

# =============================================================================
# Empty project tests
# =============================================================================

@test "empty project shows error" {
    cd "$BATS_TEST_DIRNAME/fixtures/empty-project"
    run cli
    [ "$status" -eq 1 ]
    [[ "$output" == *"No deno.json, package.json, ./scripts/ folder or makefile found"* ]]
}

# =============================================================================
# Unknown command tests
# =============================================================================

@test "unknown command shows error" {
    cd "$BATS_TEST_DIRNAME/fixtures/deno-project"
    run cli nonexistent
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown command: nonexistent"* ]]
}

# =============================================================================
# Command execution tests (with mocks)
# =============================================================================

@test "executes deno task" {
    cd "$BATS_TEST_DIRNAME/fixtures/deno-project"
    create_mock "deno"
    run cli dev
    [ "$status" -eq 0 ]
    [[ "$output" == *"MOCK deno called with: task dev"* ]]
}

@test "executes npm script" {
    cd "$BATS_TEST_DIRNAME/fixtures/npm-project"
    create_mock "npm"
    run cli dev
    [ "$status" -eq 0 ]
    [[ "$output" == *"MOCK npm called with: run dev --"* ]]
}

@test "executes shell script from scripts folder" {
    cd "$BATS_TEST_DIRNAME/fixtures/scripts-project"
    run cli build
    [ "$status" -eq 0 ]
    [[ "$output" == *"scripts build.sh executed"* ]]
}

@test "executes ts script from scripts folder with deno" {
    cd "$BATS_TEST_DIRNAME/fixtures/scripts-project"
    create_mock "deno"
    run cli dev
    [ "$status" -eq 0 ]
    [[ "$output" == *"MOCK deno called with:"* ]]
}

@test "executes make target" {
    cd "$BATS_TEST_DIRNAME/fixtures/make-project"
    run cli build
    [ "$status" -eq 0 ]
    [[ "$output" == *"make build task"* ]]
}

# =============================================================================
# Priority tests (scripts > make > deno > npm)
# =============================================================================

@test "scripts folder takes priority over deno.json" {
    # Create a project with both scripts folder and deno.json
    mkdir -p "$BATS_TEST_DIRNAME/tmp/priority-test/scripts"
    echo '{"tasks":{"build":"echo deno"}}' > "$BATS_TEST_DIRNAME/tmp/priority-test/deno.json"
    echo '#!/bin/bash' > "$BATS_TEST_DIRNAME/tmp/priority-test/scripts/build.sh"
    echo 'echo "scripts wins"' >> "$BATS_TEST_DIRNAME/tmp/priority-test/scripts/build.sh"
    chmod +x "$BATS_TEST_DIRNAME/tmp/priority-test/scripts/build.sh"

    cd "$BATS_TEST_DIRNAME/tmp/priority-test"
    run cli build
    [ "$status" -eq 0 ]
    [[ "$output" == *"scripts wins"* ]]
}

# =============================================================================
# Multi-command execution tests
# =============================================================================

@test "executes multiple commands separated by __" {
    mkdir -p "$BATS_TEST_DIRNAME/tmp/multi-cmd/scripts"
    echo '#!/bin/bash
echo "lint: $*"' > "$BATS_TEST_DIRNAME/tmp/multi-cmd/scripts/lint.sh"
    echo '#!/bin/bash
echo "build: $*"' > "$BATS_TEST_DIRNAME/tmp/multi-cmd/scripts/build.sh"
    chmod +x "$BATS_TEST_DIRNAME/tmp/multi-cmd/scripts"/*.sh

    cd "$BATS_TEST_DIRNAME/tmp/multi-cmd"
    run cli lint __ build
    [ "$status" -eq 0 ]
    [[ "$output" == *"lint:"* ]]
    [[ "$output" == *"build:"* ]]
}

@test "multi-command passes arguments to each command" {
    mkdir -p "$BATS_TEST_DIRNAME/tmp/multi-args/scripts"
    echo '#!/bin/bash
echo "lint: $*"' > "$BATS_TEST_DIRNAME/tmp/multi-args/scripts/lint.sh"
    echo '#!/bin/bash
echo "build: $*"' > "$BATS_TEST_DIRNAME/tmp/multi-args/scripts/build.sh"
    echo '#!/bin/bash
echo "test: $*"' > "$BATS_TEST_DIRNAME/tmp/multi-args/scripts/test.sh"
    chmod +x "$BATS_TEST_DIRNAME/tmp/multi-args/scripts"/*.sh

    cd "$BATS_TEST_DIRNAME/tmp/multi-args"
    run cli lint --fix __ build -o dist __ test --watch
    [ "$status" -eq 0 ]
    [[ "$output" == *"lint: --fix"* ]]
    [[ "$output" == *"build: -o dist"* ]]
    [[ "$output" == *"test: --watch"* ]]
}

@test "multi-command stops on first failure" {
    mkdir -p "$BATS_TEST_DIRNAME/tmp/multi-fail/scripts"
    echo '#!/bin/bash
echo "first ok"' > "$BATS_TEST_DIRNAME/tmp/multi-fail/scripts/first.sh"
    echo '#!/bin/bash
echo "second fails" && exit 1' > "$BATS_TEST_DIRNAME/tmp/multi-fail/scripts/second.sh"
    echo '#!/bin/bash
echo "third should not run"' > "$BATS_TEST_DIRNAME/tmp/multi-fail/scripts/third.sh"
    chmod +x "$BATS_TEST_DIRNAME/tmp/multi-fail/scripts"/*.sh

    cd "$BATS_TEST_DIRNAME/tmp/multi-fail"
    run cli first __ second __ third
    [ "$status" -eq 1 ]
    [[ "$output" == *"first ok"* ]]
    [[ "$output" == *"second fails"* ]]
    [[ "$output" != *"third should not run"* ]]
}
