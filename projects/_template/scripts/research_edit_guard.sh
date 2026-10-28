#!/usr/bin/env bash
#
# PreToolUse-хук research-агентов (bug-investigator): Edit/Write/NotebookEdit
# разрешены только внутри их воркtree <главный-воркtree>-research-* (рядом с главным
# воркtree проекта) и во временном каталоге сессии. Всё остальное (в т.ч. основной
# checkout) — блок.
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
if main:
    allowed.append(re.escape(os.path.realpath(main)) + r"-research-[^/]+/")
if any(re.match(pattern, path) for pattern in allowed):
    sys.exit(0)
hint = main or "<главный-воркtree>"
print(
    f"research-агент: правка вне research-воркtree запрещена: {path}. "
    f"Создай свой воркtree {hint}-research-* и правь там.",
    file=sys.stderr,
)
sys.exit(2)
'
