#!/bin/bash

# Claude Code Config Installer
# This script symlinks agents and skills to your global Claude Code configuration

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_CONFIG_DIR="$HOME/.claude"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Claude Code Configuration Installer  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if ~/.claude directory exists
if [ ! -d "$CLAUDE_CONFIG_DIR" ]; then
    echo -e "${RED}Error: ~/.claude directory not found${NC}"
    echo -e "${YELLOW}Please make sure Claude Code is installed and has been run at least once.${NC}"
    exit 1
fi

# Create subdirectories if they don't exist
echo -e "${BLUE}→${NC} Ensuring Claude Code directories exist..."
mkdir -p "$CLAUDE_CONFIG_DIR/agents"
mkdir -p "$CLAUDE_CONFIG_DIR/skills"

# Function to create symlink safely
create_symlink() {
    local source=$1
    local target=$2
    local name=$3

    if [ -L "$target" ]; then
        if [ "$(readlink "$target")" = "$source" ]; then
            echo -e "  ${GREEN}✓${NC} $name (already linked)"
            return 0
        else
            echo -e "  ${YELLOW}⚠${NC} $name (removing old symlink)"
            rm "$target"
        fi
    elif [ -e "$target" ]; then
        echo -e "  ${RED}✗${NC} $name (file exists but not a symlink, skipping)"
        return 1
    fi

    ln -s "$source" "$target"
    echo -e "  ${GREEN}✓${NC} $name (linked)"
}

# Install agents
echo ""
echo -e "${BLUE}→${NC} Installing sub-agents..."
agent_count=0
if [ -d "$SCRIPT_DIR/agents" ] && [ "$(ls -A $SCRIPT_DIR/agents 2>/dev/null)" ]; then
    for agent_file in "$SCRIPT_DIR/agents"/*.md; do
        if [ -f "$agent_file" ]; then
            agent_name=$(basename "$agent_file")
            create_symlink "$agent_file" "$CLAUDE_CONFIG_DIR/agents/$agent_name" "$agent_name"
            ((agent_count++))
        fi
    done
else
    echo -e "  ${YELLOW}No agents found to install${NC}"
fi

# Install skills
echo ""
echo -e "${BLUE}→${NC} Installing skills..."
skill_count=0
if [ -d "$SCRIPT_DIR/skills" ] && [ "$(ls -A $SCRIPT_DIR/skills 2>/dev/null)" ]; then
    for skill_dir in "$SCRIPT_DIR/skills"/*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            create_symlink "$skill_dir" "$CLAUDE_CONFIG_DIR/skills/$skill_name" "$skill_name"
            ((skill_count++))
        fi
    done
else
    echo -e "  ${YELLOW}No skills found to install${NC}"
fi

# Install SessionStart hook
echo ""
echo -e "${BLUE}→${NC} Installing SessionStart hook..."
hook_installed=false

if [ -f "$SCRIPT_DIR/hooks/session-start-hook.sh" ]; then
    SETTINGS_FILE="$CLAUDE_CONFIG_DIR/settings.json"
    HOOK_PATH="$SCRIPT_DIR/hooks/session-start-hook.sh"

    # Create settings.json if it doesn't exist
    if [ ! -f "$SETTINGS_FILE" ]; then
        echo '{}' > "$SETTINGS_FILE"
    fi

    # Use Python to merge the hook configuration
    python3 <<EOF
import json
import sys

settings_file = "$SETTINGS_FILE"
hook_path = "$HOOK_PATH"

try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
except:
    settings = {}

# Ensure hooks object exists
if 'hooks' not in settings:
    settings['hooks'] = {}

# Ensure SessionStart array exists
if 'SessionStart' not in settings['hooks']:
    settings['hooks']['SessionStart'] = []

# Check if our hook already exists
hook_exists = False
for hook_group in settings['hooks']['SessionStart']:
    if 'hooks' in hook_group:
        for hook in hook_group['hooks']:
            if hook.get('command') == hook_path:
                hook_exists = True
                break

# Add our hook if it doesn't exist
if not hook_exists:
    settings['hooks']['SessionStart'].append({
        "hooks": [{
            "type": "command",
            "command": hook_path
        }]
    })

# Write back to file
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("success")
EOF

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} SessionStart hook installed"
        hook_installed=true
    else
        echo -e "  ${RED}✗${NC} Failed to install SessionStart hook"
    fi
else
    echo -e "  ${YELLOW}No hook script found${NC}"
fi

# Summary
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Installation Complete!        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Installed:${NC}"
echo -e "  • $agent_count sub-agent(s)"
echo -e "  • $skill_count skill(s)"
if [ "$hook_installed" = true ]; then
    echo -e "  • SessionStart hook"
fi
echo ""
echo -e "${BLUE}Configuration location:${NC} $CLAUDE_CONFIG_DIR"
echo ""
echo -e "${YELLOW}Note:${NC} Changes will be available in your next Claude Code session."
echo -e "Run ${GREEN}claude /agents${NC} to see your installed sub-agents."
echo ""
if [ "$hook_installed" = true ]; then
    echo -e "${GREEN}✨ Session initialization enabled!${NC}"
    echo -e "   Claude will now automatically load working memory at session start."
    echo ""
fi
