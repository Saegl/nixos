---
name: explainer
description: Explain a topic as one long, self-contained HTML page with diagrams, demos, and a quiz, tailored to me.
disable-model-invocation: true
---

Make me a rich, interactive explanation of the specified topic.

Before writing, ask me which approach to take: bottom up (build from the basics toward the topic) or top down (start from the big picture, then drill into details).

## Target audience

Just one person: me, Saegl. 25 years old, CS degree.

Math: great knowledge of the basics (sets, functions, basic algebra, logic, a bit of combinatorics).
Less knowledge of calculus, even less of linear algebra.

Programming: 600+ solved problems on LeetCode, great knowledge of the basics, and a wide range across
almost every topic: parsing, compilers, simulations, backend, frontend, mobile.

## Sections

A loose guide, not a template: skip, merge, or reorder sections to fit the topic and the chosen approach.

- Motivation. A concrete scenario where the topic is used.
- Prerequisites. If you're unsure whether I have a prereq, ask me whether to widen or narrow the scope.
- Problem formulation. With one small example.
- Naive solution. Only if the topic is hard and a real naive solution exists.
- Diagnosis. Where the naive approach goes wrong.
- Easier warm-up problem.
- Key insight.
- Core concept.
- Visual walkthrough.
- Algorithm.
- Correctness proof.
- Complexity.
- Pitfalls.
- Summary. Three to five key takeaways or a cheat sheet.
- Quiz (preferred).
- Homework (preferred).
- Alternatives.
- Extensions.
- History.
- Further reading.

## Output

- A single HTML file with inline CSS and JavaScript; KaTeX from jsDelivr is the only external dependency.
- One long page with section headers and a table of contents. Don't use tabs for the top-level structure.
- Save it outside any code repo, prefixed with today's date so files sort by time: `/tmp/2026-01-12-explanation-<slug>.html`.

## Style

- Write in classic style, with the clarity and flow of Martin Kleppmann. Transitions between sections should be smooth.
- Use callouts for key concepts, definitions, and important edge cases.

## Visuals

- Pick a small number of diagram families and reuse them across cases.
- Don't use ASCII diagrams. Draw diagrams as real graphics: inline SVG for anything with structure (trees, graphs, flows), HTML for simple box layouts, HTML lists for lists of things. A tree must be drawn as nodes and edges, never as an indented list or text boxes.
- Formulas: write LaTeX (`\(...\)` inline, `\[...\]` display) and render it with KaTeX from jsDelivr, the one allowed CDN dependency:
  `katex@0.18.10/dist/katex.min.css`, `katex.min.js` and `contrib/auto-render.min.js`, then call `renderMathInElement(document.body)`.
  Never styled text, hand-written MathML, or MathJax.
- Code blocks: always use `<pre>` tags, and highlight them with Pygments ahead of time (`HtmlFormatter(nowrap=True)`, token colours as CSS variables so they follow the page theme). No highlighting via CDN or by hand.
  If you use a custom styled div instead of `<pre>`, it **must** have `white-space: pre-wrap` in its CSS,
  or the browser will collapse all newlines into a single line.

## Verification

- Interactive demos and simulations: run them (e.g. headless Chrome `--dump-dom`) and confirm they show what the text claims.
- Before delivering, screenshot the page with headless Chrome (`google-chrome --headless=new --screenshot`) and look at every figure. Fix overlaps, clipping and anything that doesn't read as a diagram.
