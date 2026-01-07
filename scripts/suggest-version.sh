#!/bin/bash
set -euo pipefail

# Get current version from latest git tag
get_current_version() {
    local version
    version=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    echo "${version#v}" # Remove 'v' prefix
}

# Parse semver into components
parse_version() {
    local version="$1"
    IFS='.' read -r MAJOR MINOR PATCH <<< "$version"
    MAJOR="${MAJOR:-0}"
    MINOR="${MINOR:-0}"
    PATCH="${PATCH:-0}"
}

# Analyze commits since last tag and determine bump type
analyze_commits() {
    local last_tag
    last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

    local commits
    if [ -n "$last_tag" ]; then
        commits=$(git log "$last_tag"..HEAD --oneline 2>/dev/null || echo "")
    else
        commits=$(git log --oneline 2>/dev/null || echo "")
    fi

    if [ -z "$commits" ]; then
        echo "patch" # Default to patch if no commits
        return
    fi

    # Check for breaking changes (BREAKING: or feat!: or fix!:)
    if echo "$commits" | grep -qiE '(BREAKING|!:)'; then
        echo "major"
        return
    fi

    # Check for new features
    if echo "$commits" | grep -qiE '^[a-f0-9]+ feat(\(|:)'; then
        echo "minor"
        return
    fi

    # Default to patch
    echo "patch"
}

# Calculate next version
next_version() {
    local current="$1"
    local bump="$2"

    parse_version "$current"

    case "$bump" in
        major)
            echo "$((MAJOR + 1)).0.0"
            ;;
        minor)
            echo "$MAJOR.$((MINOR + 1)).0"
            ;;
        patch)
            echo "$MAJOR.$MINOR.$((PATCH + 1))"
            ;;
    esac
}

# Main
main() {
    local current
    current=$(get_current_version)

    local bump
    bump=$(analyze_commits)

    local next
    next=$(next_version "$current" "$bump")

    echo "Current version: v$current"
    echo "Suggested bump:  $bump"
    echo "Next version:    v$next"
    echo ""
    echo "To release, run:"
    echo "  git tag v$next"
    echo "  git push origin v$next"
}

main "$@"
