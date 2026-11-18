# Where to put what you learn along the way

**What you learn yourself goes to auto memory, not to `CLAUDE.md`.** A build command, a
non-obvious pitfall, where things live, a correction I made mid-conversation. Memory lives in
`~/.claude/projects/<repo>/memory/`, is keyed by git repository (so it is shared by all
worktrees of one project), stays out of the project's git and needs no commit.
This is the main route: nine edits out of ten should go here.

**The project's `CLAUDE.md` holds only what I have confirmed.** Conventions, architecture,
"always do X". If you think a rule is ready to move from memory to `CLAUDE.md`, propose it;
don't move it silently.

The harness lives in two roots. **Tooling** (git): `link.sh`, this file, project templates;
its path is the target of the `~/.claude/CLAUDE.md` symlink. **Data** (no git): the
`$CLAUDE_DATA` directory, `~/Documents/claude-config` by default: per-project harness and
wiki, memory, per-project decision log. Below, `<data>` is the data root.

The project's `CLAUDE.md` is a symlink to `<data>/projects/<project>/CLAUDE.md` (syncing data
between machines, if any, is not your concern). Edit it directly; don't ask permission for
the write itself, since the directory is listed in `permissions.additionalDirectories`. It
needs no commit and is not versioned in git.

**The history of a specific task goes to the task wiki, not to memory.** What was asked,
what was done and why, what the pitfalls were and what is left: that is the task document
(see the section below), updated with the `/save-task-context` command.

**Decisions about the harness itself go to the decision log, not to project memory.** Why
an agent, skill, hook or script exists, why a given model/effort, what was rejected, when it
changed: `decisions/` (rules are in its `CLAUDE.md`). There are two logs: tooling decisions
(`link.sh`, this file, templates) go to the tooling's `decisions/`, decisions about a
specific project's harness go to `<data>/decisions/`. When you change the harness, record
the decision in the same session, without asking. Asked "why do we have X", check
`decisions/index.md` in both first.

# Task by number: read its document first

If the project has a task wiki (`<data>/projects/<project>/tasks/`), a task number in a
message (`PROJ-123`, "123") is the signal to read `tasks/pages/<number>.md` first, not git
and code. If no number is given ("that task about the empty profile screen"), find the
document with `grep -ri` over `tasks/index.md` (it holds the ticket title and keywords),
and if that finds nothing, over `tasks/pages/`.

- A question about "what, when, why we did it" is answered from the document; I go to git
  and code only if the document has no answer.
- Taking a task into work (new, rework after QA, continuation): first check whether there
  is already a document for it and for related tasks.
- The document says what was done and why as of the date it was written; the code says what
  is there now. If they disagree, the code wins, and I update the document.

The document's schema and format are in `tasks/CLAUDE.md`. The document is created and
updated by the `/save-task-context` command, which you run at the end of a session.

# Project wiki first, then code

If the project has a local wiki (`<data>/projects/<project>/wiki/`), read it **first**:
before Grep/Glob/Read over the repository, before a plan, and before asking me "where do
you keep X".

Order at the start of every task:

1. Read `wiki/index.md`, the page catalog.
2. Read the relevant `wiki/pages/<slug>.md` in full.
3. Only then go to the code, already knowing where to look.

The trigger is **not** "an architecture question": tasks don't describe themselves that
way, and the rule never fires. The trigger is simple: *I'm about to dig into an unfamiliar
part of the project*. "Add functionality to feature X", "fix Y in section Z", "how does W
work here" all count.

**No wiki page on the topic is not a dead end, it's work.** Figure things out from the code
as usual, then add what you learned to the wiki (the ingest operation, rules in
`wiki/CLAUDE.md`). The point of the wiki is that it compounds: what was figured out today
doesn't have to be figured out again next session. Don't ask permission to edit the wiki;
it's outside git and needs no commit.

The wiki doesn't override the next rule, it comes before it: a page says WHERE to look and
which pitfalls are already known; code, design and API confirm WHAT is there now. If they
disagree, the code wins, and you fix the page.

# Before implementing, check the source of truth

Don't plan or write code from memory or guesses. First open the actual source of truth and
confirm the specifics against it:

- **UI from a design**: open the design itself (Figma MCP: `get_design_context`,
  `get_screenshot`, `get_variable_defs`) instead of describing it "the way it usually is".
- **Working with an API**: look at a real response (sample JSON, proxy override, existing
  data class/mapper) instead of inventing fields and flags. I've caught you inventing
  nonexistent response fields and mappers for them.
- **Code following a pattern**: open the reference class / similar implementation in the
  codebase.

Order: look at the source → show me what you found → propose a minimal plan → implement.
Not the other way around.

# Scope discipline

Do exactly what was asked, and don't inflate the task:

- No "while I'm at it": portability, git-root autodetection, auto-installing anything,
  extra tooling/dependencies only on explicit request.
- If you think extra scope is needed, **ask first**, then do it.
- Keep the diff minimal and on topic; a small verified commit beats a broad one.

# Personal rules

Personal things that don't belong in public tooling go in `<data>/home/CLAUDE.md`;
`link.sh --home` links it to `~/.claude/CLAUDE.personal.md`, and it's pulled in here by an
import. No file means an empty import.

@~/.claude/CLAUDE.personal.md
