---
name: reflect
description: End-of-task retrospective. Only run when the user types /reflect.
disable-model-invocation: true
---
Review this session and report:
1. Friction: wrong assumptions, dead ends, repeated failed attempts, and their causes.
2. Misleading sources: CLAUDE.md lines, comments, docs, or names that were stale or pointed the wrong way.
3. Design smells: code that was harder to change than the task warranted.
4. Recurrence: read .claude/reflections.md and flag anything that appeared before.

Propose fixes: edit or delete stale CLAUDE.md entries (don't just append), and suggest code changes for design issues. Ask before applying anything.
Finally, append a short dated summary to .claude/reflections.md.
