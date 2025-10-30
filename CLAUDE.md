# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository is a **configuration package for Claude Code** that provides 5 specialized sub-agents with the `kairun-` namespace prefix. Users install it via symlinks to their global `~/.claude/` directory.

## Architecture

### Namespace Strategy
All agents use the `kairun-` prefix to:
- Avoid collisions with user's existing agents
- Enable safe uninstallation (remove all `kairun-*` symlinks)
- Clearly identify agents from this package

### Agent Structure
Each agent is a Markdown file with YAML frontmatter:
```yaml
---
name: kairun-agent-name
description: Detailed description with examples of when Claude should invoke it
tools: List, Of, Available, Tools
model: inherit|haiku|sonnet|opus
color: colorname
---
[Agent prompt and instructions in markdown]
```

The `description` field is **critical** - it determines when Claude automatically invokes the agent.

### Installation Mechanism
- `install.sh` creates **individual symlinks** for each agent file from `agents/*.md` to `~/.claude/agents/`
- Individual symlinks (not directory-level) allow users to keep their existing agents
- Backs up existing files with `.backup.TIMESTAMP` suffix
- Skills follow same pattern: `skills/*/` → `~/.claude/skills/*/`

### Uninstallation Mechanism
- `uninstall.sh` removes symlinks matching `kairun-*` pattern
- Only removes symlinks (never touches real files)
- Relies on namespace prefix rather than checking symlink source

## Agent Responsibilities

1. **kairun-working-memory-manager**: Manages `.kairun/working-memory.md` for session continuity
2. **kairun-plan-tracker**: Maintains `.kairun/plans-and-todos.md` for implementation plans
3. **kairun-security-reviewer**: Reviews code changes for security vulnerabilities
4. **kairun-code-practices-enforcer**: Enforces language-specific best practices
5. **kairun-review-orchestrator**: Coordinates parallel reviews by other agents

## Development Workflow

### Testing Installation
```bash
./install.sh
ls -la ~/.claude/agents/kairun-*  # Verify symlinks created
claude /agents                     # Verify agents appear in Claude Code
```

### Testing Uninstallation
```bash
./uninstall.sh
ls -la ~/.claude/agents/kairun-*  # Should show no results
```

### Adding New Agents
1. Create `agents/kairun-new-agent.md` with proper YAML frontmatter
2. Ensure `name:` matches filename (without `.md`)
3. Write comprehensive `description` with examples
4. Test installation picks it up automatically

### Modifying Existing Agents
Since users have symlinks, changes to agent files immediately affect their installations. Be careful with breaking changes.

## Important Constraints

- **Never remove the `kairun-` prefix** from agent names
- **Individual file symlinks only** (not directory-level)
- **Agent descriptions must include examples** of when to invoke
- **Skills directory structure**: Each skill is a subdirectory with `SKILL.md` inside
- Keep installation/uninstallation scripts simple and idempotent
