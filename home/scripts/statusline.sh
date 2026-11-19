#!/bin/sh
# Статус-бар Claude Code: занятость контекстного окна (проценты + токены + бар).
# JSON приходит на stdin — https://code.claude.com/docs/en/statusline

input=$(cat)

# Префикс в стиле fish-промпта по умолчанию: зелёный user@host, двоеточие,
# синий укороченный cwd (prompt_pwd: продвижные каталоги — по первой букве,
# последний — целиком), без завершающего ">".
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
user=$(id -un 2>/dev/null || echo "${USER:-user}")
host=$(hostname -s 2>/dev/null || echo "${HOST:-localhost}")

short_cwd=$(printf '%s' "$cwd" | awk -v home="$HOME" '
  {
    p = $0
    if (home != "" && index(p, home) == 1)
      p = "~" substr(p, length(home) + 1)
    n = split(p, parts, "/")
    out = parts[1]
    for (i = 2; i < n; i++)
      if (parts[i] != "") out = out "/" substr(parts[i], 1, 1)
    if (n >= 2 && parts[n] != "") out = out "/" parts[n]
    if (out == "") out = "/"
    print out
  }')

printf '\033[32m%s@%s\033[0m:\033[34m%s\033[0m' "$user" "$host" "$short_cwd"

# Ветка git, если место запуска — репа (worktree/подкаталог тоже считаются);
# detached HEAD показываем коротким хэшем.
branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
if [ -n "$branch" ]; then
  printf ' \033[36m(%s)\033[0m' "$branch"
else
  sha=$(git -C "$cwd" rev-parse --short=7 HEAD 2>/dev/null)
  if [ -n "$sha" ]; then
    printf ' \033[36m(%s)\033[0m' "$sha"
  fi
fi

# Название сессии: кастомное (/rename, --name) или автозаголовок ИИ; может отсутствовать.
session_name=$(printf '%s' "$input" | jq -r '.session_name // empty')
if [ -n "$session_name" ]; then
  printf ' \033[35m%s\033[0m' "$(printf '%s' "$session_name" | cut -c1-60)"
fi

printf '\n'

pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // 0')
tokens=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // 0')
size=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // 0')

fmt() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1000000) printf "%.1fM", n / 1000000
    else if (n >= 1000) printf "%.0fk", n / 1000
    else printf "%d", n
  }'
}

bar_part() {
  # $1 — сколько сегментов, $2 — какой символ рисовать
  awk -v n="$1" -v ch="$2" 'BEGIN { for (i = 0; i < n; i++) printf "%s", ch }'
}

BAR_WIDTH=${BAR_WIDTH:-10}
pct_int=${pct%%.*}
filled=$((pct_int * BAR_WIDTH / 100))

# Пороги: зелёный <60 %, жёлтый 60–84 %, красный ≥85 %
if [ "$pct_int" -ge 85 ]; then
  fill='31'
elif [ "$pct_int" -ge 60 ]; then
  fill='33'
else
  fill='32'
fi

printf 'Context %s%% \033[%sm%s\033[0m\033[90m%s\033[0m · %s из %s' \
  "$pct_int" \
  "$fill" \
  "$(bar_part "$filled" '▓')" \
  "$(bar_part $((BAR_WIDTH - filled)) '░')" \
  "$(fmt "$tokens")" "$(fmt "$size")"
