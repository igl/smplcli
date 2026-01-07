# smplcli

A unified task runner that discovers and runs tasks from multiple sources in your project.

## Prerequisites

**jq** is required for parsing JSON files.

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq

# Arch
sudo pacman -S jq
```

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/igl/smplcli/main/install.sh | bash
```

Then restart your terminal or run `source ~/.zshrc` (or `~/.bashrc`).

## Usage

```bash
# Show available commands
cli

# Run a command
cli <command> [args...]

# Examples
cli build
cli dev --watch
cli test
```

## Supported Task Sources

smplcli discovers tasks from these sources (in priority order):

| Source | Example |
|--------|---------|
| `scripts/*.sh` | `cli build` → runs `scripts/build.sh` |
| `scripts/*.ts` | `cli dev` → runs `scripts/dev.ts` with deno |
| `deno.json` tasks | `cli build` → `deno task build` |
| `package.json` scripts | `cli build` → `npm run build` |
| `Makefile` targets | `cli build` → `make build` |

If multiple sources define the same command, scripts folder takes priority.

## Update / Uninstall

```bash
# Update to latest version
curl -fsSL https://raw.githubusercontent.com/igl/smplcli/main/install.sh | bash

# Uninstall
curl -fsSL https://raw.githubusercontent.com/igl/smplcli/main/uninstall.sh | bash
```

## Development

> Cursor is not required to use smplcli.

### Prerequisites for contributing

- [shellcheck](https://github.com/koalaman/shellcheck) - shell script linter
- [shfmt](https://github.com/mvdan/sh) - shell script formatter
- [bats-core](https://github.com/bats-core/bats-core) - bash testing framework

### Recommended

- [Cursor IDE](https://cursor.sh) - for AI-enhanced tasks (suggest-version, validate-docs)

### Commands

```bash
make check    # run all checks (CI uses this)
make lint     # run shellcheck
make fmt      # format with shfmt
make test     # run bats tests
```

## License

MIT
