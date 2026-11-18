---
name: onboard-project
description: Connect a project to the tooling: an existing one (minimal CLAUDE.md from the code) or a new one (two questions and an empty skeleton); set up the harness from the template, pick memories, link. Use when the user wants to start working on a project through the tooling, "connect the project", "set up the harness", or from INSTALL.md.
---

# Connecting a project to the tooling

The goal is a working minimum, not full documentation: the wiki and rules will grow on their
own as work goes on. Don't generate wiki pages, and don't write anything into `CLAUDE.md`
that you haven't checked against the files.

## 0. Where things live

```bash
TOOLING="$(cd "$(dirname "$(readlink ~/.claude/skills/onboard-project)")/../../.." && pwd)"
[ -f "$TOOLING/local.env" ] && . "$TOOLING/local.env"
echo "tooling=$TOOLING data=${CLAUDE_DATA:-$HOME/Documents/claude-config} lang=${CLAUDE_TOOLING_LANG:-ru}"
```

If the skill isn't run from a symlink (e.g. it's being read from INSTALL.md), the tooling is
the directory containing `link.sh`. On Windows, run all commands in Git Bash.

## 1. Which project

Ask for the project path if it wasn't given. Then there are two branches.

### 1a. The project already exists

1. Is it a git repository? If not, explain that the tooling binds to a git worktree, and
   offer `git init` (only on "yes").
2. If the harness already exists (`$CLAUDE_DATA/projects/<main worktree name>/`), just run
   `"$TOOLING/link.sh" <path>` and go to step 3.
3. Otherwise `"$TOOLING/link.sh" --init <path>`.
4. Study the project **from the files, not from guesses**: README, build manifests
   (`package.json`, `Cargo.toml`, `pyproject.toml`, `CMakeLists.txt`, `Makefile`,
   `build.gradle*`, `*.sln`/`*.csproj`, `go.mod`, etc.), CI configs, top-level
   directories. For a large repository, hand the overview to a subagent (Explore) and keep
   only the conclusion.
5. In `$CLAUDE_DATA/projects/<name>/CLAUDE.md` fill in only:
   - "About the project": what it is, the stack, the main directories, 3–6 lines;
   - "Commands": commands that are **visible in the files** (manifest scripts, Makefile
     targets, CI steps). If you can't find a command, leave the placeholder and ask the user.
   Leave the other placeholders alone.
6. Suggest in a line or two what's worth adding for the stack (reviewer rules, test
   libraries in `unit-tests`), without editing; only on "yes".

### 1b. The project doesn't exist yet

1. Two questions, no more: **what the project is and why** (a sentence or two) and **the
   stack** (if it's not decided, write that down). Plus where to create the directory.
2. `mkdir`, `git init`, `"$TOOLING/link.sh" --init <path>`.
3. Put the user's answers into "About the project" as is. "Commands" stays a placeholder;
   it gets filled in once there's a build.

## 2. Check the links

`ls -la <path>/CLAUDE.md <path>/.claude/`: the symlinks to the data are in place. On
Windows a symlink must be a symlink (`ls -la` shows `->`), not a copy of the file.

## 3. Memories

Show the list from `$TOOLING/memory/_template/<language>/MEMORY.md`, one line per memory,
and ask which ones to take ("all" or "none" are fine). Copy the chosen ones into
`$CLAUDE_DATA/memory/<name>/`, along with a `MEMORY.md` containing only their lines, then
run `"$TOOLING/link.sh" <path>`; it links the memory using the project's real path.

## 4. Summary

Briefly: where the harness is, what was filled in `CLAUDE.md`, which questions are still
open, which memories are connected. Remind the user that a new Claude Code session in the
project directory will pick up the harness, but the current one won't.
