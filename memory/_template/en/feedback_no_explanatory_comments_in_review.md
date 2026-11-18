---
name: feedback-no-explanatory-comments-in-review
description: In code review, don't raise "add an explanatory comment" or "document the contract in the interface docs" as findings
metadata:
  node_type: memory
  type: feedback
---

In code review, don't suggest explanatory comments on non-obvious lines or contract docs on
interfaces as findings.

**Why:** the regression such a comment "protects" against doesn't happen in practice, and
hardly anyone reads an interface's contract docs — the implementation arrives with a bug
anyway. A comment doesn't work as a safeguard, and the finding makes the review longer.

**How to apply:** in review, keep findings that change the code or catch a real defect:
logic, lifecycle, duplication, leaks, style per `CLAUDE.md`. The `reviewer` agent already
knows this; the memory is for reviews done without it. See [[feedback-code-comments-bar]].
