#!/usr/bin/env bash
#
# Обёртка коммита для /commit. Проверяет формат заголовка перед вызовом
# `git commit`, чтобы не полагаться на то, что модель каждый раз вспомнит
# правила из CLAUDE.md/памяти:
#   - заголовок однострочный (без маркированного списка изменений под ним)
#   - "Co-Authored-By" не в заголовке; трейлером из второго аргумента — только при COAUTHOR=yes
#
# Префикс задачи (`PROJ-123 ...`) скрипт не требует — это конвенция проекта
# из CLAUDE.md. Нужна жёсткая проверка — допиши её здесь в самом проекте.
#
# Использование:
#   .claude/scripts/commit.sh "PROJ-123 Fix login crash on guest flow" ["Name <noreply@anthropic.com>"]
#
set -euo pipefail

# Соавтор Claude в коммитах: yes — разрешён (личный проект), no — запрещён (рабочий).
# Ставит onboard-project по ответу пользователя.
COAUTHOR=no

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Использование: commit.sh \"<заголовок>\" [\"<Co-Authored-By>\"]" >&2
  exit 1
fi

TITLE="$1"

if [[ "$TITLE" == *$'\n'* ]]; then
  echo "Отклонено: заголовок коммита должен быть однострочным, без списка изменений под ним." >&2
  exit 1
fi

if [[ "$TITLE" == *"Co-Authored-By"* ]]; then
  echo "Отклонено: 'Co-Authored-By' — не в заголовок." >&2
  exit 1
fi

if [[ $# -eq 2 ]]; then
  if [[ "$COAUTHOR" != yes ]]; then
    echo "Отклонено: 'Co-Authored-By' запрещён в коммитах этого репозитория (COAUTHOR=no)." >&2
    exit 1
  fi
  git commit -m "$TITLE" --trailer "Co-Authored-By: $2"
else
  git commit -m "$TITLE"
fi
