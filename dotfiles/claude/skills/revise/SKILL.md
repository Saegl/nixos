---
name: revise
description: Revise prose (markdown, docs, code comments) one approval-gated edit at a time.
disable-model-invocation: true
---

## Target

A file path, or a named section of one. If the target is unclear, ask which text.

## First pass

Apply grammar and typo fixes directly, then say briefly what you fixed.
After that, never edit without user approval.

## Rounds

Suggest one improvement, idea, or structure change via AskUserQuestion.

- An improvement is a few words added or cut.
- An idea is a larger change that becomes improvements in later rounds.
- A structure change resplits a sentence, breaks or merges blocks, or reorders so the point lands first.

Raise the biggest problem first; leave nitpicks for late rounds.
Every round, hunt for redundant or decorative passages to cut.

On approval, make the edit or adopt the idea; on skip, drop the suggestion for good.
Either way, open the next round. Don't summarize.
If the user replies with anything but a choice, answer or adjust, then re-ask the round.
End when the text is genuinely done.

## Asking

Lead the question with the kind of change, then the suggestion.
Name the section or line it touches.
Set `header` to the round number.
Pass `multiSelect: false`; `true` disables the preview pane.
The options are apply, skip, or stop, each with a one-line `description`.
Put the exact before and after lines in the apply option's `preview` field.
Cap the preview at 12 lines, since it doesn't scroll.

## Style

Preserve the author's meaning and voice. Don't smooth text into generic prose.
Never introduce em dashes. Rewrite around them, or use a colon.
