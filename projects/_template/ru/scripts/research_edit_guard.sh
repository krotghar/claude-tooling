#!/usr/bin/env bash
#
# PreToolUse-хук research-агентов (bug-investigator): Edit/Write/NotebookEdit
# разрешены только внутри их воркtree <главный-воркtree>-research-* (рядом с главным
# воркtree проекта) и во временных каталогах сессии: /tmp/claude-* (scratchpad
# Claude Code) и $TMPDIR (другие харнессы пишут туда). Остальной /tmp, основной
# checkout и всё прочее — блок.
#
# Без Python и jq: на Windows (Git Bash) их обычно нет.
#
set -uo pipefail

# Путь из JSON на stdin: tool_input.file_path или tool_input.notebook_path.
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

# Абсолютный путь без симлинков; несуществующий хвост (новый файл) дописывается как есть.
resolve() {
  local p="$1" rest=""
  while [ ! -d "$p" ] && [ "$p" != "/" ] && [ "$p" != "." ]; do
    rest="/$(basename "$p")$rest"
    p="$(dirname "$p")"
  done
  echo "$(cd "$p" && pwd -P)$rest"
}

path="$(resolve "$(to_posix "$raw")")"

main="$(git -C "${CLAUDE_PROJECT_DIR:-$PWD}" worktree list --porcelain 2>/dev/null | awk '/^worktree /{sub(/^worktree /, ""); print; exit}')"
[ -n "$main" ] && main="$(resolve "$(to_posix "$main")")"

case "$path" in
  /tmp/claude-*/* | /private/tmp/claude-*/*) exit 0 ;;
esac
if [ -n "${TMPDIR:-}" ] && [ -d "$TMPDIR" ]; then
  tmp="$(resolve "$TMPDIR")"
  case "$path" in "${tmp%/}"/*) exit 0 ;; esac
fi
if [ -n "$main" ]; then
  case "$path" in "$main"-research-*/*) exit 0 ;; esac
fi

printf 'research-агент: правка вне research-воркtree запрещена: %s. Создай свой воркtree %s-research-* и правь там.\n' "$path" "${main:-<главный-воркtree>}" >&2
exit 2
