# smplcli

A unified task runner that discovers and runs tasks from multiple sources.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/igl/smplcli/main/install.sh | bash
```

Requires **bash** or **zsh**. Works on macOS, Linux, and WSL.

Then restart your terminal or run `source ~/.zshrc` (or `~/.bashrc`).

## Usage

```bash
cli              # show available commands
cli <task>       # run a task
cli build --watch
```

## Supported Task Sources

| Source | Requires |
|--------|----------|
| `scripts/*.sh` | bash |
| `scripts/*.ts` | deno |
| `deno.json` tasks | deno, jq |
| `package.json` scripts | npm, jq |
| `Makefile` targets | make |

Priority: scripts → Makefile → deno.json → package.json

### Shebangs

`.ts` scripts default to `deno run -A`. Use a shebang to customize the runtime or set permissions:

```typescript
#!/usr/bin/env -S deno run --allow-net
console.log("runs with network permission only");
...
// This will fail with error: "NotCapable: Requires env access..."
console.log(process.env.SOME_VAR);
```

## Update / Uninstall

```bash
# Update to latest version
curl -fsSL https://raw.githubusercontent.com/igl/smplcli/main/install.sh | bash

# Uninstall
curl -fsSL https://raw.githubusercontent.com/igl/smplcli/main/uninstall.sh | bash
```

## Development

> Cursor is not required to use smplcli.

### Prerequisites

```bash
# macOS
brew install shellcheck shfmt bats-core

# Ubuntu/Debian
sudo apt install shellcheck
go install mvdan.cc/sh/v3/cmd/shfmt@latest  # or snap install shfmt
git clone https://github.com/bats-core/bats-core.git && sudo ./bats-core/install.sh /usr/local

# Arch
sudo pacman -S shellcheck shfmt bash-bats
```

### Commands

```bash
make check    # run all checks (CI uses this)
make lint     # run shellcheck
make fmt      # format with shfmt
make test     # run bats tests
```

### Git Hooks

Install git hooks to automatically format code before commits and run checks before pushes:

```bash
make install-hooks
```

This sets up:
- **pre-commit**: Formats shell files with `shfmt` before committing
- **pre-push**: Runs `make check` before pushing (prevents pushing broken code)

### Recommended

[Cursor Agent](https://cursor.sh) for AI-enhanced tasks (suggest-version, validate-docs, prepare-release).

## License

MIT
