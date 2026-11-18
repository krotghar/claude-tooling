#!/usr/bin/env bash
#
# Commit wrapper for /commit. Checks the title format before calling
# `git commit`, so we don't rely on the model remembering the rules from
# CLAUDE.md/memory every time:
#   - the title is a single line (no bulleted list of changes below it)
#   - no "Co-Authored-By"
#
# The script does not require a task prefix (`PROJ-123 ...`) — that's a project
# convention from CLAUDE.md. Need a hard check — add it here in the project itself.
#
# Usage:
#   .claude/scripts/commit.sh "PROJ-123 Fix login crash on guest flow"
#
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: commit.sh \"<title>\"" >&2
  exit 1
fi

TITLE="$1"

if [[ "$TITLE" == *$'\n'* ]]; then
  echo "Rejected: the commit title must be a single line, with no list of changes below it." >&2
  exit 1
fi

if [[ "$TITLE" == *"Co-Authored-By"* ]]; then
  echo "Rejected: 'Co-Authored-By' is not allowed in commits in this repository." >&2
  exit 1
fi

git commit -m "$TITLE"
