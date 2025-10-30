# Kairun Session Initialization

🔧 **SESSION START PROTOCOL**

Before responding to the user, you MUST:

1. **Load Working Memory**: Use the `kairun-working-memory-manager` agent to check if `.kairun/working-memory.md` exists and load context from it
   - DO NOT use the Read tool directly on the working memory file
   - Let the specialized agent handle all working memory operations
   - This provides context about previous work, decisions, and discoveries

2. **Never skip this step**: Even if the user's request seems simple, the working memory may contain critical context that affects how you should approach the task

## Why This Matters

The working memory contains:
- Current tasks and their status
- Architectural decisions made in previous sessions
- Key discoveries about the codebase
- Next steps that were planned
- Open questions and blockers

Without loading this context, you may:
- Duplicate work that was already done
- Make decisions that contradict previous choices
- Miss important context about the project
- Break established patterns

## Example Flow

```
User: "Let's add a new API endpoint for user profiles"

✅ CORRECT:
1. Invoke kairun-working-memory-manager to load context
2. Discover from memory that authentication was added last session
3. Design endpoint to integrate with existing auth system
4. After completing work, invoke working-memory-manager to record the new endpoint

❌ INCORRECT:
1. Start implementing endpoint immediately
2. Miss that auth system was already added
3. Create duplicate or incompatible implementation
```

---

**Remember**: The working memory is your bridge to previous sessions. Always load it first.
