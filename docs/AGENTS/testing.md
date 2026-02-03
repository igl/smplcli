# Testing

Uses [bats-core](https://github.com/bats-core/bats-core) framework.

## Running Tests

```bash
bats tests/                    # Run all tests
bats tests/cli.bats -f "help"  # Filter by pattern
```

## Test Fixtures

Located in `tests/fixtures/`:

| Fixture | Purpose |
|---------|---------|
| `deno-project/` | Project with deno.json |
| `npm-project/` | Project with package.json |
| `scripts-project/` | Project with scripts/ folder |
| `make-project/` | Project with Makefile |
| `empty-project/` | Empty project (error case) |

## Mock Pattern

Tests create mock commands in `$MOCK_BIN` to avoid external dependencies:

```bash
setup() {
    MOCK_BIN="$BATS_TEST_DIRNAME/tmp/bin"
    mkdir -p "$MOCK_BIN"
    export PATH="$MOCK_BIN:$PATH"
}

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
```

## Testing Checklist

Before committing core logic changes:

- [ ] `make check` passes
- [ ] New functionality has bats tests
- [ ] Multi-command chains (`__`) tested if applicable
- [ ] Error handling preserves exit codes
