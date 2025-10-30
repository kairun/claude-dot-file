#!/bin/bash

# Claude Code Config Uninstaller
# This script removes symlinked agents and skills from your global Claude Code configuration

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

echo -e "${RED}╔════════════════════════════════════════╗${NC}"
echo -e "${RED}║  Claude Code Configuration Uninstaller ║${NC}"
echo -e "${RED}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if ~/.claude directory exists
if [ ! -d "$CLAUDE_CONFIG_DIR" ]; then
    echo -e "${RED}Error: ~/.claude directory not found${NC}"
    echo -e "${YELLOW}Nothing to uninstall.${NC}"
    exit 0
fi

# Function to remove symlink safely
remove_symlink() {
    local target=$1
    local name=$2

    if [ -L "$target" ]; then
        rm "$target"
        echo -e "  ${GREEN}✓${NC} Removed $name"
        return 0
    elif [ -e "$target" ]; then
        echo -e "  ${YELLOW}⊘${NC} $name (exists but not a symlink, skipping)"
        return 1
    else
        echo -e "  ${YELLOW}⊘${NC} $name (not found)"
        return 1
    fi
}

# Uninstall agents
echo -e "${BLUE}→${NC} Removing sub-agents..."
agent_count=0
if [ -d "$SCRIPT_DIR/agents" ] && [ "$(ls -A $SCRIPT_DIR/agents 2>/dev/null)" ]; then
    for agent_file in "$SCRIPT_DIR/agents"/*.md; do
        if [ -f "$agent_file" ]; then
            agent_name=$(basename "$agent_file")
            if remove_symlink "$CLAUDE_CONFIG_DIR/agents/$agent_name" "$agent_name"; then
                ((agent_count++))
            fi
        fi
    done
else
    echo -e "  ${YELLOW}No agents found${NC}"
fi

# Uninstall skills
echo ""
echo -e "${BLUE}→${NC} Removing skills..."
skill_count=0
if [ -d "$SCRIPT_DIR/skills" ] && [ "$(ls -A $SCRIPT_DIR/skills 2>/dev/null)" ]; then
    for skill_dir in "$SCRIPT_DIR/skills"/*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            if remove_symlink "$CLAUDE_CONFIG_DIR/skills/$skill_name" "$skill_name"; then
                ((skill_count++))
            fi
        fi
    done
else
    echo -e "  ${YELLOW}No skills found${NC}"
fi

# Summary
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Uninstallation Complete!        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Removed:${NC}"
echo -e "  • $agent_count sub-agent(s)"
echo -e "  • $skill_count skill(s)"
echo ""
echo -e "${YELLOW}Note:${NC} Changes will take effect in your next Claude Code session."
echo ""
