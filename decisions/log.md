# Журнал решений тулинга — хронология

Полная история до 2026-10-28 — в журнале данных (`$CLAUDE_DATA/decisions/log.md`).

## [2026-10-28] tooling-data-layout | тулинг выделен из каталога данных в git-репозиторий
Нейтральное перенесено копией: `link.sh` (два корня, `CLAUDE_DATA`/`CLAUDE_PROJECTS`), `home/CLAUDE.md`, шаблон `home/settings.json`, `projects/_template` (плейсхолдеры `<DataRoot>`/`<ToolingRoot>`), `memory/_template`, схема `decisions/`. Allowlist-`.gitignore`, pre-commit-хук с общими и личными паттернами.

## [2026-10-29] tooling-data-layout | leak guard: авторство не скрывается (решение 6)
Убрана проверка автора на noreply, свой `user.email` в содержимом разрешён; `CLAUDE.md` — «не проектозависимый», а не «обезличенный».

## [2026-10-31] tooling-data-layout | репозиторий публичный, MIT (решение 7)
Перед `--visibility public` — скан утечек по всей истории и PR-рефам. В истории нашлись следы приватного проекта — репо пересоздан с историей без них, старый — private `claude-tooling-old`. Добавлены `LICENSE` (MIT) и строка в allowlist `.gitignore`.
