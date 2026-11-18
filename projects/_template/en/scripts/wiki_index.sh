#!/usr/bin/env bash
# SessionStart hook: puts the project's local wiki index into the session context,
# so the already accumulated pages are checked first, before digging into the repository.
# The wiki lives outside the git repository, in the tooling data directory ($CLAUDE_DATA).
#
# Registered in the project's .claude/settings.json. In worktrees that Claude Code
# creates itself (<repo>/.claude/worktrees/...), the project settings.json doesn't arrive
# before the session starts — the hook doesn't fire there. It's a speed-up, not the mechanism:
# the "wiki first" rule is duplicated in the global CLAUDE.md. The repo guard
# below is in case the hook does get registered at the user level.
set -uo pipefail

# Repository guard. The project name is the basename of the MAIN worktree (as in link.sh),
# not cwd, so it works both from a sibling worktree and from .claude/worktrees/*.
# Not git / no wiki for the project — exit silently.
cwd="${CLAUDE_PROJECT_DIR:-$PWD}"
main_worktree="$(git -C "$cwd" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2; exit}')"
[ -n "$main_worktree" ] || exit 0

PROJECT="$(basename "$main_worktree")"
WIKI_DIR="${CLAUDE_DATA:-<DataRoot>}/projects/$PROJECT/wiki"
INDEX="$WIKI_DIR/index.md"

# The wiki may be unavailable (another machine, data not synced yet) — also silent.
[ -r "$INDEX" ] || exit 0

cat <<EOF
Local project wiki (outside git): $WIKI_DIR
Pages: $WIKI_DIR/pages/<slug>.md, schema: $WIKI_DIR/CLAUDE.md

This is a step of the working order, not a hint: BEFORE the first search of the repository —
before Grep/Glob and before reading files to "understand how things work here" — check
the index below and read the relevant pages/<slug>.md in full.

The trigger is not "an architecture question" (tasks don't describe themselves that way and the rule
doesn't fire), but a simple one: you're about to dig into an unfamiliar part of the project →
page first, then the repository. A task like "implement X in section Y" falls
under it.

How this fits with the "check the source of truth" rule: the page tells you
WHERE to look and which pitfalls are already known; the code, the mockup and the project CLAUDE.md
confirm WHAT is there now. The wiki doesn't replace checking the code — it removes
blind searching before it. If a page disagrees with the code, the code is right, and fix
the page.

EOF

cat "$INDEX"
