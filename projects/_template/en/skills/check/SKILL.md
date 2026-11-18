---
name: check
description: Check the current diff before manual testing of a feature — verification (build/tests) and a deep code review run in parallel.
disable-model-invocation: true
---

The user asked to check the current work before manual testing. Run the following in parallel, in one message with two Agent tool calls:

1. The `verifier` subagent — on the modules changed in the current diff (build → tests, using the commands from the Commands section of the project's `CLAUDE.md`). Don't run lint here — it's only needed before a commit. Regression mutations are not part of `/check`: if the task needs them, offer a separate `regression-checker` run after a green result.
2. The `reviewer` subagent — on the diff of the current changes (`git diff`/`git diff HEAD`, depending on what is already committed).

Wait for both results, then combine them into one answer:
- Verification status (what passed, what didn't, with error details).
- Review findings (file, line, gist, failure scenario), sorted by severity.

If the review found problems that need code changes, offer to fix them, but don't fix them yourself without the user's confirmation unless they are small, targeted fixes. Don't run lint after the fixes yourself: it runs once, when the user asks for a commit.
