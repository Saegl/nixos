---
name: walkthrough
description: Explain a piece of a codebase (a diff, branch or PR, or a file, module or whole system) as one self-contained HTML page with diagrams, real code, demos and a quiz.
disable-model-invocation: true
---

Make me a rich, interactive explanation of the specified piece of code: either a change (diff, branch, PR) or a part
of the existing system (a file, a module, a subsystem, or how one feature works end to end).

After reading it I should be able to review the change or modify the code with confidence. That takes a working
mental model: what the pieces are, how data moves between them, why it is built this way, and where it can break. A
file-by-file summary doesn't give me that, so organise the page around the ideas and the flow, and bring the files in
as evidence.

Scale the page to the target. A thirty-line diff gets a short page; a subsystem gets a long one. Within that size
don't compress: spell out the steps of a flow instead of writing "then it gets processed".

## Before writing

Ask me these in one round, skipping whatever my request already answers:

- Purpose: reviewing a change, about to modify this code, debugging something, or just getting oriented. It decides
  what the page dwells on.
- What I already know about this part of the codebase.
- Scope: which neighbouring code is in, and where to stop.

Then explore before writing a word:

- Read the target and what surrounds it: callers, callees, the types and data it touches, configuration, tests.
- Treat tests as examples of intended behaviour, and `git log`, `git blame` and linked PRs or issues as the record
  of why the code looks the way it does.
- Run the code when the environment allows (tests, a small script, a REPL) and capture real inputs, outputs and
  logs. They become the running example.
- For a change: read the whole diff, the previous version of every function it touches, and the callers of the
  changed code.

Stay read-only. Don't modify the working tree or switch branches; look at other revisions with `git show` and
`git diff`. Don't read existing pages in `~/explainers` for reference: reading them wastes context, and a new page
doesn't need to match them.

## Audience

Just me, Saegl: an experienced programmer with a wide range (parsing, compilers, simulations, backend, frontend,
mobile). Don't explain general programming. Do explain what is specific to this code: its own concepts, names and
conventions, the domain it models, and any library or framework behaviour it relies on that isn't common knowledge.
When the code leans on a deeper topic (an algorithm, a protocol, some math), give a short primer and say that
`/teach` can cover it properly.

## Grounding

- Every claim about behaviour points at the code that makes it true: put `path:line` or the function name next to it.
- Show real code, quoted exactly, with its path and line range as a caption. Pull excerpts out of the files with a
  script instead of retyping them. Trim with clearly marked omissions. A simplified version is fine when it is
  labelled as a sketch, never when it looks like a quote.
- Separate what you verified (read it, ran it) from what you infer (intent, history you couldn't find). Say plainly
  what you couldn't work out, e.g. "I couldn't find where this flag is set".
- Use the codebase's own names for things, and define each project-specific term where it first appears.
- Pick one running example with concrete values and follow it through the whole page.

## Sections

A loose guide, not a template: skip, merge, or reorder to fit the target.

Always:

- Summary. Three to five sentences at the top: what this is, or what changed and why.
- Map. Where the target sits in the system, as a diagram with the target highlighted.
- Background. Only what this target needs. Mark the parts I can skip if I know the area.
- Intuition. The core idea on toy data, before any detail.
- Quiz. Five interactive multiple-choice questions of medium difficulty about behaviour, not trivia: "what happens
  when...", "which component decides...", "what breaks if this line goes away". Clicking an option says whether it
  is right and why, including why the tempting wrong answer is wrong.
- Where to look next. The files worth reading in full, with a sentence on each.

For existing code:

- One input followed end to end, with real values at each step.
- Key data structures and the invariants the code relies on.
- Control flow: entry points, the main path, then the branches and the error paths.
- Design decisions. Why it is built this way and what the alternatives were, from history where it exists.
- Sharp edges. Hidden coupling, ordering and concurrency assumptions, things that look wrong but are intentional,
  and things that look like real bugs (say so).
- How to change it. Where a typical new feature would go and which tests guard the area.

For a change:

- Problem. What was wrong or missing, shown on the running example.
- Before and after. The behaviour side by side on the same input.
- The change, grouped by intent instead of by file, in the order that makes it understandable. Mechanical parts
  (renames, moved code, formatting) get one line each.
- What didn't change but matters: callers that depended on the old behaviour, paths the change doesn't reach.
- Risks and review notes. Edge cases, missing tests, migrations, performance, and the spots I should read myself.
  Be candid: this section is why I read the page before approving.

Where a section sets up something I can predict, ask me to predict it first and hide the answer in a
`<details><summary>Answer</summary>` block.

## Output

- A single HTML file with inline CSS and JavaScript. Libraries may be loaded from a well-known CDN (jsDelivr, cdnjs,
  unpkg, esm.sh, Google Fonts) when they earn their place. Pin exact versions. The delivered page is the one file:
  it opens directly in a browser and needs no other local files.
- One long page with section headers and a table of contents. Don't use tabs for the top-level structure.
- Save it outside any code repo, prefixed with today's date so files sort by time:
  `~/explainers/YYYY-MM-DD-<repo>-<slug>.html`.

## Style

- Write in classic style: start from a concrete question, show the picture before the detail, and let each piece
  arrive when the reader needs it. Transitions between sections should be smooth.
- Use callouts for key concepts, invariants, and important edge cases.

## Visuals

- Dark theme only, looking like a quiet code editor. Background `#1e1f22` (graphite), panels `#2b2d30`, text
  `#d5d7db`, muted text `#8b8f98`, rules `#3c3f44`. Accents: purple `#c9a0ff`, teal `#56c8b8`, orange `#f0a35e`,
  blue `#7fb2f0`; when a page needs more, add colours of similar brightness.
- Fonts from Google Fonts: Source Sans 3 for body text and headings, Source Code Pro for code, citations and
  readouts. Body text is 17-18px. Code is nearly as large: code blocks and readouts at 16px, inline code at 0.92em.
  Never shrink code to fit a long line; let the block scroll sideways instead.
- Layout: left-aligned title, a text column of about 42rem, figures, demos and wide code allowed to run wider than
  the text. Corners rounded by about 6px. Callouts are a panel with a coloured rule down the left side.
- Citations go in the right margin. On a wide window each `path:line` sits in a gutter beside the sentence it
  supports, in small muted monospace with a thin rule on its left; on a narrow one it falls back inline, in
  brackets after the sentence.
- Every code block has a caption bar on top with its `path:line-range`, in the same small monospace.
- Colour is identity. Give each key component (a service, a module, a data structure, a kind of message) one accent
  colour and use it everywhere that component appears: in the map, in other diagrams, in the prose and in demos.
- Pick a small number of diagram families and reuse them. The useful ones for code:
  - a component map with example data written on the arrows;
  - a sequence diagram for who calls whom over time;
  - a state machine for anything with a lifecycle;
  - a layout of a data structure with real values in the boxes;
  - a before and after pair for a change;
  - a very simplified mock of the UI, when the behaviour is visible to a user.
- Don't use ASCII diagrams. Draw diagrams as real graphics: inline SVG for anything with structure (trees, graphs,
  flows), HTML for simple box layouts, HTML lists for lists of things. A tree must be drawn as nodes and edges, never
  as an indented list or text boxes.
- Code blocks: always use `<pre>` tags. Write the code as plain escaped text in `<pre><code class="language-python">`
  and highlight it in the browser with Shiki, loaded as an ES module:
  `import { codeToHtml } from 'https://esm.sh/shiki@4.5.0'`, called with `theme: 'github-dark-dimmed'`. Never hand-write token
  `<span>`s or paste pre-highlighted markup. If you use a custom styled div instead of `<pre>`, it **must** have
  `white-space: pre-wrap` in its CSS, or the browser will collapse all newlines into a single line.
- Changed code: show it as a unified diff (Shiki `lang: 'diff'`) cut down to the hunks that matter, or as before and
  after blocks side by side when the shape of the code changed.
- Formulas, when there are any: LaTeX rendered with KaTeX from jsDelivr (`katex@0.18.10`, with
  `contrib/auto-render.min.js`).

## Interactive demos

- Make a figure interactive when the thing it shows unfolds over time or depends on an input: step, back and play
  controls that walk the running example through the component map and show the state at each step, a toggle
  between before and after for a change, or a small simulation with a slider for the input.
- One idea per demo, placed right where the text needs it, with a caption saying what to try and what to notice.
- The demo must show something sensible before I touch it, and the text around it must still make sense if I never do.
- A demo re-implements the real logic in JavaScript, so it can drift from the code: check its output against what
  the real code produces for the same input.
- Readouts must not jump while a value changes: show a fixed number of decimals in a monospace font and pad to the
  width of the longest value, sign included.

## Verification

- Check every quoted excerpt and every `path:line` against the repository before delivering; a script that looks up
  each excerpt in the file it cites is enough.
- Check claims about runtime behaviour by running tests or a small script where the environment allows. Where it
  doesn't, say in the page that the claim comes from reading the code.
- Check each quiz answer against the code.
- Interactive demos: run them (e.g. headless Chrome `--dump-dom`) and confirm they show what the text claims.
- Before delivering, screenshot the whole page and look at every figure. Fix overlaps, clipping and anything that
  doesn't read as a diagram. `--screenshot` captures only the window, so make the window taller than the page, then
  slice the image into screen-sized parts and view each one:

  ```sh
  sed 's/<details/<details open/g' page.html > shots/page-open.html   # expand hidden answers so they get checked too
  google-chrome --headless=new --hide-scrollbars --window-size=1280,30000 --virtual-time-budget=10000 \
    --screenshot=shots/full.png file://$PWD/shots/page-open.html
  magick shots/full.png -crop 1280x2000 +repage shots/part-%02d.png
  ```

  If the last part isn't blank, the page is longer than the window: increase the height and retake it. Use the
  scratchpad for these files, not `~/explainers`.
