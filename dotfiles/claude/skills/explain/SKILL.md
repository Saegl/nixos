---
name: explain
description: Use when the user asks for a rich explanation of a code change (diff, branch, PR) or of a concept, file, module, or directory. Produces HTML output.
disable-model-invocation: true
---

# Explain

Please make me a rich, interactive explanation of the specified target: either a code change (diff, branch, PR) or a piece of the existing system (a concept, file, module, or directory).

It should have these sections:

- Background: Explain the existing system relevant to the target. (You should broadly explore surrounding code for this.) We don't know how much the reader already knows, so include a deep background for beginners (note that it can be skipped if the reader is already familiar), and then a more narrow background directly relevant to the target.
- Intuition: Explain the core intuition for the change or concept. The focus here is to explain the essence, not the full details. Use concrete examples with toy data. Use figures and diagrams liberally.
- Code: Do a high-level walkthrough of the changed code, or of the code that embodies the concept. Group/order it in an understandable way.
- Quiz: Come up with five questions that test the reader's knowledge of the target. This should be medium difficulty, difficult enough that you actually need to understand the substance of the target to answer them, but not gotchas. The goal is to help the reader make sure that they've actually understood. These should be presented as interactive multiple-choice questions, and when the user clicks, it tells them whether they were correct and gives feedback.

Format:

- Output a single self-contained HTML file which includes CSS and JavaScript. Make the whole thing one long page with section headers and a table of contents. Don't use tabs for the top-level structure. Put the file in a global place on my computer outside of the code repo, and make sure the filename always starts with today's date in `YYYY-MM-DD-` format, because it helps keep the files time-sorted and out of version control. For example: /tmp/2026-01-12-explanation-<slug>.html
- Please write with the clarity and flow of Martin Kleppmann, making it engaging and written in classic style. Transitions between sections should be smooth.
- Some tips on diagrams. Ideally, you should pick a small number of diagram families that can be reused throughout the explanation to explain various cases. Some useful kinds of diagrams:
  - A very simplified version of the UI that the user sees in the app, to explain UI behavior or changes.
  - A system diagram showing data flow or communication between components. Make sure to include example data here!
- Don't use ASCII diagrams. Draw diagrams as real graphics: inline SVG for anything with structure (trees, graphs, flows), HTML for simple box layouts, HTML lists for lists of things. A tree must be drawn as nodes and edges, never as an indented list or text boxes.
- Formulas: use MathML, not styled text. Chrome doesn't stretch MathML underbraces; draw braces with CSS if needed.
- Code blocks: always use `<pre>` tags, and highlight them with Pygments ahead of time (`HtmlFormatter(nowrap=True)`, token colours as CSS variables so they follow the page theme). No highlighting via CDN or by hand.
  If you use a custom styled div instead of `<pre>`, it **must** have `white-space: pre-wrap` in its CSS,
  or the browser will collapse all newlines into a single line.
- Interactive demos and simulations: run them (e.g. headless Chrome `--dump-dom`) and confirm they actually show what the text claims about them.
- Before delivering, screenshot the page with headless Chrome (`google-chrome --headless=new --screenshot`) and look at every figure. Fix overlaps, clipping and anything that doesn't read as a diagram.
- Use callouts for key concepts or definitions, important edge cases, etc.
