# Updater prompt

This file is instructions for Claude Code, not for a human. It is for someone who installed
the tooling earlier and wants the current version. Start it from any folder:

```bash
claude "Update https://github.com/krotghar/claude-tooling following its UPDATE.md"
```

An old clone may not have this file yet, which is why the command names the repository and not
a local path.

---

You are updating this tooling for the user. Go step by step, explain each step in one or two
sentences, and ask before anything that overwrites, moves or deletes their files. `TOOLING`
below is the user's existing clone of the tooling (where `link.sh` lives). On Windows every
command runs in Git Bash.

This session started before the update, so any tooling skill it lists is the old one: read
files instead of calling skills.

## Language

If `TOOLING/local.env` sets `CLAUDE_TOOLING_LANG`, talk in that language. Otherwise your first
message, before any tool call, asks in both languages: Russian or English (`ru` / `en`). Talk
only in the chosen one from then on; it also goes into `local.env` in step 3.

## 0. Find the clone

In this order:

- The session runs inside a clone of the tooling (`link.sh` at the git root).
- `~/.claude/CLAUDE.md` is a symlink, even a broken one: `readlink` gives
  `TOOLING/home/<lang>/CLAUDE.md`, or `TOOLING/home/CLAUDE.md` in versions before the RU/EN
  split. On Windows without Developer Mode it is a one-line `@<path>` file with the same path.
- `~/.claude/skills/onboard-project` is a symlink or junction: `TOOLING` is three levels up
  from its target.

Nothing found: the tooling isn't installed here. Say so and offer `INSTALL.md` instead.

## 1. Local changes

```bash
git -C "$TOOLING" status --short
```

The global rules are linked into `~/.claude/`, so edits made through the link land in the
clone. If anything is modified, show the user the diff. Their own rules belong in
`$CLAUDE_DATA/home/CLAUDE.md` (personal rules, imported by the global ones; create it if
missing): offer to move the additions there, then restore the tooling files. Do it only on a
yes; if they want to keep the edits in place, stop and let them decide how to merge.

## 2. History and pull

```bash
git -C "$TOOLING" fetch origin
git -C "$TOOLING" merge-base HEAD origin/main
```

No merge base means the clone predates the repository being recreated (2026-10-31) and
`git pull` cannot work. Offer to clone again: move the old clone aside, clone into the same
path (so existing links keep their target), copy `local.env` over if there was one. Delete the
old clone only on a yes, after step 6 shows nothing points into it.

Otherwise note the current commit (step 8 needs it) and pull:

```bash
git -C "$TOOLING" rev-parse HEAD
git -C "$TOOLING" pull --ff-only
```

Then read `TOOLING/UPDATE.md`: if it differs from what you were given, follow the local one.

## 3. Settings file

Older versions had no `TOOLING/local.env`. If it's missing, find the current values rather
than asking blindly: `CLAUDE_DATA` in the environment, or where `~/.claude/CLAUDE.personal.md`
or the project memory links in `~/.claude/projects/*/memory` point; default
`~/Documents/ai-config`. Confirm with the user, then write it (git ignores it):

```bash
CLAUDE_DATA="<data root>"
CLAUDE_TOOLING_LANG="<ru|en>"
```

Use `$HOME/...` rather than `~`. Older versions also relinked memory of every project under
`~/StudioProjects` on `--home`; now that happens only if `CLAUDE_PROJECTS` is set. If the user
keeps projects in one folder, offer to add `CLAUDE_PROJECTS="<that folder>"`.

## 4. User settings

`~/.claude/settings.json` must have both roots in `permissions.additionalDirectories`: the
data root and `TOOLING`. Older installs often have only the first. Add what's missing, show
the diff, write on a yes. Leave every other key alone.

## 5. Relink home

```bash
"$TOOLING/link.sh" --home
```

Show the output. Every line should be `link:` or `ok:`. This repairs `~/.claude/CLAUDE.md`
(the global rules moved to `home/<lang>/`, so an old link is broken and the rules silently
stopped loading) and links the new user skills.

## 6. Broken links

Earlier versions linked paths that no longer exist. List dangling symlinks:

```bash
find ~/.claude ~/.agents ~/.config/fish -maxdepth 4 -type l ! -exec test -e {} \; -print 2>/dev/null
```

Show those pointing into `TOOLING` or the data root and offer to remove them (for example
`~/.agents/AGENTS.md`, no longer linked). Remove only on a yes; leave links pointing elsewhere
alone.

## 7. Projects

For each connected project (folders in `$CLAUDE_DATA/projects/`), ask where its folder is and
offer to rerun `"$TOOLING/link.sh" <project folder>`. It is safe to repeat; it removes the
`AGENTS.md` link older versions put there and switches to `CLAUDE.local.md` /
`.claude/settings.local.json` if the project keeps its own in git.

The project setups themselves (`$CLAUDE_DATA/projects/<name>/`) are copies of the template,
made once, so the update does not change them, by design. Tell the user that. Don't compare
or merge them with the template unless they ask.

## 8. What's new

Read `git log --oneline <old HEAD>..HEAD` (or the recent log after a fresh clone) and
`decisions/log.md`, and tell the user in a few lines what changed for them. If
`tooling-review` is new to them, describe it and offer a schedule exactly as in step 8 of
`INSTALL.md`.

## 9. Summary

List what was done: how the code was updated, `local.env`, settings, links repaired or
removed, projects relinked. Finish with: start a new Claude Code session to pick up the new
rules and skills.
