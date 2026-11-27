---
name: commit
description: Commit with a title check — validates the format (one line, no bullet list), with a Co-Authored-By trailer if the project allows it, before calling git commit.
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_PROJECT_DIR}/.claude/scripts/commit.sh *)
---

The user explicitly asked to commit with the title: $ARGUMENTS

Do exactly one step — call the wrapper script, passing the title as the first argument:

```
${CLAUDE_PROJECT_DIR}/.claude/scripts/commit.sh "$ARGUMENTS" ["<Model name> <noreply@anthropic.com>"]
```

The second argument is the `Co-Authored-By` value from the attribution system reminder, and only if
the project's `CLAUDE.md` allows a co-author (then `scripts/commit.sh` has `COAUTHOR=yes`). If it
forbids one or says nothing — pass the title alone. Never put `Co-Authored-By` in the title.

The script checks the format itself (one-line title, no list of changes, `Co-Authored-By` only as the second argument and only with `COAUTHOR=yes`) and either creates the commit or refuses with a clear reason — in that case show the reason to the user and don't try to commit around the script.

Within this skill, don't call `git commit` directly — only through this script. The script doesn't check the task prefix (`PROJ-123 ...`): that's a convention from the project's `CLAUDE.md`; a hard check can be added to `.claude/scripts/commit.sh` if wanted.
