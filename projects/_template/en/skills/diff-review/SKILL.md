---
name: diff-review
description: Review the current diff (or a given commit/range) right in this session, without a subagent, with the report in a markdown document. Use when asked to "review the diff", "review the changes", "look at what I've done" — and the session was started specifically for the review.
---

The user asks for a code review in this session. The review is done **inline**, not
through a subagent: the session was started for the review, and the context is needed
here, not in a subagent's report.

Run the `reviewer` subagent only if the user explicitly asks for it
(or if the review is part of a bigger task and context needs to be saved).

## What to review

By default — `git diff HEAD` (working tree + index). If the user named a commit, a
range or files — those. If the working tree is clean but the branch has moved away from
the base (`<base>`), review `git diff <base>...HEAD` and say that's what you took.

## Order

1. **The handoff, if there is one.** The user often gives a link to an artifact with a
   handoff document for the task — read it first (`WebFetch`). It contains decisions
   already made and things deliberately left out of scope: without it, half of the
   findings will turn out to be already answered.
2. **The whole diff.** `git diff --stat`, then the diff itself, module by module. Read
   large outputs from the persisted-output files, don't cut them with `head` — a
   truncated diff produces false findings.
3. **Verify claims against the code.** This is the main part, the reason the review is
   done inline. Don't trust either the handoff or your own guess about how the
   neighbouring code works: open it.

   What to check almost always:
   - **Completeness of coverage.** If the task is "do X in all sections", grep for all
     the places where X applies and compare with the list of changed ones. This is
     usually where the most valuable findings are.
   - **Other callers.** The changed method may have other call sites that the new
     behaviour now also affects.
   - **Exhaustive branching** over enums and types from shared code: a new variant must
     be handled in every consumer, not swallowed by a default branch.
   - **When is the object under test created?** If a test changes the input after the
     object has already been created (in shared setup), the test is green for the wrong
     reason.
   - **Order of guards and side effects** (logging, analytics, state writes, the
     response to the client).
   - **Claims that "there are no tests at all"** — check with `find` that the test file
     really doesn't exist rather than living under a different name.
4. **Skills for the kind of code.** If the diff has tests, load `unit-tests`. Check
   against it, not against general notions.
5. **The project wiki.** If the diff touches an unfamiliar area — first
   `<DataRoot>/projects/<Project>/wiki/index.md` and the relevant page, then the code.

## What to look at

The criteria are the same as for the `reviewer` subagent (`.claude/agents/reviewer.md`) —
correctness, regressions, test coverage, readability, conformance to the plan and the
project's `CLAUDE.md`, plus stack-specific rules if they've been added there.
You don't have to read it in full, but for a large diff it's worth it.

## What NOT to raise as findings

- An explanatory comment on a non-obvious line — it doesn't protect against regressions.
- A doc comment with a contract on an interface method — nobody reads that kind of
  documentation.
- Complaints about a style already established in the touched file (for example, test
  block markers `// Arrange/Act/Assert` vs `// Prepare/Do/Check`). New code should read
  like the code around it.
- Pre-existing problems the diff doesn't touch — unless the diff makes them noticeably
  worse. Then say exactly that: "pre-existing, but now it fires".

## Report

The format is in `report-format.md` next to this file. **Read it before writing the
report** and follow it literally: severity scale, verdict, document skeleton, the
mandatory "✅ Checked and confirmed" section.

The report is written to a markdown file in the session scratchpad and sent via
`SendUserFile` with `display: "render"`. In the chat — the verdict in one line and the
list of finding titles.

## After the review

Don't change the code yourself unless asked. Don't run the linter after fixes yourself —
it's only needed before a commit: when the user asks to commit, run it (the command is in
the Commands section of the project's `CLAUDE.md`), fix what it finds, and only then call
`/commit`.
