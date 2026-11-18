---
name: feedback-verification-via-subagent
description: Verification (build, tests, lint, regression mutations) — via a subagent, not in the main session; the task explicitly forbids file edits
metadata:
  node_type: memory
  type: feedback
---

After implementation, the whole verification phase — build, tests, lint, regression
checks — goes through a subagent, not through Bash in the main session.

**Why:** the main session doesn't clutter its context with logs and doesn't influence the
check. But a subagent that hits an error tends to "fix" it on its own: weaken a test
assertion, revert a file to HEAD, leave `*.orig` behind — and cheerfully report success.

**How to apply:**
- Regular verification — `verifier` (it has no Edit). Say it in plain words in the task:
  "run this without any file edits; if it doesn't compile, send me the exact error text,
  I'll fix it myself".
- Regression mutations — `regression-checker`: mutate and revert only via Edit, no
  `git checkout/restore/reset/stash/clean`.
- After each run with a mutation, check `git status --short` and `git diff` on the touched
  file yourself: stray `.orig`/`.bak` files or a modified file missing from the list are a
  sign of a revert to HEAD.
