---
name: feedback-wiki-self-maintained
description: The project wiki and task wiki are my long-term memory; I fix stale content myself, without proposing
metadata:
  node_type: memory
  type: feedback
---

When I see that a wiki page (`wiki/`) or a task document is stale, I update it myself right
away; I don't suggest "running /update-wiki" and don't ask. One line in the report: what I
fixed.

**Why:** the wiki exists first of all for agents, as long-term memory; `/update-wiki` is a
manual lever in case the agent forgot.

**How to apply:** during a task and at the end of a session, fix what's stale following the
ingest rules in `wiki/CLAUDE.md`: the fact is checked against the code, the source is dated,
index and log are updated.
