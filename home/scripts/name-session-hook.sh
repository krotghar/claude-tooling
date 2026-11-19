#!/bin/sh
# Хук UserPromptSubmit: на первом промпте сессии выставляет имя сессии
# (session_title) по номеру задачи из промпта. Если номера нет — молчит, и
# сессия остаётся без кастомного имени: Claude Code сам сгенерирует
# AI-заголовок по первому промпту.
# Вход на stdin — https://code.claude.com/docs/en/hooks (UserPromptSubmit).

input=$(cat)

prompt=$(printf '%s' "$input" | jq -r '.prompt // empty')
[ -z "$prompt" ] && exit 0

# Только первый промпт: в транскрипте ещё не было ответов модели.
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
if [ -n "$transcript" ] && [ -f "$transcript" ] \
  && grep -q '"type":"assistant"' "$transcript" 2>/dev/null
then
  exit 0
fi

head_line=$(printf '%s\n' "$prompt" | head -n 1)

# Явный номер тикета: PREFIX-123 (PREFIX — 2+ букв латиницы/цифр, при желании с цифрами).
task=$(printf '%s\n' "$head_line" | grep -ioE '[a-z][a-z0-9]*[a-z][0-9]*-[0-9]{1,6}' | head -n 1)

# Голый номер «123» — только самым первым токеном сообщения.
if [ -z "$task" ]; then
  first=${head_line%%[ 	]*}
  case $first in
    [0-9]|[0-9][0-9]|[0-9][0-9][0-9]|[0-9][0-9][0-9][0-9]|\
[0-9][0-9][0-9][0-9][0-9]|[0-9][0-9][0-9][0-9][0-9][0-9]) task=$first ;;
  esac
fi

[ -z "$task" ] && exit 0

task=$(printf '%s' "$task" | tr '[:lower:]' '[:upper:]')
jq -n --arg t "$task" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", sessionTitle: $t}}'
