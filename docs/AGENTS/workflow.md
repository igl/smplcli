# Development Workflow

## Prerequisites

Install globally:

```bash
# macOS
brew install shellcheck shfmt bats-core

# Ubuntu/Debian
sudo apt install shellcheck jq
go install mvdan.cc/sh/v3/cmd/shfmt@latest
# Install bats-core from source
```

## Make Targets

```bash
make check          # CI: lint + fmt-check + test
make lint           # shellcheck
make fmt            # shfmt -w
make fmt-check      # shfmt -d (dry run)
make test           # bats tests/
make install-hooks  # Setup git hooks
make version        # Show current git tag
make suggest-version # Analyze commits, suggest next version
```

## Git Hooks

Install to auto-format on commit and block push if checks fail:

```bash
make install-hooks
```

| Hook | Runs |
|------|------|
| **pre-commit** | `make fmt` + re-add formatted files |
| **pre-push** | `make check` (blocks push on failure) |

Hooks are symlinks from `hooks/` to `.git/hooks/`.
