---
name: feedback-no-compressed-questions
description: Write questions and decision points for the user in full sentences with context, not in telegraphic style
metadata:
  node_type: memory
  type: feedback
---

Spell out open questions, options and recommendations in full: what this place is in plain
words, what happens there now, what each option would change, what I recommend and why.
Don't relay a subagent's compressed report as scraps of jargon.

**Why:** a question compressed to fragments can't be decided without asking back, so the
words saved turn into an extra round trip.

**How to apply:** each question is its own paragraph: context → current state → options
with consequences → recommendation. Especially when relaying a plan or a subagent's report.
