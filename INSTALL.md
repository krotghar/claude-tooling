# Installer prompt

This file is instructions for Claude Code, not for a human. The user starts it from the
folder of the project they want to connect:

```bash
cd <project>
claude "Install https://github.com/krotghar/claude-tooling following its INSTALL.md"
```

Starting it from a clone of the tooling itself also works: then there is no project yet, and
step 7 asks for one.

---

You are installing this tooling for the user. Talk to them in the language they wrote to you
in. Go step by step, explain each step in one or two sentences, and ask before anything that
overwrites or moves their files. `PROJECT` below is the folder the session was started in,
unless it is the tooling clone itself. `TOOLING` is the tooling clone (where `link.sh` lives).

## 0. Find or clone the tooling

- The session runs inside a clone of the tooling (`link.sh` and `INSTALL.md` at the git
  root): `TOOLING` is that folder, there is no `PROJECT`.
- `~/.claude/skills/onboard-project` is a symlink or junction (`[ -L ]` is true for both in
  Git Bash): the tooling is already installed, and
  `TOOLING` is three levels up from its target. Skip to step 7 for `PROJECT`.
- Otherwise ask where to clone the tooling. Default: `~/claude-tooling`; any path outside
  `PROJECT` works. Clone there and read `TOOLING/INSTALL.md`: if it differs from what you were
  given, follow the cloned one.

## 1. Environment

- Check that `git` is available.
- **Windows:** every command below runs in Git Bash, which Claude Code on Windows already
  needs. Developer Mode is not required: without the symlink privilege `link.sh` says so
  and uses junctions for directories, a one-line `@<path>` import for `CLAUDE.md` and
  a hardlink for `.claude/settings.json`. Don't ask the user to turn Developer Mode on. If they have it,
  `link.sh` uses real symlinks.
- Nothing else is needed: the scripts are plain bash, no Python or jq.

## 2. Language

Ask which language the tooling should be in: `ru` or `en` (folders under `home/`,
`projects/_template/`, `memory/_template/`). It sets the language of the global rules,
the project template and the memories. Claude still answers in whatever language the
user writes in.

## 3. Data root

The tooling (this git repo) is kept apart from the **data**: per-project setup, wiki, task
notes, memory. Ask where to keep the data folder. Default: `~/Documents/claude-config`. Any
path works, including a synced folder; syncing is up to the user and out of scope here.

Create it and write `TOOLING/local.env` (git ignores it):

```bash
CLAUDE_DATA="<chosen path>"
CLAUDE_TOOLING_LANG="<ru|en>"
```

Use `$HOME/...` rather than `~` in this file.

## 4. Existing Claude Code setup

Look before linking. `link.sh --home` turns `~/.claude/CLAUDE.md` into a symlink (an
`@<path>` import on Windows without Developer Mode); a real file
there gets renamed to `CLAUDE.md.bak` and drops out of context.

- `~/.claude/CLAUDE.md` is a real file: show the user its content and offer to move it to
  `$CLAUDE_DATA/home/CLAUDE.md`. The global rules import that file, so their rules keep
  working alongside the tooling. Move only on a yes.
- `~/.claude/skills/onboard-project` or `~/.claude/skills/tooling-review` already exist and
  are not symlinks into `TOOLING`: say they will be renamed to `.bak`.

## 5. User settings

`~/.claude/settings.json` needs both roots in `permissions.additionalDirectories` so Claude
can edit project data without a prompt each time. Merge into the existing file (create it if
missing), show the user the diff, write on a yes:

```json
{
  "permissions": {
    "additionalDirectories": ["<data root>", "<TOOLING>"]
  }
}
```

Leave every other key alone.

## 6. Link

```bash
"$TOOLING/link.sh" --home
```

Show the output. Every line should be `link:` or `ok:`.

## 7. Connect the project

Read `TOOLING/home/<lang>/skills/onboard-project/SKILL.md` and follow it for `PROJECT`
(`<lang>` from `TOOLING/local.env`). It may have just been linked, but this session started
before that, so the skill isn't loaded here: read the file instead of calling the skill. No
`PROJECT` (started from the tooling clone): ask whether to connect one now and which.

Tell the user how to connect later projects: the same command from that project's folder, or
`/onboard-project` in a Claude Code session there.

## 8. Periodic review (optional)

The `/tooling-review` skill reads the project's recent sessions and commits and writes
proposals for improving its memory, `CLAUDE.md` and skills, without applying any. Tell the
user it exists, then ask whether to run it on a schedule. If they want that, suggest one of
these and set it up only on a yes:

- Claude desktop app: a local scheduled task running `/tooling-review` in the project folder
  every week;
- otherwise cron (macOS/Linux) or Task Scheduler (Windows) running
  `claude -p "/tooling-review"` in the project folder.

It needs to run locally: it reads the session transcripts in `~/.claude/projects/`.

## 9. Summary

List what was done: data root, language, what was moved, what was linked, which project was
connected, whether a review is scheduled. Finish with: start a new Claude Code session in the
project folder to pick everything up.
