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

    # Explicit keywords always take precedence
    # Check for breaking changes (BREAKING: or feat!: or fix!:)
    if echo "$commits" | grep -qiE '(BREAKING|!:)'; then
        echo "major"
        return
    fi

    # Check for new features keyword
    if echo "$commits" | grep -qiE '^[a-f0-9]+ feat(\(|:)'; then
        echo "minor"
        return
    fi

    # Try AI analysis of actual code changes
    local ai_suggestion
    ai_suggestion=$(analyze_with_ai "$last_tag")
    if [ -n "$ai_suggestion" ]; then
        echo "$ai_suggestion"
        return
    fi

    # Default to patch
    echo "patch"
}

# Use cursor agent to analyze code diff and suggest version bump
analyze_with_ai() {
    local last_tag="$1"

    # Check if cursor agent is available
    if ! command -v cursor &>/dev/null; then
        return
    fi

    # Get the actual code diff
    local diff
    if [ -n "$last_tag" ]; then
        diff=$(git diff "$last_tag"..HEAD 2>/dev/null || echo "")
    else
        diff=$(git diff HEAD~10..HEAD 2>/dev/null || echo "")
    fi

    if [ -z "$diff" ]; then
        return
    fi

    # Truncate diff to ~300 lines to limit size while avoiding UTF-8 character issues
    # This is safer than byte-based truncation which can cut multi-byte characters
    local truncated_diff
    truncated_diff=$(echo "$diff" | head -n 300)

    if [ -z "$truncated_diff" ]; then
        return
    fi

    # Use cursor agent in print mode to analyze the diff
    # Add timeout to prevent hanging (30 seconds) if available
    local result
    local prompt
    prompt="Analyze this git diff and suggest a semver version bump.

RULES:
- major: Breaking changes (removed/renamed public APIs, incompatible changes)
- minor: New features (new functions, new options, new capabilities)
- patch: Bug fixes, refactoring, docs, tests, internal changes

Respond with ONLY one word: major, minor, or patch

DIFF:
${truncated_diff}"

    if command -v timeout &>/dev/null; then
        result=$(timeout 30 cursor agent -p "$prompt" 2>/dev/null | tr '[:upper:]' '[:lower:]' | grep -oE '\b(major|minor|patch)\b' | head -1)
    else
        result=$(cursor agent -p "$prompt" 2>/dev/null | tr '[:upper:]' '[:lower:]' | grep -oE '\b(major|minor|patch)\b' | head -1)
    fi

    # Validate and return result
    case "$result" in
        major|minor|patch) echo "$result" ;;
    esac
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
