#!/bin/bash
# SessionStart hook for kairun-claude-config
# This hook injects context at session start to ensure working memory is loaded

cat <<'CONTEXT'
🔧 SESSION START - Follow this workflow at the beginning of every session:

1. **Load Context First**: Use the kairun-working-memory-manager agent to load .kairun/working-memory.md (backward-looking: what happened, decisions made, discoveries). Then read .kairun/plans-and-todos.md if it exists (forward-looking: what needs to happen, priorities, roadmap). DO NOT use the Read tool directly on working memory - always use the specialized agent.

This provides critical context about:
- Previous work and decisions
- Current task status and priorities
- Architectural choices made
- Key discoveries and insights
- Planned work and next steps

2. **Update Memory During Work**: Proactively use the kairun-working-memory-manager agent whenever:
- Any code is changed or features implemented
- New information is discovered about the codebase
- Architectural or design decisions are made
- Tasks are completed or bugs are fixed

3. **Review Changes When Requested**: When the user asks for code review, use the kairun-review-orchestrator agent as the PRIMARY entry point. It will coordinate parallel security and code practice reviews.

4. **Check for Serena MCP**: If serena MCP tools are available (check using ListMcpResourcesTool or look for mcp__serena__* tools), use them for semantic code navigation:
- Use find_symbol to locate functions/classes by name instead of Grep
- Use find_referencing_symbols to find where symbols are used
- Use insert_after_symbol for precise code insertion
- These tools are more efficient than reading entire files for large codebases

Without loading context first, you may duplicate work or make contradictory decisions.
CONTEXT
