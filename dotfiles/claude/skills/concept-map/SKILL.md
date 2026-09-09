---
name: concept-map
description: Use when the user wants a concept map, mental model, or conceptual overview of a directory, module, or codebase. Produces an interactive HTML graph.
disable-model-invocation: true
---

# Concept Map

Please map the concepts in the specified target so I can hold the whole thing in my head.

## Target

A directory, module, package, or file set. If none is given, ask.
If the target is large, ask which slice to map rather than mapping everything shallowly.

## Explore first

Read the target properly before drawing anything. Follow imports outward far enough to
learn what the module assumes about the rest of the system, then stop at that boundary.
Read tests too: they state the intended behavior more plainly than the implementation does.

## What counts as a concept

A concept is an idea the reader has to hold in their head to work in this code:
a domain entity, a lifecycle or state machine, an invariant, a protocol between parts,
a unit of ownership, a recurring pattern. **Not** one node per file, class, or function.
Several files often collapse into one concept; one file often hides three.

Aim for 15 to 40 nodes. If you have more, you are mapping code structure instead of ideas,
so merge. If you have far fewer, look for the assumptions nobody wrote down.

Group nodes into 3 to 6 clusters and name each cluster. Colour by cluster.

Every node needs a real code anchor, `path/to/file.rs:120`, so the reader can go look.
Never invent a concept the code does not support, and never invent a line number.

## Edges

Edges are labelled with a verb, so that node-verb-node reads as a true sentence:
`Session owns Transcript`, `Compactor rewrites Transcript`, `Tool call blocks Turn`.
Prefer few strong edges over many weak ones. Drop an edge whose label is only "uses"
or "relates to" unless the relation is genuinely the point.

Mark the two or three edges that carry the most surprise, the ones where the code does
something a reader would not have guessed, and let the page highlight them.

## Output

A single self-contained HTML file, CSS and JavaScript inline, no CDN, no network.
Put it outside the repo with today's date first, so files stay time-sorted and out of
version control: `/tmp/2026-01-12-concept-map-<slug>.html`.
When it is written, open it with `xdg-open` and print the path.

The page is a graph plus a detail panel:

- **Graph.** Inline SVG, force-directed. Nodes are rounded rects sized to their label text,
  never bare circles, so labels never collide or need leader lines. Run the simulation
  (all-pairs repulsion, springs on edges, weak pull to centre) for a few hundred ticks on
  load and render the settled result. No perpetual animation. Nodes are draggable and
  re-settle; the canvas pans by drag and zooms by wheel on the `viewBox`.
- **Edge labels** sit on the edge, small, with a background chip so they stay readable
  where lines cross. Direction gets an arrowhead.
- **Hover** a node: it and its neighbours stay lit, everything else dims.
- **Click** a node: the detail panel shows what the concept is in two or three sentences,
  why it exists, its code anchors, and the gotcha or edge case that bites people. Write
  this for someone new to the code but not new to programming.
- **Search box** filters and focuses nodes by name.
- **Legend** of clusters, each toggleable to hide that cluster.
- **"Start here"** list of the 3 to 5 concepts to read first, in order, as the way into
  the map. Put it above or beside the graph, not buried.

Basic responsive styling, so the graph is still usable on a phone.

## Style

Write with the clarity of Martin Kleppmann: plain, concrete, confident. Prefer the
specific noun from the codebase over a generic one. Explain a mechanism rather than
restating a name. Say what is actually true, including where the design is awkward.
