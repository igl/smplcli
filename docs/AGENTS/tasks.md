# Common Tasks

## Adding a Make Target

Edit `Makefile`:

```makefile
.PHONY: lint ... new-target

help:
	@echo "Available targets:"
	...
	@echo "  new-target     - Description here"

new-target:
	@echo "Doing the thing..."
	@command --arg
```

## Adding a Script

1. Create `scripts/my-script.sh`
2. Add to top of file:
   ```bash
   #!/bin/bash
   set -euo pipefail
   ```
3. Update `Makefile` lint/fmt targets to include new file
4. Run `make check`

## Modifying cli.sh

**Critical**: `cli.sh` is sourced into user's shell. **Never add `set -euo pipefail`.**

Guidelines:
- Keep functions modular (`cli` → `_cli_single`)
- Maintain backward compatibility (users source this directly)
- Test with fixtures: `cd tests/fixtures/X && source ../../cli.sh && cli`

## Testing Changes

Test against all supported project types:

```bash
cd tests/fixtures/deno-project && source ../../cli.sh && cli
cd tests/fixtures/npm-project && source ../../cli.sh && cli
cd tests/fixtures/scripts-project && source ../../cli.sh && cli
cd tests/fixtures/make-project && source ../../cli.sh && cli
```
