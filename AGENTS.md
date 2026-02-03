# AGENTS.md - smplcli

> Unified task runner that discovers commands from `scripts/*`, `Makefile`, `deno.json`, and `package.json`.

## Quick Start

```bash
make check          # Run CI checks (lint + fmt-check + test)
make install-hooks  # Setup git hooks
```

## Project-Specific Context

| Aspect | Detail |
|--------|--------|
| **Architecture** | Shell functions (sourced, not executed) in `cli.sh` |
| **Test runner** | [bats-core](https://github.com/bats-core/bats-core): `bats tests/` |
| **CI command** | `make check` |

## Docs

- [Shell Conventions](./docs/AGENTS/shell-conventions.md) - shfmt, shellcheck, style rules
- [Testing](./docs/AGENTS/testing.md) - bats fixtures, mocks, patterns
- [Development Workflow](./docs/AGENTS/workflow.md) - setup, git hooks, make targets
- [Versioning & Releases](./docs/AGENTS/versioning.md) - semver, git tags
- [Common Tasks](./docs/AGENTS/tasks.md) - modifying cli.sh, adding scripts

**Maintainers**: See [AGENTS.md Review Protocol](./docs/AGENTS/agent.md) when updating these docs.

## Critical Design Constraints

- **`cli.sh` is SOURCED** into user's shell → **never add `set -euo pipefail`** to it
- Scripts in `scripts/*.sh` ARE executed → **must have `set -euo pipefail`**
