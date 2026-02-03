# AGENTS.md Review Protocol

When creating or updating AGENTS.md files, follow this progressive disclosure review process.

## 1. Find Contradictions

Identify any instructions that conflict with each other. For each contradiction found, ask the user which version to keep.

**Common contradiction patterns:**
- Different files described as needing the same treatment (but actually don't)
- Commands that sound similar but do different things
- Inconsistent style requirements across sections

## 2. Identify the Essentials

Extract ONLY what belongs in the root AGENTS.md:

- One-sentence project description
- Package manager (if not npm)
- Non-standard build/typecheck/test commands
- Anything truly relevant to every single task
- Critical design constraints that could break things

**Root AGENTS.md should be scannable in under 30 seconds.**

## 3. Group the Rest

Organize remaining instructions into logical categories:

| Category | Typical Content |
|----------|-----------------|
| **Language Conventions** | Style rules, linting, formatting |
| **Testing** | Test runners, fixtures, mocks, patterns |
| **Development Workflow** | Setup, git hooks, IDE config |
| **Versioning & Releases** | Semver, tags, CI/CD |
| **Common Tasks** | How to add/modify specific file types |

Create separate markdown files for each category.

## 4. Create the File Structure

Output:
- Minimal root `AGENTS.md` with markdown links to separate files
- Each separate file with its relevant instructions
- Consistent folder structure under `docs/AGENTS/` (or user preference)

## 5. Flag for Deletion

Identify instructions that are:

| Type | Example | Action |
|------|---------|--------|
| **Redundant** | Standard practices the agent already knows | Remove |
| **Too vague** | "Write clean code", "Follow best practices" | Remove or make specific |
| **Overly obvious** | File header comments explaining it's a file | Remove |
| **OS-specific setup** | `brew install`, `apt install` commands | Remove (agent can look up) |
| **Verbose checklists** | 10+ item lists that CI already covers | Reduce to essentials |

## Output Format

### Root AGENTS.md Template

```markdown
# AGENTS.md - {project-name}

> One-line description of what this project does.

## Quick Start

```bash
{non-standard-command}    # One-line description
{another-command}         # Another one-liner
```

## Project-Specific Context

| Aspect | Detail |
|--------|--------|
| **Architecture** | {brief note} |
| **{Key Aspect}** | {brief note} |
| **CI command** | {command} |

## Docs

- [{Category}](./docs/AGENTS/{file}.md)
- [{Category}](./docs/AGENTS/{file}.md)

## Critical Design Constraints

- **{Constraint}** → {consequence if ignored}
- **{Constraint}** → {consequence if ignored}
```

### Category File Template

```markdown
# {Category Name}

## {Subtopic}

Specific, actionable instructions.

```bash
# Example command
command --arg
```

## {Another Subtopic}

| Thing | Value | Why |
|-------|-------|-----|
| ... | ... | ... |
```

## Review Checklist

Before finalizing AGENTS.md changes:

- [ ] No contradictions remain (or user confirmed resolution)
- [ ] Root AGENTS.md under 50 lines
- [ ] Root AGENTS.md scannable in 30 seconds
- [ ] All non-essential content in linked sub-files
- [ ] All content is specific and actionable
- [ ] No redundant/obvious instructions
- [ ] Critical constraints prominently featured
- [ ] All links between files work
