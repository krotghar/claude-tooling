# <Project> Wiki — schema

A personal knowledge base for the <Project> project, separate from the project
`CLAUDE.md` (symlinked into a specific worktree) and from auto-memory
(`~/.claude/projects/.../memory/MEMORY.md`). Methodology — Karpathy's gist on the
LLM wiki (raw sources → wiki → schema, ingest/query/lint operations).

Lives locally outside the git repository (`<DataRoot>/projects/<Project>/wiki/`, the
tooling data directory, unversioned). It is not part of `settings.json`/`link.sh` — it is
not Claude Code configuration but a knowledge base that Claude reads and writes by
absolute path when relevant to the task.

## Three layers

- **Raw sources** (immutable, not duplicated here): the git repository itself
  (code, commit history, MRs), the team's external documentation/wiki, if any,
  the project's `CLAUDE.md`.
- **Wiki** (`pages/*.md` + `index.md`) — what the LLM writes and maintains itself:
  summaries of architectural topics, entity pages for modules/areas,
  concept pages for patterns (DI, navigation, state handling, etc.).
- **Schema** — this file. Changed through explicit discussion, not silently.

## How it differs from auto-memory and the project CLAUDE.md

- `project CLAUDE.md` — confirmed mandatory conventions ("always do X").
- `auto-memory` (`~/.claude/projects/.../memory/`) — what was learned during
  specific conversations: feedback, task context, links to external systems.
  Short, targeted entries, not meant to be a complete picture.
- **This wiki** — a compounding artifact: the more sources are ingested,
  the fuller and more connected the picture of the project's architecture/modules/decisions.
  Unlike memory, it is meant to grow in depth (dozens of pages,
  cross-links), not to be a list of short facts.
- **Task wiki** (`../tasks/`, its own schema `tasks/CLAUDE.md`) — what was done for a
  specific ticket, when and why, with statuses and dates. Only knowledge about how the
  project works that holds outside the task is moved from there into here; the task
  document links to it with `[[slug]]`.

## Structure

- `index.md` — catalog of all wiki pages with a one-line description. Read
  first on a query to find the relevant pages.
- `log.md` — append-only operation log, prefix `## [YYYY-MM-DD] ingest|query|lint | Title`.
- `pages/*.md` — the pages themselves. The file name is the topic's kebab-case slug
  (e.g. `pages/di.md`, `pages/module-structure.md`).

### Page format

```markdown
# Title

Briefly, what the page is about (1-2 sentences).

## <sections as needed>

...

## Sources
- <file/MR/commit/wiki page this was taken from>

## See also
- [[other-page-slug]]
```

## Session workflow

The wiki is read **first**, before Grep/Glob/Read over the repository and before the plan.
The rule is duplicated in the global `CLAUDE.md` so it fires in any chat:

1. `index.md` — the page catalog.
2. The relevant `pages/<slug>.md` in full.
3. The code — already knowing where to look.

The trigger is not "an architecture question" (tasks don't describe themselves that way) but
"I'm about to dig into an unfamiliar part of the project". "Add functionality to
feature X" falls under it: start from the overview page (feature/module map,
if one exists), and from there go to the specific feature's page, if there is one.

No page on the topic is not a dead end but work to do: figure it out from the code → create
a page (ingest). That is the only way the wiki compounds; a session in which something was
figured out and not written down is half wasted.

The wiki does not replace the source of truth: if a page disagrees with the code, the code is
right, and the page must be fixed in the same session.

## Operations

- **Ingest** — a source was added (code file, MR, external wiki page,
  CLAUDE.md section) → read it, extract the essence, write/update
  1+ pages in `pages/`, update `index.md`, append a line to `log.md`.
  Don't rewrite the whole wiki from scratch — make targeted additions/edits to existing
  pages if the topic already exists.
- **Query** — a question about architecture/modules/decision history → find the
  relevant pages via `index.md`, answer with links to the pages
  (and, if the material is new and valuable, file it as an edit/new page).
- **Lint** — on request, go through `pages/`: find contradictions, outdated
  claims (module renamed/removed), orphan pages not linked from
  `index.md`, gaps (topic mentioned but has no page).

## Data scope

Only the project's own architecture/modules/patterns/decision history. Don't store
here: secrets, users' personal data, contents of tickets with
sensitive information.
