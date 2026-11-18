#!/usr/bin/env bash
#
# PreToolUse hook for research agents (bug-investigator): Edit/Write/NotebookEdit
# are allowed only inside their worktree <main-worktree>-research-* (next to the project's
# main worktree) and in the session's temporary directories: /tmp/claude-* (Claude Code
# scratchpad) and $TMPDIR (other harnesses write there). The rest of /tmp, the main
# checkout and everything else — blocked.
#
set -euo pipefail

MAIN_WORKTREE="$(git -C "${CLAUDE_PROJECT_DIR:-$PWD}" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2; exit}')" || true
export MAIN_WORKTREE

python3 -c '
import json, os, re, sys
data = json.load(sys.stdin)
tool_input = data.get("tool_input") or {}
raw = tool_input.get("file_path") or tool_input.get("notebook_path") or ""
if not raw:
    sys.exit(0)
path = os.path.realpath(os.path.expanduser(raw))
main = os.environ.get("MAIN_WORKTREE", "")
allowed = [r"/(private/)?tmp/claude-[^/]+/"]
tmpdir = os.environ.get("TMPDIR", "")
if tmpdir:
    allowed.append(re.escape(os.path.realpath(tmpdir).rstrip("/")) + "/")
if main:
    allowed.append(re.escape(os.path.realpath(main)) + r"-research-[^/]+/")
if any(re.match(pattern, path) for pattern in allowed):
    sys.exit(0)
hint = main or "<main-worktree>"
print(
    f"research agent: edits outside the research worktree are not allowed: {path}. "
    f"Create your own worktree {hint}-research-* and edit there.",
    file=sys.stderr,
)
sys.exit(2)
'
