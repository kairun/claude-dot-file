# Kairun Claude Code Configuration

A curated collection of sub-agents for Claude Code that enhance your development workflow with specialized AI assistants.

## What's Included

This configuration package provides 5 powerful sub-agents:

### 🧠 kairun-working-memory-manager
Maintains project context across development sessions through `.kairun/working-memory.md`. Automatically tracks:
- Current tasks and progress
- Important architectural decisions
- Key discoveries and insights
- Next steps and open questions

### 🔒 kairun-security-reviewer
Reviews code changes for security vulnerabilities including:
- Authentication/authorization issues
- SQL injection risks
- Secrets management problems
- Input validation gaps
- Certificate handling flaws

### ✨ kairun-code-practices-enforcer
Enforces language-specific best practices and coding standards:
- Idiomatic code patterns
- Error handling consistency
- Performance optimizations
- Code organization and structure

### 🎯 kairun-review-orchestrator
Coordinates comprehensive code reviews by running multiple reviewer agents in parallel and compiling their feedback into actionable insights.

### 📋 kairun-plan-tracker
Maintains implementation plans and tracks project progress through `.kairun/plans-and-todos.md`. Automatically:
- Records initial implementation plans
- Updates plans as work progresses
- Tracks completed tasks and new requirements
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
1. Create symlinks from this repo to `~/.claude/agents/`
2. Preserve any existing files by creating backups
3. Show you a summary of what was installed

### Verify Installation

After installation, start a new Claude Code session and run:

```bash
claude /agents
```

You should see all the `kairun-*` agents listed.

## Usage

Claude Code will automatically invoke these agents when appropriate based on their descriptions. You can also explicitly request them:

```bash
# Explicitly invoke an agent
claude "Use the kairun-security-reviewer to check this code"

# The agents work proactively
claude "Add a new authentication endpoint"
# → Claude will automatically use kairun-security-reviewer after implementation
```

### Working Memory

The working memory manager creates a `.kairun/working-memory.md` file in your project to track context. To initialize it:

```bash
claude "Let's start working on the authentication feature"
# → kairun-working-memory-manager will automatically create and maintain the file
```

## Customization

All agent files are in the `agents/` directory as Markdown files with YAML frontmatter. You can:

1. **Modify existing agents**: Edit the `.md` files directly
2. **Add new agents**: Create new `.md` files in `agents/`
3. **Adjust behavior**: Update the `description` field to change when agents are invoked

After making changes, your updates will be reflected immediately since the files are symlinked.

## Uninstallation

```bash
cd kairun-claude-config
./uninstall.sh
```

This will remove all symlinks created by the installer. Your original files (if any were backed up) will remain in `~/.claude/agents/*.backup.*`.

## Project Structure

```
kairun-claude-config/
├── agents/                          # Sub-agent definitions
│   ├── kairun-working-memory-manager.md
│   ├── kairun-code-practices-enforcer.md
│   ├── kairun-security-reviewer.md
│   ├── kairun-review-orchestrator.md
│   └── kairun-plan-tracker.md
├── skills/                          # Skills (future expansion)
├── init-prompts/                    # Original prompts used for creating agents/skills
│                                    # (Not installed/uninstalled)
├── install.sh                       # Installation script
├── uninstall.sh                     # Uninstallation script
└── README.md                        # This file
```

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

The installer automatically backs up existing files to `*.backup.TIMESTAMP`. You can:
- Restore backups: `mv ~/.claude/agents/file.backup.* ~/.claude/agents/file`
- Remove backups: `rm ~/.claude/agents/*.backup.*`

## Contributing

Found a bug or want to improve an agent? Feel free to submit issues or pull requests!

## License

[Your License Here]

## Credits

Built for the Claude Code community to enhance AI-assisted development workflows.
