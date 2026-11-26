# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Claude Code tooling ("обвязка"): global rules, a stack-neutral project template
(skills/agents/hook scripts), generic feedback memories, and `link.sh`, which deploys all of
it via symlinks. This repo is the **tooling** root (git). Per-project content — project
`CLAUDE.md`, skills, agents, wiki, tasks, memory, project decision log — lives in the
**data** root, `$CLAUDE_DATA` (default `~/Documents/ai-config`), which has no git and is
synced (or not) however its owner likes.

Keep this repo project-independent, not anonymous: nothing that identifies an employer, a
project, a host, a machine, internal addresses or keys goes in — not even in history. The
owner's name and e-mail are fine (commit authorship, the own address in content).

## Layout

- `INSTALL.md` — AI installer prompt, run from the project to connect:
  `claude "Install https://github.com/krotghar/claude-tooling following its INSTALL.md"`;
  `UPDATE.md` — the same for an existing install, from any folder:
  `claude "Update https://github.com/krotghar/claude-tooling following its UPDATE.md"`.
- `home/<lang>/CLAUDE.md` → `~/.claude/CLAUDE.md` — global instructions; `home/<lang>/skills/*`
  (`onboard-project`, `tooling-review`) → `~/.claude/skills/`; `home/scripts/*` (language-neutral:
  status line, hook scripts) → `~/.claude/scripts/`, wired up in `home/settings.json` template.
- Languages: `home/`, `projects/_template/`, `memory/_template/` have `ru/` and `en/` trees.
  RU is the source, EN its translation — change RU, update EN in the same commit with the same
  file set (EN memory has no `feedback_reply_in_russian`). `CLAUDE_TOOLING_LANG` (default `ru`) picks one.
- `home/settings.json` — neutral template for `~/.claude/settings.json`; not linked, compare
  by hand. Its `additionalDirectories` must cover both roots.
- `projects/_template/<lang>/`, `memory/_template/<lang>/` — never linked (`link.sh` skips `_*`). A new
  project gets a **copy** via `link.sh --init`; placeholders `<Project>`, `<DataRoot>`,
  `<ToolingRoot>` are substituted on copy. Scripts that need the data root use
  `${CLAUDE_DATA:-<DataRoot>}`.
- `decisions/` — decision log for the tooling itself (rules in `decisions/CLAUDE.md`). The
  full pre-split history and general decisions are in `$CLAUDE_DATA/decisions/`,
  per-project ones in `$CLAUDE_DATA/projects/<project>/decisions/`.
- `hooks/pre-commit`, `hooks/leak-patterns` — leak guard (see below).

From the data root `link.sh` links `projects/<P>/*` into worktrees, `memory/<P>/` into
`~/.claude/projects/<key>/memory`, `home/skills/*` into `~/.claude/skills/`, and `fish/*.fish`
into `~/.config/fish/functions/`. The memory key is derived from the real main-worktree path
on `link.sh <worktree>`; `--home` also relinks memory of projects under `$CLAUDE_PROJECTS` if set
(no default). Settings come from env vars or untracked `local.env` next to
`link.sh` (env wins). Platforms: macOS, Linux, Windows via Git Bash (native symlinks with
Developer Mode; without it junctions, `@`-import files for `CLAUDE*.md`, hardlinks —
`CLAUDE_TOOLING_NO_SYMLINKS=1` forces that path for testing); no `sed -i`.

## Commands

```bash
./link.sh --home                               # home symlinks
./link.sh <project-worktree>                   # symlinks into a specific worktree
./link.sh --init <project>                     # new project: copy _template, then link
git config core.hooksPath hooks                # once per clone: enable the leak guard
hooks/pre-commit --all                         # scan the whole tree, not just the index
```

Idempotent — safe to re-run. `link.sh` never silently clobbers a real file at the target:
it renames it to `<name>.bak`. It appends linked paths to the project's `.git/info/exclude`.
A path the project tracks in git is left alone: `CLAUDE.md` falls back to `CLAUDE.local.md`,
`.claude/settings.json` to `.claude/settings.local.json`, the rest is skipped with a warning.
Test `--init` against a temp dir: `CLAUDE_DATA=$(mktemp -d) ./link.sh --init <tmp-git-repo>`.

## Leak guard

- `.gitignore` is an allowlist (`/*`, then `!` per allowed path). Adding a top-level file
  means adding it there.
- `hooks/pre-commit` greps staged content against `hooks/leak-patterns` (generic: home
  paths, private keys, `.lan` hosts, RFC1918 addresses, e-mail other than noreply or your own `user.email`) and
  `$CLAUDE_DATA/.leak-patterns` (personal: projects, hosts — kept out of the repo on
  purpose, since the list itself would leak). A hit blocks the commit; fix, don't bypass.

## Editing conventions

- Changing the tooling (adding/removing a skill, agent, hook or script; changing a model,
  effort, tools, when it's invoked; deciding *not* to change it) — record the decision in
  `decisions/` in the same session.
- A change that breaks existing installs (a linked file moves, a new required setting) needs a
  step in `UPDATE.md` in the same commit.
- Things learned along the way go into auto memory, not into this file. Propose promoting a
  rule here, don't do it silently.
- Keep scope tight; check the actual source of truth before implementing.
