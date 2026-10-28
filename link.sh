#!/usr/bin/env bash
#
# Расставляет симлинки в ~/.claude (домашние) или в конкретный git-воркtree
# (проектные). Идемпотентен — можно гонять повторно на уже размеченном месте.
#
# Два корня:
#   тулинг — каталог этого скрипта (git): home/CLAUDE.md, шаблоны;
#   данные — $CLAUDE_DATA (без git): projects/<П>/, memory/<П>/, home/skills/*,
#            fish/*.fish.
# Главные воркtree проектов лежат в $CLAUDE_PROJECTS/<П> — от этого пути
# считается ключ памяти в ~/.claude/projects/.
#
# Использование:
#   link.sh --home
#   link.sh <путь-к-воркtree>
#   link.sh --init <путь-к-воркtree>   # нет обвязки проекта — завести из projects/_template
#
# Папки с `_` в начале имени (projects/_template, memory/_template) — заготовки,
# а не проекты: их не линкуем.
#
set -euo pipefail

TOOLING="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA="${CLAUDE_DATA:-$HOME/Documents/claude-config}"
PROJECTS="${CLAUDE_PROJECTS:-$HOME/StudioProjects}"

# Существующий реальный файл/каталог на месте цели не затираем молча —
# переименовываем в .bak рядом и говорим об этом.
link_one() {
  local target="$1" link_name="$2"
  if [[ -L "$link_name" ]]; then
    local current
    current="$(readlink "$link_name")"
    if [[ "$current" == "$target" ]]; then
      echo "  ok: $link_name"
      return
    fi
    rm "$link_name"
  elif [[ -e "$link_name" ]]; then
    local bak="${link_name}.bak"
    echo "  бэкап реального файла: $link_name -> $bak"
    mv "$link_name" "$bak"
  fi
  mkdir -p "$(dirname "$link_name")"
  ln -s "$target" "$link_name"
  echo "  link: $link_name -> $target"
}

# Дописывает /<путь> в .git/info/exclude (общий на все воркtree), если строки
# там ещё нет.
ensure_excluded() {
  local worktree="$1" rel="$2"
  local common_dir
  common_dir="$(git -C "$worktree" rev-parse --git-common-dir 2>/dev/null)" || return 0
  [[ "$common_dir" = /* ]] || common_dir="$worktree/$common_dir"
  local exclude_file="$common_dir/info/exclude"
  mkdir -p "$(dirname "$exclude_file")"
  touch "$exclude_file"
  if ! grep -qxF "/$rel" "$exclude_file"; then
    echo "/$rel" >>"$exclude_file"
    echo "  exclude: /$rel"
  fi
}

link_home() {
  echo "Домашние симлинки:"
  link_one "$TOOLING/home/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  # Глобальный AGENTS.md (читает Cline и др.) — те же инструкции.
  link_one "$TOOLING/home/CLAUDE.md" "$HOME/.agents/AGENTS.md"

  local fish_file
  for fish_file in "$DATA/fish"/*.fish; do
    [[ -f "$fish_file" ]] || continue
    link_one "$fish_file" "$HOME/.config/fish/functions/$(basename "$fish_file")"
  done

  # Личные скиллы — поштучно: ~/.claude/skills уже занят каталогом приложения.
  for skill_dir in "$DATA/home/skills"/*/; do
    [[ -d "$skill_dir" ]] || continue
    link_one "${skill_dir%/}" "$HOME/.claude/skills/$(basename "$skill_dir")"
  done

  if [[ -d "$DATA/memory" ]]; then
    for proj_dir in "$DATA/memory"/*/; do
      [[ -d "$proj_dir" ]] || continue
      local proj_name main_worktree key
      proj_name="$(basename "$proj_dir")"
      [[ "$proj_name" == _* ]] && continue
      main_worktree="$PROJECTS/$proj_name"
      key="$(echo "$main_worktree" | tr '/._' '-')"
      link_one "${proj_dir%/}" "$HOME/.claude/projects/$key/memory"
    done
  fi
}

# Путь в файлы шаблона — через $HOME, если он под домашним каталогом: так строка
# верна и в shell-скрипте, и в markdown.
home_form() {
  local path="$1"
  if [[ "$path" == "$HOME"/* ]]; then
    echo "\$HOME${path#"$HOME"}"
  else
    echo "$path"
  fi
}

# Новая обвязка проекта — копия (не симлинк) projects/_template, дальше проект
# специализирует её у себя. В файлах шаблона <Project> заменяется на имя проекта,
# <DataRoot> — на корень данных, <ToolingRoot> — на корень тулинга.
init_project() {
  local proj_name="$1" proj_dir="$2"
  local tpl="$TOOLING/projects/_template"
  echo "Обвязка '$proj_name' из шаблона:"
  mkdir -p "$(dirname "$proj_dir")"
  cp -R "$tpl" "$proj_dir"

  local area
  for area in wiki tasks; do
    mkdir -p "$proj_dir/$area/pages"
    mv "$proj_dir/$area-CLAUDE.md" "$proj_dir/$area/CLAUDE.md"
  done
  printf '# Index\n\nКаталог страниц wiki проекта %s. Схема — `CLAUDE.md` рядом.\n' \
    "$proj_name" >"$proj_dir/wiki/index.md"
  printf '# Log\n\n## [%s] ingest | Заведена wiki\nСхема из шаблона. Страниц пока нет.\n' \
    "$(date +%F)" >"$proj_dir/wiki/log.md"
  printf '# Tasks index\n\nКаталог документов по задачам проекта %s. Схема — [CLAUDE.md](CLAUDE.md), журнал — [log.md](log.md).\n' \
    "$proj_name" >"$proj_dir/tasks/index.md"
  printf '# Tasks log\n' >"$proj_dir/tasks/log.md"

  local data_root tooling_root
  data_root="$(home_form "$DATA")"
  tooling_root="$(home_form "$TOOLING")"
  grep -rlE '<Project>|<DataRoot>|<ToolingRoot>' "$proj_dir" | while IFS= read -r f; do
    sed -i '' -e "s|<Project>|$proj_name|g" -e "s|<DataRoot>|$data_root|g" \
      -e "s|<ToolingRoot>|$tooling_root|g" "$f"
  done
  date +%F >"$proj_dir/.template-origin"
  echo "  создано: $proj_dir"
}

link_worktree() {
  local worktree="$1" init="${2:-}"
  worktree="$(cd "$worktree" && pwd)"

  local main_worktree
  main_worktree="$(git -C "$worktree" worktree list --porcelain | awk '/^worktree /{print $2; exit}')"
  if [[ -z "$main_worktree" ]]; then
    echo "link.sh: не удалось определить главный воркtree для $worktree" >&2
    exit 1
  fi

  local proj_name="$(basename "$main_worktree")"
  local proj_dir="$DATA/projects/$proj_name"
  if [[ "$proj_name" == _* ]]; then
    echo "link.sh: '$proj_name' — имя заготовки, не проекта" >&2
    exit 1
  fi
  if [[ ! -d "$proj_dir" ]]; then
    if [[ -z "$init" ]]; then
      echo "link.sh: нет обвязки под проект '$proj_name' в $DATA/projects/ (завести из шаблона: link.sh --init $worktree)" >&2
      exit 1
    fi
    init_project "$proj_name" "$proj_dir"
  fi

  echo "Проектные симлинки в $worktree (обвязка: $proj_name):"
  link_one "$proj_dir/CLAUDE.md" "$worktree/CLAUDE.md"
  # AGENTS.md (https://agents.md/) — те же инструкции для остальных агентов.
  link_one "$proj_dir/CLAUDE.md" "$worktree/AGENTS.md"
  mkdir -p "$worktree/.claude"
  link_one "$proj_dir/skills" "$worktree/.claude/skills"
  link_one "$proj_dir/agents" "$worktree/.claude/agents"
  link_one "$proj_dir/scripts" "$worktree/.claude/scripts"
  link_one "$proj_dir/settings.json" "$worktree/.claude/settings.json"

  for rel in CLAUDE.md AGENTS.md .claude/skills .claude/agents .claude/scripts .claude/settings.json; do
    ensure_excluded "$worktree" "$rel"
  done
}

case "${1:-}" in
  --home)
    link_home
    ;;
  --init)
    [[ -n "${2:-}" ]] || { echo "Использование: link.sh --init <путь-к-воркtree>" >&2; exit 1; }
    link_worktree "$2" init
    ;;
  "")
    echo "Использование: link.sh --home | link.sh [--init] <путь-к-воркtree>" >&2
    exit 1
    ;;
  *)
    link_worktree "$1"
    ;;
esac
