---
name: restructure
description: Find refactoring opportunities in a target - a better overall approach, wrong or missing abstractions, code smells, naming and style issues - ranked by how much cleaner and shorter the code gets. Reports only; applies nothing without approval.
disable-model-invocation: true
---

# Restructure

Find changes that make the code cleaner and shorter, from renames up to replacing the whole approach.

## Target

`/restructure [target]` — a file, module, or directory. Nothing means the directory most touched in recent commits; say which you picked. Never the whole repo of a large project unless asked.

## Explore

Read the whole target, not excerpts. Follow callers and callees far enough to know how each piece is actually used: a smell is only real if the usage proves it. Check `git log` on hot files — code that keeps changing together belongs together.

## What to look for

Wrong abstractions:

- abstraction with one implementation and no realistic second — inline it
- base class or helper grown flags/params to serve callers that diverged — split it back, duplication is cheaper
- wrapper that only forwards calls — delete the layer
- config or strategy object for a choice that never varies
- the same concept modelled twice under different names

Missing abstractions:

- repeated shape across 3+ sites (not 2) — extract once
- parallel `if`/`switch` on the same type or tag in several places — one table, map, or polymorphic dispatch
- data clumps: the same params travel together everywhere — make them one type
- primitives standing in for a domain idea (stringly-typed states, magic tuples)

Misplaced responsibility:

- feature envy: a function mostly reads another module's data — move it there
- shotgun surgery: one change needs edits in many files — pull it together
- god module/function doing unrelated jobs — split on the seams
- layering violations and circular imports

Also: long parameter lists, boolean params that switch behavior, state that could be derived instead of stored, and error handling duplicated at every call site.

Style and naming:

- names that mislead, drift from what the code now does, or differ for the same thing
- inconsistent idioms within the target
- style nits worth fixing — keep them brief and group them together

Don't propose speculative "might need to scale" rewrites, or new layers unless they delete more than they add.

## Different approach

Step back from the code and state in one sentence what it's trying to achieve. Then ask whether a whole different approach would do it better:

- a library, stdlib feature, or platform built-in that already solves it
- a different data model or representation that makes the logic fall out
- declarative instead of imperative (a table, schema, config, query) or the reverse
- a different algorithm, or moving the work elsewhere (build time, database, the caller)
- dropping the feature's hard part because the requirement behind it doesn't hold

Propose one only if it's clearly better, not just different. Name its costs: migration, dependencies, what gets harder.

## Output

Lead with the different approach if you found one: the goal sentence, the alternative, a sketch, what it deletes, and its costs.

Then rank findings by payoff: lines removed, concepts removed, and future changes made local. For each:

- **Title** and smell name
- **Where**: `file:line` anchors for every site involved
- **Problem**: two sentences on why the current shape hurts, grounded in how it's used
- **Change**: the restructuring, with a short before/after sketch when the shape isn't obvious
- **Estimate**: rough net line delta and risk (behavior touched, public API, test coverage)

Cap at the ten best, then list style and naming nits compactly after them. Mention how many weaker findings you dropped. If the code is already well-shaped, say so — never pad.

End by asking which to apply. When applying, do one finding at a time, keep behavior identical, run tests/typecheck after each, and report `git diff --shortstat`.
