---
name: explainer
description: Explain a topic as one long, self-contained HTML page with diagrams, demos, and a quiz, tailored to me.
disable-model-invocation: true
---

Make me a rich, interactive explanation of the specified topic.

I want to really understand the topic, to grok it, not to skim a summary. Length is not a cost: there is no page
limit, no publisher and no deadline, and I'm willing to work through a long page. So don't compress. Spell out every
intermediate step instead of writing "it's easy to see" or "after some algebra". Take detours into adjacent topics when
they make the main one click, and say up front that it's a detour and why it's worth it. When in doubt between shorter
and clearer, choose clearer.

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
- Prerequisites. Before writing, list the specific prerequisites the topic leans on (e.g. "matrix multiplication",
  "derivatives of compositions", "Bayes' rule") and ask me how well I know each one, so you can pick the starting point.
  The background in "Target audience" is a general average and can be off for any particular subtopic. Whatever I say
  is weak or missing gets built from the ground up at the start of the page, with its own practice problems, instead of
  being assumed. Separately, ask about scope: which neighbouring topics to include and how far to go.
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
- Quiz (preferred). A final mixed review over the whole page, on top of the inline practice problems.
- Homework (preferred). Larger open-ended problems, ideally ones that need code.
- Alternatives.
- Extensions.
- History.
- Further reading.

## Practice problems throughout

Don't save all the questions for the end. After every section that introduces something new, stop and give me one to
three problems that check I actually got it before moving on: predict an output, trace an algorithm by hand on a small
input, find the bug, compute a value, prove a small claim, or extend the idea to a slightly different case. Mix easy
recall with problems that need real thought, and label each with a rough difficulty.

Every problem has a full worked solution hidden in a collapsed block, so I can try first and check after:

```html
<details class="solution">
  <summary>Solution</summary>
  <p>Step-by-step reasoning, not just the final answer...</p>
</details>
```

Solutions show the reasoning, not only the answer, and mention the common wrong answer and why it's wrong when there
is one. For a problem with a hint worth giving, add a separate `<details><summary>Hint</summary>` before the solution.

## Code

- Prefer modern Python (3.12+) with full type annotations: `list[int]`, `dict[str, Node]`, `X | None`, dataclasses,
  `match` where it reads well. Use another language when it suits the topic better (C for memory layout, Rust for
  ownership, SQL for queries, JavaScript for in-page demos, etc.) and say why.
- Use descriptive names everywhere: `text`, `pattern_index`, `apple_count`, `visited_nodes`, not `t`, `i`, `x`, `vis`.
  The same goes for worked examples: concrete, meaningful values (apples, users, words) instead of abstract letters.
  In formulas, short symbols are fine, but define each one in words where it first appears, and keep the code and the
  formula visibly connected (e.g. "here \(n\) is `len(text)`").
- Code should be complete and runnable, not fragments with `...`, unless it's clearly marked as a sketch.
  Show the output of running it next to the code.

## Output

- A single HTML file with inline CSS and JavaScript; KaTeX from jsDelivr is the only external dependency.
- One long page with section headers and a table of contents. Don't use tabs for the top-level structure.
- Save it outside any code repo, prefixed with today's date so files sort by time: `~/explainers/2026-01-12-<slug>.html`.

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

## Accuracy and references

- Use web search to check facts you're not sure about: definitions, history, dates, attributions, complexity bounds,
  current API details. Don't invent citations.
- Link the primary sources (papers, specs, official docs) and the best secondary ones in Further reading, with a
  sentence on what each is good for.

## Verification

- Run every code block with the interpreter or compiler available in the environment (check what's installed, e.g.
  `python3`, `gcc`, `rustc`, `node`; use `nix shell` / `uv run` for anything missing) and paste the real output, never
  an imagined one. Type-check Python with `mypy` or `pyright` when available. Fix anything that fails before delivering.
- Check the worked solutions to practice problems by computing them in code where possible.
- Interactive demos and simulations: run them (e.g. headless Chrome `--dump-dom`) and confirm they show what the text claims.
- Before delivering, screenshot the whole page and look at every figure. Fix overlaps, clipping and anything that
  doesn't read as a diagram. `--screenshot` captures only the window, so make the window taller than the page, then
  slice the image into screen-sized parts and view each one:

  ```sh
  sed 's/<details/<details open/g' page.html > shots/page-open.html   # expand solutions so they get checked too
  google-chrome --headless=new --hide-scrollbars --window-size=1280,30000 \
    --screenshot=shots/full.png file://$PWD/shots/page-open.html
  magick shots/full.png -crop 1280x2000 +repage shots/part-%02d.png
  ```

  If the last part isn't blank, the page is longer than the window: increase the height and retake it. Use the
  scratchpad for these files, not `~/explainers`.
