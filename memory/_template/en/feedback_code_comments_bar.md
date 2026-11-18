---
name: feedback-code-comments-bar
description: A high bar for code comments — by default, no comment is written
metadata:
  node_type: memory
  type: feedback
---

Don't write code comments by default. A comment is justified only when a competent reader
really couldn't figure things out without it: a non-obvious bug workaround, an external
constraint, a reason that isn't in the code. "Good to know", "the order here is
non-obvious", restating the code — these don't pass.

**Why:** a comment that restates the code goes stale, drifts from it, and makes the line
look more complicated than it is. It doesn't work as protection against regressions.

**How to apply:** before writing a comment, check that the reader really couldn't figure it
out without it. A subagent reviewer's approval doesn't confirm the bar is met. Comment
language follows the project's convention. Related: [[feedback-no-explanatory-comments-in-review]].
