#!/bin/bash
set -euo pipefail

REPO="igl/smplcli"
INSTALL_DIR="$HOME/.smplcli"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[smplcli]${NC} $1"; }
warn() { echo -e "${YELLOW}[smplcli]${NC} $1"; }
error() {
	echo -e "${RED}[smplcli]${NC} $1" >&2
	exit 1
}

# Check for jq dependency
if ! command -v jq &>/dev/null; then
	error "jq is required but not installed.
Install it with:
  macOS:  brew install jq
  Ubuntu: sudo apt install jq
  Arch:   sudo pacman -S jq"
fi

# Check for curl
if ! command -v curl &>/dev/null; then
	error "curl is required but not installed."
fi

# Get latest release tag from GitHub API
info "Fetching latest release..."
set +e
API_RESPONSE=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>&1)
CURL_EXIT=$?
set -e

if [ $CURL_EXIT -ne 0 ]; then
	warn "Failed to fetch release info: $API_RESPONSE"
	warn "Installing from main branch..."
	DOWNLOAD_URL="https://raw.githubusercontent.com/$REPO/main/cli.sh"
else
	LATEST_TAG=$(echo "$API_RESPONSE" | jq -r '.tag_name // empty' 2>/dev/null)
	if [ -z "$LATEST_TAG" ]; then
		warn "No releases found. Installing from main branch..."
		DOWNLOAD_URL="https://raw.githubusercontent.com/$REPO/main/cli.sh"
	else
		info "Found release: $LATEST_TAG"
		DOWNLOAD_URL="https://raw.githubusercontent.com/$REPO/$LATEST_TAG/cli.sh"
	fi
fi

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download cli.sh
info "Downloading cli.sh..."
if ! curl -fsSL "$DOWNLOAD_URL" -o "$INSTALL_DIR/cli.sh"; then
	error "Failed to download cli.sh"
fi

chmod +x "$INSTALL_DIR/cli.sh"

# Determine shell rc file
detect_shell_rc() {
	local shell_name
	shell_name=$(basename "$SHELL")

	case "$shell_name" in
		zsh) echo "$HOME/.zshrc" ;;
		bash)
			# Prefer .bashrc, fall back to .bash_profile on macOS
			if [ -f "$HOME/.bashrc" ]; then
				echo "$HOME/.bashrc"
			else
				echo "$HOME/.bash_profile"
			fi
			;;
		*) echo "$HOME/.profile" ;;
	esac
}

RC_FILE=$(detect_shell_rc)
SOURCE_LINE="source \"\$HOME/.smplcli/cli.sh\""

# Add source line if not already present
if ! grep -qF ".smplcli/cli.sh" "$RC_FILE" 2>/dev/null; then
	info "Adding source line to $RC_FILE..."
	{
		echo ""
		echo "# smplcli - unified task runner"
		echo "$SOURCE_LINE"
	} >>"$RC_FILE"
else
	info "Source line already exists in $RC_FILE"
fi

info "Installation complete!"
echo ""
echo "To use cli immediately, run: source $INSTALL_DIR/cli.sh"
echo "Or open a new terminal (cli will be available automatically)."
