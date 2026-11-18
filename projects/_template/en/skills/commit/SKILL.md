---
name: commit
description: Commit with a title check — validates the format (one line, no bullet list, no Co-Authored-By) before calling git commit.
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_PROJECT_DIR}/.claude/scripts/commit.sh *)
---

The user explicitly asked to commit with the title: $ARGUMENTS

Do exactly one step — call the wrapper script, passing the title as its only argument:

```
${CLAUDE_PROJECT_DIR}/.claude/scripts/commit.sh "$ARGUMENTS"
```

The script checks the format itself (one-line title, no list of changes, no `Co-Authored-By`) and either creates the commit or refuses with a clear reason — in that case show the reason to the user and don't try to commit around the script.

Within this skill, don't call `git commit` directly — only through this script. The script doesn't check the task prefix (`PROJ-123 ...`): that's a convention from the project's `CLAUDE.md`; a hard check can be added to `.claude/scripts/commit.sh` if wanted.
