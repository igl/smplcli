#!/bin/bash
set -euo pipefail

INSTALL_DIR="$HOME/.smplcli"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

info() { echo -e "${GREEN}[smplcli]${NC} $1"; }
warn() { echo -e "${RED}[smplcli]${NC} $1"; }

# Remove install directory
if [ -d "$INSTALL_DIR" ]; then
	info "Removing $INSTALL_DIR..."
	rm -rf "$INSTALL_DIR"
else
	info "Install directory not found, skipping..."
fi

# Remove source lines from shell rc files
remove_from_rc() {
	local rc_file="$1"
	if [ -f "$rc_file" ] && grep -qF ".smplcli/cli.sh" "$rc_file"; then
		info "Removing source line from $rc_file..."
		# Remove the source line and the comment above it
		sed -i.bak '/.smplcli\/cli.sh/d' "$rc_file"
		sed -i.bak '/# smplcli - unified task runner/d' "$rc_file"
		rm -f "${rc_file}.bak"
	fi
}

remove_from_rc "$HOME/.zshrc"
remove_from_rc "$HOME/.bashrc"
remove_from_rc "$HOME/.bash_profile"
remove_from_rc "$HOME/.profile"

info "Uninstall complete!"
echo ""
echo "Restart your terminal or run: exec \$SHELL"
