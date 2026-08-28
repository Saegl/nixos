---
name: tidy
description: Tighten existing code without changing behavior - delete comments that restate the code, cut the rest to two sentences, refactor for brevity, land a net-negative diff. Use when asked to tidy, trim, tighten, declutter, de-comment, or clean up code, or after a draft lands. Optional target - paths, a directory, `staged`, or a commit range.
---

# Tidy

Make the code shorter and more obvious. Behavior must not change.

## Scope

`/tidy [target]` — paths or globs, a directory, `staged`, a commit range, or nothing for the working-tree diff. A named file is tidied whole; a diff target confines you to the lines it touched.

Never the whole repo unless asked outright. Never generated files, vendored deps, or license headers.

## Comments

Delete comments an average programmer doesn't need:

- restates the next line (`# increment counter`)
- section banners, decorative rules
- changelog, attribution, ticket prose
- commented-out code
- docstrings that repeat the signature

Keep why, not what — non-obvious choices, outside constraints, workarounds (keep the link), warnings that prevent a real mistake. **Two sentences max.** Needs more? The code is the problem: extract, split, rename until the comment fits or disappears.

Directive comments are code. Never delete `# noqa`, `# type: ignore`, `// eslint-disable-*`, `#[allow(...)]`, `//go:build`, pragmas, shebangs.

## Code

Prefer, in order: delete it, inline it, name it.

- dead code, unreachable branches, unused imports/params/vars — delete
- early return over nested `if`
- duplicated branches, near-identical helpers — collapse
- single-use vars whose name adds nothing — inline
- hand-rolled loops the stdlib expresses — replace
- functions whose comments mark sections — split at the marks

Terse, not golfed: a one-liner needing a second read is worse than the three lines it replaced. Match the file's idiom and naming.

Ask first: public API renames, dependency changes, new abstraction layers, behavior "improvements", performance rewrites.

## Finish

1. Run tests, typecheck, linter. Say so if the project has none.
2. `git diff --shortstat` — deletions must exceed insertions, or say what grew and why.
3. Report the net delta and any call a reviewer might dispute.
