#!/usr/bin/env bash
#
# PreToolUse hook for research agents (bug-investigator): Edit/Write/NotebookEdit
# are allowed only inside their worktree <main-worktree>-research-* (next to the project's
# main worktree), in the session's temporary directories: /tmp/claude-* (Claude Code
# scratchpad) and $TMPDIR, $TMP, $TEMP (other harnesses write there, and on Windows the
# scratchpad lives under them), and in the directories passed as arguments (e.g. the
# project's task wiki, where the agent writes its report — the path is substituted by
# link.sh --init from placeholders). The rest of /tmp, the main checkout and everything
# else — blocked.
#
# No Python or jq: Windows (Git Bash) usually has neither.
#
set -uo pipefail

# Path from the JSON on stdin: tool_input.file_path or tool_input.notebook_path.
input="$(cat)"
raw="$(printf '%s' "$input" | grep -oE '"(file_path|notebook_path)"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' | head -1 \
  | sed -E 's/^"[a-z_]+"[[:space:]]*:[[:space:]]*"//; s/"$//; s/\\\\/\\/g; s/\\"/"/g')"
[ -n "$raw" ] || exit 0

to_posix() {
  case "$1" in
    [A-Za-z]:[\\/]*) command -v cygpath >/dev/null && cygpath -u "$1" || echo "$1" ;;
    "~/"*) echo "$HOME/${1#\~/}" ;;
    *) echo "$1" ;;
  esac
}

# Absolute path without symlinks; a missing tail (new file) is appended as is.
# On Windows, in the C:/x/y form: otherwise the same directory comes out as /tmp/... or as
# /c/Users/<u>/AppData/Local/Temp/..., and the comparison with TMPDIR misses.
resolve() {
  local p="$1" rest="" abs
  while [ ! -d "$p" ] && [ "$p" != "/" ] && [ "$p" != "." ]; do
    rest="/$(basename "$p")$rest"
    p="$(dirname "$p")"
  done
  abs="$(cd "$p" && pwd -P)$rest"
  if command -v cygpath >/dev/null; then cygpath -m "$abs"; else echo "$abs"; fi
}

path="$(resolve "$(to_posix "$raw")")"

main="$(git -C "${CLAUDE_PROJECT_DIR:-$PWD}" worktree list --porcelain 2>/dev/null | awk '/^worktree /{sub(/^worktree /, ""); print; exit}')"
[ -n "$main" ] && main="$(resolve "$(to_posix "$main")")"

case "$path" in
  /tmp/claude-*/* | /private/tmp/claude-*/*) exit 0 ;;
esac
for tmp in "${TMPDIR:-}" "${TMP:-}" "${TEMP:-}"; do
  [ -n "$tmp" ] && [ -d "$(to_posix "$tmp")" ] || continue
  tmp="$(resolve "$(to_posix "$tmp")")"
  case "$path" in "${tmp%/}"/*) exit 0 ;; esac
done
for allow in "$@"; do
  [ -n "$allow" ] || continue
  case "$path" in "$(resolve "$(to_posix "$allow")")"/*) exit 0 ;; esac
done
if [ -n "$main" ]; then
  case "$path" in "$main"-research-*/*) exit 0 ;; esac
fi

printf 'research agent: editing outside the research worktree is forbidden: %s. Create your own worktree %s-research-* and edit there.\n' "$path" "${main:-<main-worktree>}" >&2
exit 2
