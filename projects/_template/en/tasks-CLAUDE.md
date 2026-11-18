# <Project> Tasks — schema

A wiki of the <Project> project's tasks: one document per task (a tracker ticket,
e.g. `PROJ-123`). The goal is to answer "what was done, when and why" from the
document, without reconstructing it from git and code, and to refer to a task by its number.

A sibling of the project wiki (`../wiki/`), organized the same way but about something else:

| | `wiki/` | `tasks/` |
|---|---|---|
| About | how the project works: modules, patterns, component pitfalls | what was done for a specific task and why exactly that way |
| Unit | topic, `pages/<slug>.md` | task, `pages/<number>.md` |
| State (status, what was verified) | not allowed — goes stale | allowed, always with a date |
| Updated by | `/update-wiki` | `/save-task-context` |

Lives outside the git repository (`<DataRoot>/projects/<Project>/tasks/`,
the tooling data directory, unversioned), not part of `link.sh`, read by
absolute path. The "task number → document first" rule is in the global
`CLAUDE.md` (`~/.claude/CLAUDE.md`), so it works in any worktree.

## Structure

- `pages/<number>.md` — the task document. File name = ticket number, so
  a document is opened directly by number, without `index.md`. Work without a ticket —
  slug `no-ticket-<kebab-topic>`.
- `index.md` — catalog: one line per task (link, ticket title verbatim,
  keywords, status, dates), newest first. Needed when no number is given ("that
  task about the notification settings screen"), and for an overview.
- `log.md` — append-only save log, new entries at the end:
  `## [YYYY-MM-DD] save | <number> <ticket title verbatim>` + what
  was added. Answers "what was done on such-and-such date".

## Search without a number

The file name is just the number, so links don't break and the document opens directly.
To search by words: `grep -ri '<word>' tasks/index.md`: a task's line contains the title and
keywords. If nothing is found in the index, run the same grep over `tasks/pages/`.

**Keywords** — one line, 5–10 comma-separated: how the task would be described in
words without knowing the number (synonyms for the screen or feature, style, remote-config key), plus
the main classes and toggles. The line is identical in `index.md` and in the document header. This
is service data; keep it minimal: not a description, not a retelling.

## Links

`[[<number>]]` — a task document (`tasks/pages/`), `[[slug]]` — a project wiki
page (`wiki/pages/`). The namespaces must not overlap: a task number
(`PROJ-123`, `no-ticket-*`) never matches any wiki slug. A task without a document — plain text, not `[[...]]`, otherwise lint
will report a broken link.

## Document format

````markdown
# <number> <ticket title verbatim, as in the tracker>

One or two sentences: the essence of the task and how it ended as of the last entry.

| | |
|---|---|
| Ticket | <link to the ticket in the tracker> |
| Keywords | <5–10 comma-separated, see "Search without a number"> |
| Status | <in progress / code ready / reviewed / manually verified / postponed / closed> (as of YYYY-MM-DD) |
| Branch | `<task branch>` → `<target branch>` |
| Commits / MR | optional: `<hash>` — <what it contains>; MR, if known |
| Related | [[PROJ-456]] or PROJ-456 as text — how it is related |
| Wiki | [[slug]] |

## Problem statement
What was asked, in your own words. Links: ticket, design mockup (file + node), docs.
Clarifications received along the way — with a date.

## Outcome
What was done: behavior and places in the code (module, key classes/functions), no listings.

## Decisions
Numbered list: what was chosen → why → which alternatives were rejected.
Also deliberate deviations from the mockup/legacy and the user's decisions
("review item 3 won't be done — the mockup has no line there").

## Pitfalls and difficulties
Symptom → cause → workaround. Also mistakes and inaccuracies of the session itself
(including things said in chat that were wrong — and what is actually true).

## Remaining
Debt, unverified items, open questions, follow-up tasks with numbers.
Don't silently delete closed items: mark them `~~item~~ — closed YYYY-MM-DD, by what`.

## Verification
What was verified and how (build, tests, regression, review, manually) — date and result.

## Timeline
- YYYY-MM-DD — what was done in the session, briefly

## Sources
- plan, handoff, mockup, review reports — with a date
````

An empty section — "—", not made-up filler.

## What to write and what not to

- **Why matters more than what.** "What" can be recovered from git, "why" lives only in
  the conversation. Every decision has a reason and rejected alternatives.
- **Git is optional.** The user usually makes commits, pushes, MRs and merges themselves, so
  there's no need to track them. If a hash or MR is known, fill in the "Commits / MR" line;
  if not, the line may be absent. Don't set a status like "not committed/not pushed", and don't add
  "commit/push" items to "Remaining": that goes stale with the very first commit.
  A git fact that affects the work (the branch sits on top of another task, a rebase is needed) is written down.
- **State comes with a date.** Status and what was verified are written with the date
  as of which they hold.
- **Check specifics against the source**, not against session memory: names of classes,
  toggles, paths — from the code.
- **Not a retelling of the conversation**, but the outcome: what was concluded and why.
- **No listings or diffs** — only places in the code.
- **No knowledge about how the project works.** What holds outside this task goes into `wiki/`
  (`/update-wiki`); the document gets a `[[slug]]` link.
- Secrets, personal data, sensitive ticket contents — don't store.

## Operations

- **Save** (`/save-task-context`) — at the end of a session: create or extend the document,
  update its line in `index.md`, append an entry to `log.md`, run the link lint.
  An existing document is extended, not rewritten.
- **Query** — a question about a task: the document by number or by searching `index.md`
  (see "Search without a number"); answer with a link to the document. If the document has no answer — go to git/code and offer
  to add it.
- **Lint** — on request: broken `[[links]]`, documents missing from `index.md`, statuses
  that haven't been updated in a long time.
