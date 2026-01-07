.PHONY: lint fmt fmt-check test check version suggest-version help

# Default target
help:
	@echo "Available targets:"
	@echo "  lint           - Run shellcheck on all .sh files"
	@echo "  fmt            - Format shell files with shfmt"
	@echo "  fmt-check      - Check formatting without modifying"
	@echo "  test           - Run bats tests"
	@echo "  check          - Run lint + fmt-check + test (CI)"
	@echo "  version        - Show current version from git tag"
	@echo "  suggest-version - Analyze commits and suggest next version"

# Core targets (used by CI)

lint:
	@echo "Running shellcheck..."
	@shellcheck cli.sh install.sh uninstall.sh scripts/*.sh

fmt:
	@echo "Formatting shell files..."
	@shfmt -w -i 0 -ci cli.sh install.sh uninstall.sh scripts/*.sh

fmt-check:
	@echo "Checking formatting..."
	@shfmt -d -i 0 -ci cli.sh install.sh uninstall.sh scripts/*.sh

test:
	@echo "Running tests..."
	@bats tests/

check: lint fmt-check test
	@echo "All checks passed!"

version:
	@git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0"

# Developer targets (not in CI)

suggest-version:
	@./scripts/suggest-version.sh
