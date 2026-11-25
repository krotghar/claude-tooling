---
name: tooling-review
description: Review the history of work on a project (session transcripts, commits, memory) and propose improvements to the harness: memories, CLAUDE.md, skills. Only proposes; applies nothing without a "yes". Use on request ("what should we tune in the harness", "tooling review") or on a schedule.
---

# Project harness review

The job is to find where Claude stumbles again and again, or where the user keeps doing the
same thing by hand, and to propose targeted edits. Don't rewrite the whole harness, and
don't change anything without an explicit "yes".

## 0. Where things live

```bash
TOOLING="$(cd "$(dirname "$(readlink ~/.claude/skills/tooling-review)")/../../.." && pwd)"
[ -f "$TOOLING/local.env" ] && . "$TOOLING/local.env"
DATA="${CLAUDE_DATA:-$HOME/Documents/ai-config}"
MAIN="$(git worktree list --porcelain | awk '/^worktree /{sub(/^worktree /, ""); print; exit}')"
PROJ="$(basename "$MAIN")"
KEY="$(echo "$MAIN" | sed 's/[^A-Za-z0-9]/-/g')"
ls "$DATA/projects/$PROJ/reviews/" 2>/dev/null | tail -1   # previous review
```

Transcripts are in `~/.claude/projects/$KEY/*.jsonl` (on Windows the project path has the
form `C:/...` and the key looks like `C--Users-...`). The period runs from the date of the
previous review; the first time, the last 30 days.

## 1. Collection (via a subagent)

Transcripts are large; don't read them in the main session. Give a subagent (Explore or
general-purpose) the task: in the `*.jsonl` files for the period, take only user messages
(`"type":"user"` with text, not tool results) and find:

- **recurring corrections**: the same remark to Claude in two or more sessions
  ("no, not like that", "I already asked you to", "again");
- **recurring manual sequences**: the user asks for the same chain of steps from session
  to session (a skill candidate);
- **skill and agent invocations**: which are used, which never are.

Return per finding: the gist, how many times, session dates, one short quote. Don't quote
secrets, tokens, passwords or personal data.

Meanwhile, yourself: `git log --since=<date>` (what was done), the project's current memory,
the project's `CLAUDE.md`, `wiki/log.md` and `tasks/log.md`.

## 2. Proposals

Each proposal is one of:

- a new memory (the correction recurred ≥ 2 times and isn't in memory yet);
- an edit to a memory that the code or new corrections have contradicted;
- moving a confirmed rule from memory to the project's `CLAUDE.md` (propose only);
- a new skill, or an edit to an existing one, for a recurring sequence;
- a skill or agent that was never invoked: ask whether it's needed.

Each one has a **basis** (dates, how many times) and a **concrete edit** (text or diff). No
basis in the history, no proposal: "the way it usually is" is not an argument. Few findings
is fine: two precise proposals beat ten generic ones.

## 3. Result

Write `$DATA/projects/$PROJ/reviews/<YYYY-MM-DD>.md`: the period, sources, list of
proposals. Then:

- **Interactive run**: show the proposals as a list and ask which to apply. Apply only the
  chosen ones; new skills and agents go into `$DATA/projects/$PROJ/`.
- **Scheduled run** (`claude -p`, nobody will answer): only the file, apply nothing. End
  with one line: how many proposals and where the file is.
