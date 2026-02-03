# Shell Conventions

All shell scripts must pass **shellcheck** and use **shfmt** formatting.

## Formatting

```bash
# Format (tabs, indent case labels)
shfmt -w -i 0 -ci cli.sh install.sh uninstall.sh scripts/*.sh

# Check without modifying
shfmt -d -i 0 -ci cli.sh install.sh uninstall.sh scripts/*.sh
```

## Style Rules

- **Indentation**: Tabs only (`-i 0`)
- **Conditionals**: Use `[[ ]]` for bash
- **Variables**: Quote all: `"$var"`, never `$var`
- **Functions**: Use `local var=value`, lowercase with underscores
- **Errors**: Redirect to stderr: `echo "error" >&2`

## Critical Distinction

| File Type | `set -euo pipefail`? | Reason |
|-----------|---------------------|--------|
| `cli.sh` | **NO** | Sourced into user's shell; would affect their environment |
| `scripts/*.sh` | **YES** | Executed standalone; need strict error handling |
| `install.sh`, `uninstall.sh` | **YES** | Executed standalone |

## Error Handling Patterns

```bash
# Good - exit on failure
if ! command "$@"; then
    echo "Error: command failed" >&2
    exit 1
fi

# Good - preserve exit code
command "$@" || return $?
```
