# Installer prompt

This file is instructions for Claude Code, not for a human. Start it from the cloned
repository:

```bash
claude "Install the tooling following INSTALL.md"
```

---

You are installing this tooling for the user. Talk to them in the language they wrote to you
in. Go step by step, explain each step in one or two sentences, and ask before anything that
overwrites or moves their files. `TOOLING` below is the directory of this file (where
`link.sh` lives).

## 1. Environment

- Check that `git` is available.
- **Windows:** every command below runs in Git Bash, which Claude Code on Windows already
  needs. `link.sh` creates native symlinks, which need Developer Mode (Settings → For
  developers) or an elevated shell. Check before anything else:
  ```bash
  d="$(mktemp -d)"; touch "$d/a"; MSYS=winsymlinks:nativestrict ln -s "$d/a" "$d/b" && ls -la "$d"; rm -rf "$d"
  ```
  If it fails with "Operation not permitted", Developer Mode is off: ask the user to turn it
  on (Settings → System → For developers → Developer Mode), then run the check again. Stop
  here until it passes. Don't fall back to copies: the tooling relies on edits going through
  the links.
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

Look before linking. `link.sh --home` turns `~/.claude/CLAUDE.md` into a symlink; a real file
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

## 7. First project

Ask whether to connect a project now. If yes, read
`TOOLING/home/<lang>/skills/onboard-project/SKILL.md` and follow it. It was just linked, but
this session started before that, so the skill isn't loaded here: read the file instead of
calling the skill. For later projects the user runs `/onboard-project` in a new session.

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
