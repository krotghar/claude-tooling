#!/usr/bin/env bash
#
# Расставляет симлинки в ~/.claude (домашние) или в конкретный git-воркtree
# (проектные). Идемпотентен — можно гонять повторно на уже размеченном месте.
#
# Два корня:
#   тулинг — каталог этого скрипта (git): home/<язык>/, шаблоны;
#   данные — $CLAUDE_DATA (без git): projects/<П>/, memory/<П>/, home/skills/*,
#            home/CLAUDE.md, fish/*.fish.
#
# Настройки — переменные окружения или файл local.env рядом со скриптом (его пишет
# инсталлятор, в git он не попадает):
#   CLAUDE_DATA          корень данных (по умолчанию ~/Documents/claude-config)
#   CLAUDE_TOOLING_LANG  язык шаблонов: ru | en (по умолчанию ru)
#   CLAUDE_PROJECTS      где лежат главные воркtree — нужен только --home, чтобы
#                        перелинковать память проектов (по умолчанию ~/StudioProjects)
#
# Использование:
#   link.sh --home
#   link.sh <путь-к-воркtree>
#   link.sh --init <путь-к-воркtree>   # нет обвязки проекта — завести из шаблона
#
# Папки с `_` в начале имени (projects/_template, memory/_template) — заготовки,
# а не проекты: их не линкуем.
#
# Windows: запускать из Git Bash. Симлинки там нативные (нужен Developer Mode или
# права администратора); без них скрипт падает, а не копирует файлы молча.
#
set -euo pipefail

TOOLING="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# local.env — дефолты; заданные в окружении переменные берут верх.
if [[ -f "$TOOLING/local.env" ]]; then
  env_data="${CLAUDE_DATA:-}" env_projects="${CLAUDE_PROJECTS:-}" env_lang="${CLAUDE_TOOLING_LANG:-}"
  # shellcheck source=/dev/null
  source "$TOOLING/local.env"
  CLAUDE_DATA="${env_data:-${CLAUDE_DATA:-}}"
  CLAUDE_PROJECTS="${env_projects:-${CLAUDE_PROJECTS:-}}"
  CLAUDE_TOOLING_LANG="${env_lang:-${CLAUDE_TOOLING_LANG:-}}"
fi
DATA="${CLAUDE_DATA:-$HOME/Documents/claude-config}"
PROJECTS="${CLAUDE_PROJECTS:-$HOME/StudioProjects}"
TOOLING_LANG="${CLAUDE_TOOLING_LANG:-ru}"

if [[ ! -d "$TOOLING/home/$TOOLING_LANG" ]]; then
  echo "link.sh: unknown CLAUDE_TOOLING_LANG='$TOOLING_LANG' (no $TOOLING/home/$TOOLING_LANG)" >&2
  exit 1
fi

IS_WINDOWS=""
case "$(uname -s)" in
  MINGW* | MSYS* | CYGWIN*)
    IS_WINDOWS=1
    export MSYS=winsymlinks:nativestrict CYGWIN=winsymlinks:nativestrict
    ;;
esac

# Путь из git (на Windows вида C:/x/y) → путь для операций с файлами (/c/x/y).
to_posix() {
  if [[ -n "$IS_WINDOWS" ]]; then cygpath -u "$1"; else echo "$1"; fi
}

# Ключ проекта в ~/.claude/projects/ — так его считает Claude Code: абсолютный путь
# главного воркtree, все символы кроме [A-Za-z0-9] заменены на '-'. На Windows путь
# берётся в форме C:/x/y.
memory_key() {
  local path="$1"
  [[ -n "$IS_WINDOWS" ]] && path="$(cygpath -m "$path")"
  echo "$path" | sed 's/[^A-Za-z0-9]/-/g'
}

# Существующий реальный файл/каталог на месте цели не затираем молча —
# переименовываем в .bak рядом и говорим об этом.
link_one() {
  local target="$1" link_name="$2"
  if [[ -L "$link_name" ]]; then
    local current target_cmp
    current="$(readlink "$link_name")"
    # На Windows readlink может вернуть другую форму того же пути (/tmp вместо
    # /c/Users/<u>/AppData/Local/Temp) — сравниваем в одной.
    if [[ -n "$IS_WINDOWS" ]]; then
      current="$(cygpath -m "$current")"
      target_cmp="$(cygpath -m "$target")"
    else
      target_cmp="$target"
    fi
    if [[ "$current" == "$target_cmp" ]]; then
      echo "  ok: $link_name"
      return
    fi
    rm "$link_name"
  elif [[ -e "$link_name" ]]; then
    local bak="${link_name}.bak"
    echo "  backup of a real file: $link_name -> $bak"
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
  case "$common_dir" in
    /* | [A-Za-z]:/*) common_dir="$(to_posix "$common_dir")" ;;
    *) common_dir="$worktree/$common_dir" ;;
  esac
  local exclude_file="$common_dir/info/exclude"
  mkdir -p "$(dirname "$exclude_file")"
  touch "$exclude_file"
  if ! grep -qxF "/$rel" "$exclude_file"; then
    echo "/$rel" >>"$exclude_file"
    echo "  exclude: /$rel"
  fi
}

is_tracked() {
  [[ -n "$(git -C "$1" ls-files -- "$2" 2>/dev/null)" ]]
}

# Прежние версии ставили симлинк и поверх отслеживаемого пути. Такой симлинк, если git
# хранит там не симлинк, убираем и возвращаем путь из git; старая копия — в <путь>.bak.
restore_tracked() {
  local worktree="$1" rel="$2"
  [[ -L "$worktree/$rel" ]] || return 0
  [[ "$(git -C "$worktree" ls-files -s -- "$rel" | head -1)" == 120000* ]] && return 0
  rm "$worktree/$rel"
  git -C "$worktree" checkout -- "$rel"
  echo "  restored from git: $worktree/$rel"
}

link_home() {
  echo "Home symlinks (language: $TOOLING_LANG):"
  link_one "$TOOLING/home/$TOOLING_LANG/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  # Личные правила — из данных; глобальный CLAUDE.md подключает их импортом.
  [[ -f "$DATA/home/CLAUDE.md" ]] && link_one "$DATA/home/CLAUDE.md" "$HOME/.claude/CLAUDE.personal.md"

  local fish_file
  for fish_file in "$DATA/fish"/*.fish; do
    [[ -f "$fish_file" ]] || continue
    link_one "$fish_file" "$HOME/.config/fish/functions/$(basename "$fish_file")"
  done

  # Скиллы — поштучно: ~/.claude/skills уже занят каталогом приложения. Сначала
  # скиллы тулинга, потом личные из данных.
  local skill_dir
  for skill_dir in "$TOOLING/home/$TOOLING_LANG/skills"/*/ "$DATA/home/skills"/*/; do
    [[ -d "$skill_dir" ]] || continue
    link_one "${skill_dir%/}" "$HOME/.claude/skills/$(basename "$skill_dir")"
  done

  # Память проектов, чей главный воркtree лежит в $CLAUDE_PROJECTS. Проекты в других
  # местах линкуют память сами, при `link.sh <воркtree>`.
  if [[ -d "$DATA/memory" ]]; then
    local proj_dir proj_name main_worktree
    for proj_dir in "$DATA/memory"/*/; do
      [[ -d "$proj_dir" ]] || continue
      proj_name="$(basename "$proj_dir")"
      [[ "$proj_name" == _* ]] && continue
      main_worktree="$PROJECTS/$proj_name"
      [[ -d "$main_worktree" ]] || continue
      link_one "${proj_dir%/}" "$HOME/.claude/projects/$(memory_key "$main_worktree")/memory"
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

# Новая обвязка проекта — копия (не симлинк) projects/_template/<язык>, дальше проект
# специализирует её у себя. В файлах шаблона <Project> заменяется на имя проекта,
# <DataRoot> — на корень данных, <ToolingRoot> — на корень тулинга.
init_project() {
  local proj_name="$1" proj_dir="$2"
  local tpl="$TOOLING/projects/_template/$TOOLING_LANG"
  echo "Project setup '$proj_name' from template ($TOOLING_LANG):"
  mkdir -p "$(dirname "$proj_dir")"
  cp -R "$tpl" "$proj_dir"

  local area
  for area in wiki tasks; do
    mkdir -p "$proj_dir/$area/pages"
    mv "$proj_dir/$area-CLAUDE.md" "$proj_dir/$area/CLAUDE.md"
  done
  local today
  today="$(date +%F)"
  if [[ "$TOOLING_LANG" == ru ]]; then
    printf '# Index\n\nКаталог страниц wiki проекта %s. Схема — `CLAUDE.md` рядом.\n' "$proj_name" >"$proj_dir/wiki/index.md"
    printf '# Log\n\n## [%s] ingest | Заведена wiki\nСхема из шаблона. Страниц пока нет.\n' "$today" >"$proj_dir/wiki/log.md"
    printf '# Tasks index\n\nКаталог документов по задачам проекта %s. Схема — [CLAUDE.md](CLAUDE.md), журнал — [log.md](log.md).\n' "$proj_name" >"$proj_dir/tasks/index.md"
  else
    printf '# Index\n\nCatalog of wiki pages for project %s. Schema — `CLAUDE.md` next to this file.\n' "$proj_name" >"$proj_dir/wiki/index.md"
    printf '# Log\n\n## [%s] ingest | Wiki created\nSchema from the template. No pages yet.\n' "$today" >"$proj_dir/wiki/log.md"
    printf '# Tasks index\n\nCatalog of task documents for project %s. Schema — [CLAUDE.md](CLAUDE.md), log — [log.md](log.md).\n' "$proj_name" >"$proj_dir/tasks/index.md"
  fi
  printf '# Tasks log\n' >"$proj_dir/tasks/log.md"

  local data_root tooling_root f
  data_root="$(home_form "$DATA")"
  tooling_root="$(home_form "$TOOLING")"
  # Без sed -i: у BSD и GNU sed он несовместим.
  grep -rlE '<Project>|<DataRoot>|<ToolingRoot>' "$proj_dir" | while IFS= read -r f; do
    sed -e "s|<Project>|$proj_name|g" -e "s|<DataRoot>|$data_root|g" \
      -e "s|<ToolingRoot>|$tooling_root|g" "$f" >"$f.tmp"
    cat "$f.tmp" >"$f" && rm "$f.tmp"
  done
  printf '%s %s\n' "$today" "$TOOLING_LANG" >"$proj_dir/.template-origin"
  echo "  created: $proj_dir"
}

link_worktree() {
  local worktree="$1" init="${2:-}"
  worktree="$(cd "$worktree" && pwd)"

  local main_worktree
  main_worktree="$(git -C "$worktree" worktree list --porcelain | awk '/^worktree /{sub(/^worktree /, ""); print; exit}')"
  if [[ -z "$main_worktree" ]]; then
    echo "link.sh: cannot find the main worktree for $worktree (not a git repository?)" >&2
    exit 1
  fi
  main_worktree="$(to_posix "$main_worktree")"

  local proj_name proj_dir
  proj_name="$(basename "$main_worktree")"
  proj_dir="$DATA/projects/$proj_name"
  if [[ "$proj_name" == _* ]]; then
    echo "link.sh: '$proj_name' is a template name, not a project" >&2
    exit 1
  fi
  if [[ ! -d "$proj_dir" ]]; then
    if [[ -z "$init" ]]; then
      echo "link.sh: no project setup for '$proj_name' in $DATA/projects/ (create from template: link.sh --init $worktree)" >&2
      exit 1
    fi
    init_project "$proj_name" "$proj_dir"
  fi

  echo "Project symlinks in $worktree (setup: $proj_name):"
  # Источник в обвязке : путь в воркtree : локальный двойник, если путь занят git.
  # AGENTS.md (https://agents.md/) — те же инструкции для остальных агентов.
  local entry src rel fallback
  for entry in \
    "CLAUDE.md:CLAUDE.md:CLAUDE.local.md" \
    "CLAUDE.md:AGENTS.md:" \
    "skills:.claude/skills:" \
    "agents:.claude/agents:" \
    "scripts:.claude/scripts:" \
    "settings.json:.claude/settings.json:.claude/settings.local.json"; do
    IFS=: read -r src rel fallback <<<"$entry"
    # Путь, который проект держит в git, не трогаем: симлинк поверх него git видит как
    # правку (typechange), и её легко закоммитить вместе с личным путём. Claude Code
    # читает CLAUDE.local.md и settings.local.json рядом с основными файлами.
    if is_tracked "$worktree" "$rel"; then
      restore_tracked "$worktree" "$rel"
      if [[ -n "$fallback" ]] && ! is_tracked "$worktree" "$fallback"; then
        echo "  tracked in git, using $fallback: $worktree/$rel"
        rel="$fallback"
      else
        echo "  skip (tracked in git): $worktree/$rel"
        continue
      fi
    fi
    link_one "$proj_dir/$src" "$worktree/$rel"
    ensure_excluded "$worktree" "$rel"
  done

  # Память — по реальному пути главного воркtree, где бы он ни лежал.
  if [[ -d "$DATA/memory/$proj_name" ]]; then
    link_one "$DATA/memory/$proj_name" "$HOME/.claude/projects/$(memory_key "$main_worktree")/memory"
  fi
}

case "${1:-}" in
  --home)
    link_home
    ;;
  --init)
    [[ -n "${2:-}" ]] || { echo "Usage: link.sh --init <worktree-path>" >&2; exit 1; }
    link_worktree "$2" init
    ;;
  "")
    echo "Usage: link.sh --home | link.sh [--init] <worktree-path>" >&2
    exit 1
    ;;
  *)
    link_worktree "$1"
    ;;
esac
