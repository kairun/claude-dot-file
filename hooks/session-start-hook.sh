#!/bin/bash
# SessionStart hook for kairun-claude-config
# This hook injects context at session start to ensure working memory is loaded

cat <<'CONTEXT'
🔧 SESSION START - Before responding to the user's request, use the kairun-working-memory-manager agent to check if .kairun/working-memory.md exists and load context from it. DO NOT use the Read tool directly on working memory - always use the specialized agent.

This provides critical context about:
- Previous work and decisions
- Current task status
- Architectural choices made
- Key discoveries and insights
- Next steps and open questions

Without loading this context first, you may duplicate work or make contradictory decisions.
CONTEXT
