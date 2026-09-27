---
name: concepts
description: List the concepts needed to understand a target file, module, or directory, each sized as a 10-30 minute study chunk.
disable-model-invocation: true
---

## Target

A file, module, or directory. If the target is unclear, ask which one.

## Explore

Read the whole target, not excerpts. Follow imports and callers far enough to know what each piece relies on and why it exists.

## What counts as a concept

A concept is one idea the reader must hold to understand the target: a mechanism, an invariant, a protocol, a data flow, a design decision and the problem it solves.

- Name ideas, not files. One concept may span several files; one file may hold several concepts.
- Include prerequisites the target depends on non-trivially (e.g. Redis consumer groups under a queue consumer), marked as prerequisites.
- Skip what an average developer already knows, and generic project plumbing (DI wiring, base classes, exceptions) unless the target uses it in an unusual way.

## Sizing

Each concept takes 10-30 minutes to understand from its code and this explanation.

- Split a concept that would take longer; merge ones that take under 10 minutes into their closest neighbour.
- The count follows from the target: a small file may have one concept, a large directory twenty. Never pad or trim to reach a typical number.

## Output

Order concepts so each one depends only on earlier ones. For each:

- **Name** and estimated minutes
- **Idea**: two or three sentences on what it is and why the target needs it
- **Where**: `file:line` anchors to the code that embodies it
- **Depends on**: earlier concepts it builds on, if any

End with the total estimated time. Then offer to teach any concept in depth.
