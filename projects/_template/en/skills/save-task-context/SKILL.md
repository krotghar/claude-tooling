---
name: save-task-context
description: Saves the session context to the task wiki — creates or extends the task document (problem statement, outcome, decisions and why, pitfalls, what's left, verification, timeline), updates index.md and log.md, lints links. Use at the end of a session on a numbered task or when asked to save the task context.
argument-hint: "[optional: task number, if it isn't clear from the conversation and the branch]"
---

The user asks to save the session context to the task wiki. Argument (if any): $ARGUMENTS

The task wiki lives **outside the git repository**, at an absolute path:
`<DataRoot>/projects/<Project>/tasks/`
(`CLAUDE.md` — schema and document format, `index.md` — catalog, `log.md` — log,
`<number or kebab-topic>/<same name>.md` — documents, next to them — the task's
working artifacts). Don't create anything inside the project repository and
don't offer to commit it.

## Order

1. **Identify the task.** The number comes from the argument, otherwise from the
   conversation, otherwise from the branch (`git branch --show-current` in the session's
   worktree). If the session covered several tasks — one document per task. Can't find the
   number — ask, don't make it up.
2. **Read `tasks/CLAUDE.md`** (the format comes from there) and the task document
   (`<number or kebab-topic>/<same name>.md`) if it already exists — then you
   extend it rather than rewrite it. Look into
   `index.md`: are there documents on related tasks worth linking to?
3. **Gather material from the session** — this is the main source: the problem statement
   and clarifications, decisions with reasons and rejected options, the user's decisions
   (on the review, on scope), pitfalls, the session's own mistakes, what's not done and
   not verified.
4. **Check specifics against the source**, not memory: class, function and flag names,
   paths — against the code. Tracking commits, push and PR/MR isn't required: the user
   usually handles git themselves (see the schema, "Git — optional"). A hash at hand can
   be recorded. Check the branch with `git` only if it matters for the work: for
   example, it sits on top of another task and needs a rebase. Decisions and the "why"
   can't be checked anywhere — that's exactly what we record.
5. **Write the document** following the schema's format:
   - new — all sections; an empty section — "—"; the ticket title — verbatim;
     "Keywords" — one line per the schema's rule;
   - existing — a line in "Timeline", update the header (status with date),
     "Outcome", "Decisions", "Pitfalls", "Remaining" (strike out closed items with a date
     rather than deleting them), "Verification", "Sources".
6. **Update `index.md`** — the task's line (newest on top; for an existing one, fix the
   status and dates; keywords are the same as in the document header, extend them if the
   task has grown) — and **append an entry to the end of `log.md`**:
   `## [YYYY-MM-DD] save | <task number> <title verbatim>` + 1–5 lines on what was
   added.
7. **Run the link lint** (script below) and fix everything it finds.
8. **Report briefly**: which document was created or updated and what went into it.
   If along the way you learned something about how the project works that holds beyond
   this task, or a wiki page turned out to be outdated — add it to the wiki yourself
   following the `update-wiki` skill's procedure (don't offer or ask), and don't copy it
   into the task document. In the report — one line on which pages were updated.

## What to write

- **Why, not just what.** The "what" can be recovered from git, the "why" can't. A
  decision gets its reason and the rejected options.
- **The user's decisions** — precise in meaning: "review item 3 we skip — the design has
  no line there", "commit without Co-Authored-By".
- **Your own mistakes and inaccuracies.** If you said something wrong in the chat or did
  something unnecessary — record how it actually is.
- **Pitfalls concretely:** symptom → cause → how it was worked around.
- **State with a date:** status by code and checks, what's verified and what isn't.
  Commits/PR — optional; no "not committed" status and no "commit/push" items in
  "Remaining".

## What not to write

- Code listings and diffs — only locations (module, class, function).
- Knowledge about how the project works — that's `wiki/`; in the document, a `[[slug]]`
  link.
- A retelling of the conversation — only the outcome of the discussion.
- Secrets, personal data, sensitive ticket contents.

## Link lint

```bash
cd <DataRoot>/projects/<Project> && scripts/lint_links.sh tasks
```

The lint doesn't read `tasks/CLAUDE.md`: the links in the format template are placeholders.

## Neighbouring routes

- How the project works (modules, patterns, component pitfalls) → the wiki, edited on your own following the `update-wiki` procedure.
- About me and how to work with me (feedback, preferences) → auto-memory
  (`~/.claude/projects/<repo>/memory/`).
