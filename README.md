# Kairun Claude Code Configuration

A curated collection of sub-agents for Claude Code that enhance your development workflow with specialized AI assistants.

## What's Included

This configuration package provides 5 powerful sub-agents that work together through a shared `.kairun/` directory:

### 🧠 kairun-working-memory-manager
The central memory hub that maintains project context across development sessions. Automatically invoked at session start and after every task completion. Manages `.kairun/working-memory.md` (read by all other agents):
- Current tasks and progress
- Important architectural decisions
- Key discoveries and insights
- Next steps and open questions
- Handles manual memory reset/clear requests

### 🎯 kairun-review-orchestrator
The primary entry point for all code reviews. Coordinates comprehensive reviews by launching security-reviewer and code-practices-enforcer agents **simultaneously in parallel**, then compiling their feedback into unified, actionable insights. Use this agent for code reviews, not the individual reviewers.

### 🔒 kairun-security-reviewer
Security review specialist invoked **only by the orchestrator** (not directly). Reviews code changes for vulnerabilities:
- Authentication/authorization issues
- SQL injection risks
- Secrets management problems
- Input validation gaps
- Certificate handling flaws
- Returns findings to orchestrator for compilation

### ✨ kairun-code-practices-enforcer
Code quality specialist invoked **only by the orchestrator** (not directly). Enforces language-specific best practices:
- Idiomatic code patterns
- Error handling consistency
- Performance optimizations
- Code organization and structure
- Returns findings to orchestrator for compilation

### 📋 kairun-plan-tracker
Maintains implementation plans and tracks project progress through `.kairun/plans-and-todos.md`:
- Records initial implementation plans
- Updates plans as work progresses
- Tracks completed tasks and new requirements
- Cross-references working memory for context
- Maintains project direction and priorities

## Installation

### Prerequisites
- Claude Code must be installed and run at least once
- Git

### Quick Install

```bash
# Clone this repository
git clone <repository-url> kairun-claude-config
cd kairun-claude-config

# Run the install script
./install.sh
```

The install script will:
1. Create symlinks from this repo to `~/.claude/agents/` and `~/.claude/skills/`
2. Install a SessionStart hook into `~/.claude/settings.json` that loads working memory automatically
3. Show you a summary of what was installed

### Verify Installation

After installation, start a new Claude Code session and run:

```bash
claude /agents
```

You should see all the `kairun-*` agents listed.

## Usage

### How Agents Coordinate

The agents use a **shared memory architecture** through the `.kairun/` directory:

- **`.kairun/working-memory.md`**: Central shared memory managed exclusively by `working-memory-manager`. All other agents read from it for context but never edit it.
- **`.kairun/plans-and-todos.md`**: Implementation plans managed exclusively by `plan-tracker`.

**Note**: Add `.kairun/` to your project's `.gitignore` to keep session context local.

### Agent Invocation Flow

Claude Code automatically invokes agents when appropriate:

```bash
# 1. Session start - working-memory-manager activates automatically via SessionStart hook
claude "Let's work on adding authentication"
# → SessionStart hook injects context instructing Claude to use kairun-working-memory-manager
# → kairun-working-memory-manager checks/creates .kairun/working-memory.md
# → Context from previous sessions is loaded automatically

# 2. After implementing code - orchestrator runs review
claude "I've added the login endpoint"
# → kairun-review-orchestrator launches in parallel:
#    - kairun-security-reviewer (checks for vulnerabilities)
#    - kairun-code-practices-enforcer (checks code quality)
# → Orchestrator compiles findings and returns to main process
# → kairun-working-memory-manager records results

# 3. Manual memory operations
claude "Reset working memory"
# → kairun-working-memory-manager handles reset with user options

# 4. Planning sessions
claude "Let's plan the database migration"
# → kairun-plan-tracker creates/updates .kairun/plans-and-todos.md
```

### Direct Agent Usage

For code reviews, always use the orchestrator (not individual reviewers):

```bash
# ✅ Correct - use orchestrator
claude "Review my authentication code"
# → Uses kairun-review-orchestrator

# ❌ Incorrect - don't invoke reviewers directly
claude "Use kairun-security-reviewer to check this"
# → Security/practices agents should only be invoked by orchestrator
```

## Architecture

### Shared Memory Design

```
.kairun/
├── working-memory.md    # Managed by: working-memory-manager (write)
│                        # Read by: ALL agents for context
└── plans-and-todos.md   # Managed by: plan-tracker (write)
                         # Read by: plan-tracker only
```

### Agent Relationships

```
Main Process
    ├─→ working-memory-manager (session start, after every task)
    ├─→ review-orchestrator (after code changes)
    │   ├─→ security-reviewer (parallel)
    │   └─→ code-practices-enforcer (parallel)
    └─→ plan-tracker (planning sessions)
```

## Customization

All agent files are in the `agents/` directory as Markdown files with YAML frontmatter. The `AGENT_CREATION_PROMPTS.md` file in the root contains the original prompts and design rationale used to create each agent.

You can:

1. **Modify existing agents**: Edit the `.md` files in `agents/` directly
2. **Add new agents**: Create new `.md` files in `agents/` with proper YAML frontmatter (use `kairun-` prefix)
3. **Adjust behavior**: Update the `description` field to change when agents are invoked
4. **Modify SessionStart hook**: Edit `hooks/session-start-hook.sh` to change session initialization behavior
5. **Reference original prompts**: Check `AGENT_CREATION_PROMPTS.md` for the design rationale

After making changes, your updates will be reflected immediately since the files are symlinked.

## Uninstallation

```bash
cd kairun-claude-config
./uninstall.sh
```

This will:
- Remove all agent symlinks created by the installer
- Remove the SessionStart hook from `~/.claude/settings.json`

## Project Structure

```
kairun-claude-config/
├── agents/                          # Sub-agent definitions (symlinked to ~/.claude/agents/)
│   ├── kairun-working-memory-manager.md
│   ├── kairun-code-practices-enforcer.md
│   ├── kairun-security-reviewer.md
│   ├── kairun-review-orchestrator.md
│   └── kairun-plan-tracker.md
├── hooks/                           # Claude Code hooks
│   └── session-start-hook.sh        # SessionStart hook (installed to ~/.claude/settings.json)
├── skills/                          # Skills (future expansion)
├── AGENT_CREATION_PROMPTS.md        # Original prompts used to create agents (documentation)
├── install.sh                       # Installation script
├── uninstall.sh                     # Uninstallation script
└── README.md                        # This file
```

**Note**:
- Agent files with `kairun-` prefix are symlinked to `~/.claude/agents/`
- The SessionStart hook is registered in `~/.claude/settings.json`
- Documentation files remain in the repo for reference

## Why Symlinks?

Using symlinks means:
- ✅ Updates to this repo automatically reflect in your Claude Code config
- ✅ Easy to track changes via git
- ✅ Can maintain multiple configuration sets
- ✅ Simple to share with your team

## Troubleshooting

### Agents not appearing?

1. Make sure you started a new Claude Code session after installation
2. Check that symlinks were created: `ls -la ~/.claude/agents/kairun-*`
3. Verify Claude Code config directory exists: `ls -la ~/.claude/`

### Symlink conflicts?

If you have an existing file (not a symlink) with the same name as a kairun agent, the installer will skip it and show an error. Since all agents are namespaced with `kairun-`, conflicts should be rare.

## Contributing

Found a bug or want to improve an agent? Feel free to submit issues or pull requests!

## License

[Your License Here]

## Credits

Built for the Claude Code community to enhance AI-assisted development workflows.
