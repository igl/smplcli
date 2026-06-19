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

3. GitHub Actions (`cd.yml`) creates the release automatically: it verifies CI
   passed on the tagged commit, then publishes a release with `cli.sh` attached.

## Critical: fixes ship via tags, not `main`

`install.sh` downloads `cli.sh` from the **latest GitHub release tag**, not from
`main`. A fix merged to `main` does **not** reach users until a new version tag
is pushed. Symptom: a behavior change is present in the repo `cli.sh` but absent
from the installed copy at `~/.smplcli/cli.sh`.

When a `cli.sh` fix appears "not to work", check the installed copy first:

```bash
diff /opt/smplcli/cli.sh ~/.smplcli/cli.sh   # differences = installed copy is stale
```

To pick up a fix immediately without releasing, copy it in and re-source:

```bash
cp /opt/smplcli/cli.sh ~/.smplcli/cli.sh && source ~/.smplcli/cli.sh
```

The durable fix is always to push a new version tag.

## Commit Conventions

`suggest-version.sh` detects bump type from commit messages:

| Pattern | Bump Type |
|---------|-----------|
| `BREAKING:` or `!:` | major |
| `feat:` or `feat(scope):` | minor |
| anything else | patch |

If Cursor IDE is available, it also uses AI analysis of the actual diff.
