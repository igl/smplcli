# Versioning & Releases

Uses **semantic versioning** with git tags.

## Commands

```bash
make version         # Show current: vX.Y.Z (from git tag)
make suggest-version # Analyze commits, suggest next version
```

## Release Process

1. Check current and suggested version:
   ```bash
   make version
   make suggest-version
   ```

2. Create and push tag:
   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

3. GitHub Actions creates release automatically (if configured)

## Commit Conventions

`suggest-version.sh` detects bump type from commit messages:

| Pattern | Bump Type |
|---------|-----------|
| `BREAKING:` or `!:` | major |
| `feat:` or `feat(scope):` | minor |
| anything else | patch |

If Cursor IDE is available, it also uses AI analysis of the actual diff.
